# Whisper Android

Offline speech-to-text library for Android using [whisper.cpp](https://github.com/ggerganov/whisper.cpp)

## Features

- ✅ 100% offline transcription
- ✅ No external API calls
- ✅ Supports Spanish and multiple languages
- ✅ WAV support built-in (no extra dependencies)
- ✅ Optional MP3/M4A/AAC/OGG/FLAC support (with FFmpeg)
- ✅ Automatic audio conversion
- ✅ Kotlin coroutines support
- ✅ Lightweight (1.9 MB base, ~10 MB with FFmpeg)

## Installation

### Gradle

```gradle
dependencies {
    implementation 'com.whispercpp:whisper-android:1.0.0'
    
    // Optional: For MP3/M4A/AAC/OGG support (adds ~8MB)
    implementation 'com.arthenica:ffmpeg-kit-audio:5.1'
}
```

### ⚠️ Important: Audio Format Support

| Format | Requires FFmpeg? | Library Size |
|--------|-----------------|--------------|
| WAV    | ❌ No (built-in) | 1.9 MB      |
| MP3, M4A, AAC, OGG, FLAC | ✅ Yes (add dependency above) | +8 MB |

**Without FFmpeg**: Only WAV files work  
**With FFmpeg**: All audio formats work automatically

### Download Model

Download a Whisper model from [Hugging Face](https://huggingface.co/ggerganov/whisper.cpp):

```bash
# Base model (~140MB)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

Place it in your app's assets or download at runtime.

## Usage

### Basic Example

```kotlin
import com.whispercpp.android.WhisperContext

// 1. Initialize context with model path
val modelPath = File(context.filesDir, "ggml-base.bin").absolutePath
val whisper = WhisperContext(modelPath)

// 2. Transcribe audio file (supports WAV, MP3, M4A, etc.)
val text = whisper.transcribe("/path/to/audio.mp3")
println("Transcription: $text")

// 3. Clean up
whisper.close()
```

### Supported Audio Formats

**WAV files work out of the box:**

```kotlin
// No additional dependencies needed
whisper.transcribe("/path/to/audio.wav")
```

**For other formats (MP3, M4A, etc.), add FFmpeg:**

```gradle
dependencies {
    implementation 'com.whispercpp:whisper-android:1.0.0'
    implementation 'com.arthenica:ffmpeg-kit-audio:5.1'  // Add this for MP3/M4A/etc
}
```

```kotlin
// Now all formats work automatically
whisper.transcribe("/path/to/audio.mp3")   // MP3
whisper.transcribe("/path/to/audio.m4a")   // M4A/AAC
whisper.transcribe("/path/to/audio.ogg")   // OGG Vorbis
whisper.transcribe("/path/to/audio.flac")  // FLAC
whisper.transcribe("/path/to/audio.wav")   // WAV (no conversion)

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
