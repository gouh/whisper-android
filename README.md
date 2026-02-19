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

**Hugo Hernández Valdez**  
Website: [hangouh.me](https://hangouh.me)  
Email: hugohv10@gmail.com

Built with ❤️ for offline speech recognition on Android
