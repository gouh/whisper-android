# Whisper Android

Offline speech-to-text library for Android using [whisper.cpp](https://github.com/ggerganov/whisper.cpp)

## Features

- ✅ 100% offline transcription
- ✅ No external API calls or dependencies
- ✅ Supports Spanish and multiple languages
- ✅ WAV audio support (16kHz, mono, PCM)
- ✅ Kotlin coroutines support
- ✅ Lightweight (1.9 MB)
- ✅ arm64-v8a and x86_64 architectures

## Installation

### Maven Local

```gradle
repositories {
    mavenLocal()
}

dependencies {
    implementation 'mx.valdora:whisper-android:1.0.0'
}
```

### Download Model

Download a Whisper model from [Hugging Face](https://huggingface.co/ggerganov/whisper.cpp):

```bash
# Base model (~140MB) - Recommended
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin

# Tiny model (~75MB) - Faster but less accurate
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin

# Small model (~466MB) - More accurate
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin
```

Place it in your app's assets or download at runtime.

## Usage

### Basic Transcription

```kotlin
import mx.valdora.whisper.WhisperContext
import java.io.File

// 1. Initialize context with model path
val modelPath = File(context.filesDir, "ggml-base.bin").absolutePath
val whisper = WhisperContext(modelPath)

// 2. Transcribe audio file (WAV only)
val audioFile = File("/path/to/audio.wav")
val text = whisper.transcribe(audioFile)
println("Transcription: $text")

// 3. Clean up
whisper.close()
```

### Recording Audio in WAV Format

To record audio directly in WAV format on Android:

```kotlin
val recorder = MediaRecorder().apply {
    setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
    setOutputFormat(MediaRecorder.OutputFormat.WAV)
    setAudioEncoder(MediaRecorder.AudioEncoder.PCM_16BIT)
    setAudioSamplingRate(16000)  // 16kHz for Whisper
    setAudioChannels(1)  // Mono
    setOutputFile(outputFile)
    prepare()
    start()
}

// Stop recording
recorder.stop()
recorder.release()

// Now transcribe
val text = whisper.transcribe(File(outputFile))
```

### With Coroutines

```kotlin
lifecycleScope.launch {
    try {
        val text = whisper.transcribe(audioFile)
        textView.text = text
    } catch (e: Exception) {
        Log.e("Whisper", "Transcription failed", e)
    }
}
```

## Audio Requirements

- **Format**: WAV (PCM)
- **Sample Rate**: 16kHz
- **Channels**: Mono (1 channel)
- **Bit Depth**: 16-bit

## Building from Source

```bash
# Clone repository
git clone https://github.com/gouh/whisper-android.git
cd whisper-android

# Build and publish to Maven Local
make publish

# Or manually
./gradlew :library:publishToMavenLocal
```

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov
- [Whisper](https://github.com/openai/whisper) by OpenAI

## Author

Hugo Hernández Valdez  
Email: hugohv10@gmail.com  
Website: [valdora.mx](https://valdora.mx)

### Basic Example

```kotlin
import mx.valdora.whisper.WhisperContext
import java.io.File

// 1. Initialize context with model path
val modelPath = File(context.filesDir, "ggml-base.bin").absolutePath
val whisper = WhisperContext(modelPath)

// 2. Transcribe audio file (WAV only)
val audioFile = File("/path/to/audio.wav")
val text = whisper.transcribe(audioFile)
println("Transcription: $text")

// 3. Clean up
whisper.close()
```

### Audio Format

Only WAV files are supported (16kHz, mono, PCM):

```kotlin
whisper.transcribe(File("/path/to/audio.wav"))
```

To record audio in WAV format on Android:

```kotlin
val recorder = MediaRecorder().apply {
    setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
    setOutputFormat(MediaRecorder.OutputFormat.WAV)
    setAudioEncoder(MediaRecorder.AudioEncoder.PCM_16BIT)
    setAudioSamplingRate(16000)  // 16kHz for Whisper
    setAudioChannels(1)  // Mono
    setOutputFile(outputFile)
    prepare()
    start()
}
```

// Disable auto-conversion if needed
whisper.transcribe("/path/to/audio.wav", autoConvert = false)
```

**Without FFmpeg**, attempting to transcribe non-WAV files will throw:
```
UnsupportedOperationException: Cannot convert mp3 to WAV. 
Either provide a WAV file or add FFmpeg dependency
```

### With Coroutines

```kotlin
lifecycleScope.launch {
    try {
        val whisper = WhisperContext(modelPath)
        val text = whisper.transcribe(audioPath)
        textView.text = text
        whisper.close()
    } catch (e: Exception) {
        Log.e("Whisper", "Error: ${e.message}")
    }
}
```

### Transcribe from Assets

```kotlin
// Copy model from assets
fun copyModelFromAssets(context: Context): String {
    val modelFile = File(context.filesDir, "ggml-base.bin")
    if (!modelFile.exists()) {
        context.assets.open("ggml-base.bin").use { input ->
            modelFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
    }
    return modelFile.absolutePath
}

// Use it
val modelPath = copyModelFromAssets(context)
val whisper = WhisperContext(modelPath)
```

## Audio Requirements

### Supported Formats

**Without additional dependencies (WAV only):**
- WAV (PCM) - 1.9 MB library size

**With FFmpeg (all formats):**
- WAV, MP3, M4A, AAC, OGG, FLAC, OPUS, WMA, WebM, AMR
- Requires adding: `implementation 'com.arthenica:ffmpeg-kit-audio:5.1'` (~8 MB additional)
- Auto-conversion to 16kHz mono WAV

**Audio specifications:**
- **Sample Rate**: Any (automatically resampled to 16kHz)
- **Channels**: Mono or Stereo (converted to mono)
- **Bit Depth**: Any (converted to 16-bit PCM)

## API Reference

### WhisperContext

```kotlin
class WhisperContext(modelPath: String) : Closeable {
    
    // Transcribe WAV file
    suspend fun transcribe(audioPath: String): String
    
    // Transcribe audio data directly
    suspend fun transcribe(audioData: FloatArray): String
    
    // Release resources
    override fun close()
}
```

### WhisperLib (Low-level)

```java
public class WhisperLib {
    static native long initContext(String modelPath);
    static native int fullTranscribe(long contextPtr, float[] audioData);
    static native String getTranscriptionText(long contextPtr);
    static native void freeContext(long contextPtr);
    static native float[] readWavFile(String filePath);
}
```

## Supported Architectures

- `arm64-v8a` (64-bit ARM)
- `x86_64` (64-bit x86, for emulators)

## Model Sizes

| Model | Size | Speed | Accuracy |
|-------|------|-------|----------|
| tiny  | 75 MB | Fast | Good |
| base  | 140 MB | Medium | Better |
| small | 460 MB | Slow | Best |

## Performance

- **Base model on mid-range phone**: ~1-2x realtime
- **1 minute audio**: ~30-60 seconds to transcribe
- **Memory usage**: ~200-500 MB

## License

MIT

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) by Georgi Gerganov
- [OpenAI Whisper](https://github.com/openai/whisper)

## Author

**Hugo Hernández Valdez**
- Website: [hangouh.me](https://hangouh.me)
- GitHub: [@gouh](https://github.com/gouh)
- Email: hugohv10@gmail.com

Built with ❤️ for offline speech recognition on Android
