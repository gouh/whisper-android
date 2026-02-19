package com.whispercpp.android

import com.whispercpp.WhisperLib
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.Closeable
import java.io.File

/**
 * Whisper.cpp context for audio transcription
 * 
 * @param modelPath Absolute path to ggml model file
 */
class WhisperContext(modelPath: String) : Closeable {
    
    private val contextPtr: Long = WhisperLib.initContext(modelPath)
    
    init {
        if (contextPtr == 0L) {
            throw IllegalStateException("Failed to initialize Whisper context from: $modelPath")
        }
    }
    
    /**
     * Transcribe audio file (supports WAV, MP3, M4A, AAC, OGG, FLAC, etc.)
     * 
     * @param audioPath Absolute path to audio file
     * @param autoConvert Automatically convert non-WAV files (default: true, requires FFmpeg)
     * @return Transcribed text
     */
    suspend fun transcribe(audioPath: String, autoConvert: Boolean = true): String = withContext(Dispatchers.IO) {
        val isWav = audioPath.endsWith(".wav", ignoreCase = true)
        
        val wavPath = if (!isWav && autoConvert) {
            // Try to convert if FFmpeg is available
            try {
                AudioConverter.convertToWav(audioPath)
            } catch (e: UnsupportedOperationException) {
                throw UnsupportedOperationException(
                    "Cannot convert ${File(audioPath).extension} to WAV. " +
                    "Either provide a WAV file or add FFmpeg dependency: " +
                    "implementation(\"com.arthenica:ffmpeg-kit-audio:5.1\")",
                    e
                )
            }
        } else {
            audioPath
        }
        
        val audioData = WhisperLib.readWavFile(wavPath)
        if (audioData.isEmpty()) {
            throw IllegalArgumentException("Failed to read audio file: $wavPath")
        }
        
        // Clean up temp file if we converted
        if (wavPath != audioPath) {
            File(wavPath).delete()
        }
        
        val result = WhisperLib.fullTranscribe(contextPtr, audioData)
        if (result != 0) {
            throw RuntimeException("Transcription failed with code: $result")
        }
        
        WhisperLib.getTranscriptionText(contextPtr)
    }
    
    /**
     * Transcribe audio data directly
     * 
     * @param audioData Float array of 16kHz mono audio samples
     * @return Transcribed text
     */
    suspend fun transcribe(audioData: FloatArray): String = withContext(Dispatchers.IO) {
        val result = WhisperLib.fullTranscribe(contextPtr, audioData)
        if (result != 0) {
            throw RuntimeException("Transcription failed with code: $result")
        }
        
        WhisperLib.getTranscriptionText(contextPtr)
    }
    
    override fun close() {
        if (contextPtr != 0L) {
            WhisperLib.freeContext(contextPtr)
        }
    }
    
    companion object {
        init {
            System.loadLibrary("whisper_android")
        }
    }
}
