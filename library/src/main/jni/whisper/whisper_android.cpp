#include <jni.h>
#include <string>
#include <vector>
#include <fstream>
#include <android/log.h>
#include "whisper.h"

#define LOG_TAG "WhisperJNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// WAV header structure
struct wav_header {
    char riff[4];
    int32_t file_size;
    char wave[4];
    char fmt[4];
    int32_t fmt_size;
    int16_t audio_format;
    int16_t num_channels;
    int32_t sample_rate;
    int32_t byte_rate;
    int16_t block_align;
    int16_t bits_per_sample;
    char data[4];
    int32_t data_size;
};

std::vector<float> read_wav(const std::string& filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file.is_open()) {
        LOGE("Failed to open file: %s", filename.c_str());
        return {};
    }

    // Read RIFF header
    char riff[4];
    file.read(riff, 4);
    if (std::string(riff, 4) != "RIFF") {
        LOGE("Not a RIFF file");
        return {};
    }
    
    int32_t file_size;
    file.read(reinterpret_cast<char*>(&file_size), 4);
    
    char wave[4];
    file.read(wave, 4);
    if (std::string(wave, 4) != "WAVE") {
        LOGE("Not a WAVE file");
        return {};
    }
    
    // Find fmt chunk
    int16_t audio_format = 0;
    int16_t num_channels = 0;
    int32_t sample_rate = 0;
    int16_t bits_per_sample = 0;
    
    while (file.good()) {
        char chunk_id[4];
        int32_t chunk_size;
        file.read(chunk_id, 4);
        file.read(reinterpret_cast<char*>(&chunk_size), 4);
        
        if (std::string(chunk_id, 4) == "fmt ") {
            file.read(reinterpret_cast<char*>(&audio_format), 2);
            file.read(reinterpret_cast<char*>(&num_channels), 2);
            file.read(reinterpret_cast<char*>(&sample_rate), 4);
            file.seekg(6, std::ios::cur); // skip byte_rate and block_align
            file.read(reinterpret_cast<char*>(&bits_per_sample), 2);
            file.seekg(chunk_size - 16, std::ios::cur); // skip rest of fmt
        } else if (std::string(chunk_id, 4) == "data") {
            LOGI("WAV: %d Hz, %d channels, %d bits, %d bytes", sample_rate, num_channels, bits_per_sample, chunk_size);
            
            int num_samples = chunk_size / (bits_per_sample / 8);
            std::vector<int16_t> samples(num_samples);
            file.read(reinterpret_cast<char*>(samples.data()), chunk_size);
            
            // Convert to mono float
            std::vector<float> audio(num_samples / num_channels);
            for (size_t i = 0; i < audio.size(); i++) {
                float sum = 0;
                for (int ch = 0; ch < num_channels; ch++) {
                    sum += samples[i * num_channels + ch] / 32768.0f;
                }
                audio[i] = sum / num_channels;
            }
            
            // Resample to 16kHz
            if (sample_rate != 16000) {
                float ratio = static_cast<float>(sample_rate) / 16000.0f;
                size_t new_size = audio.size() / ratio;
                std::vector<float> resampled(new_size);
                
                for (size_t i = 0; i < new_size; i++) {
                    size_t src_idx = static_cast<size_t>(i * ratio);
                    if (src_idx < audio.size()) {
                        resampled[i] = audio[src_idx];
                    }
                }
                
                LOGI("Resampled from %zu to %zu samples", audio.size(), new_size);
                return resampled;
            }
            
            LOGI("Read %zu samples", audio.size());
            return audio;
        } else {
            file.seekg(chunk_size, std::ios::cur);
        }
    }

    LOGE("No data chunk found");
    return {};
}

extern "C" {

JNIEXPORT jfloatArray JNICALL
Java_mx_valdora_whisper_WhisperLib_readWavFile(JNIEnv *env, jclass clazz, jstring filePath) {
    const char *path = env->GetStringUTFChars(filePath, nullptr);
    
    std::vector<float> audio = read_wav(path);
    
    env->ReleaseStringUTFChars(filePath, path);
    
    if (audio.empty()) {
        return env->NewFloatArray(0);
    }
    
    jfloatArray result = env->NewFloatArray(audio.size());
    env->SetFloatArrayRegion(result, 0, audio.size(), audio.data());
    
    return result;
}

JNIEXPORT jlong JNICALL
Java_mx_valdora_whisper_WhisperLib_initContext(JNIEnv *env, jclass clazz, jstring modelPath) {
    const char *model_path = env->GetStringUTFChars(modelPath, nullptr);
    
    LOGI("Loading model: %s", model_path);
    
    struct whisper_context_params cparams = whisper_context_default_params();
    struct whisper_context *ctx = whisper_init_from_file_with_params(model_path, cparams);
    
    env->ReleaseStringUTFChars(modelPath, model_path);
    
    if (ctx == nullptr) {
        LOGE("Failed to load model");
        return 0;
    }
    
    LOGI("Model loaded successfully");
    return reinterpret_cast<jlong>(ctx);
}

JNIEXPORT jint JNICALL
Java_mx_valdora_whisper_WhisperLib_fullTranscribe(JNIEnv *env, jclass clazz, jlong contextPtr, jfloatArray audioData) {
    auto *ctx = reinterpret_cast<struct whisper_context *>(contextPtr);
    
    if (ctx == nullptr) {
        LOGE("Context is null");
        return -1;
    }
    
    jsize audio_len = env->GetArrayLength(audioData);
    jfloat *audio = env->GetFloatArrayElements(audioData, nullptr);
    
    LOGI("Transcribing %d samples", audio_len);
    
    struct whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
    wparams.language = "es";
    wparams.translate = false;
    wparams.print_progress = false;
    wparams.print_realtime = false;
    wparams.print_timestamps = false;
    
    int result = whisper_full(ctx, wparams, audio, audio_len);
    
    env->ReleaseFloatArrayElements(audioData, audio, JNI_ABORT);
    
    if (result != 0) {
        LOGE("Transcription failed: %d", result);
    } else {
        LOGI("Transcription completed");
    }
    
    return result;
}

JNIEXPORT jstring JNICALL
Java_mx_valdora_whisper_WhisperLib_getTranscriptionText(JNIEnv *env, jclass clazz, jlong contextPtr) {
    auto *ctx = reinterpret_cast<struct whisper_context *>(contextPtr);
    
    if (ctx == nullptr) {
        LOGE("Context is null");
        return env->NewStringUTF("");
    }
    
    const int n_segments = whisper_full_n_segments(ctx);
    std::string result;
    
    for (int i = 0; i < n_segments; i++) {
        const char *text = whisper_full_get_segment_text(ctx, i);
        result += text;
        if (i < n_segments - 1) {
            result += " ";
        }
    }
    
    LOGI("Transcription text: %s", result.c_str());
    return env->NewStringUTF(result.c_str());
}

JNIEXPORT void JNICALL
Java_mx_valdora_whisper_WhisperLib_freeContext(JNIEnv *env, jclass clazz, jlong contextPtr) {
    auto *ctx = reinterpret_cast<struct whisper_context *>(contextPtr);
    
    if (ctx != nullptr) {
        whisper_free(ctx);
        LOGI("Context freed");
    }
}

} // extern "C"
