package mx.valdora.whisper

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
     * Transcribe WAV audio file (16kHz, mono, PCM)
     * 
     * @param audioFile Audio file to transcribe
     * @return Transcribed text
     */
    suspend fun transcribe(audioFile: File): String = withContext(Dispatchers.IO) {
        if (!audioFile.exists()) {
            throw IllegalArgumentException("Audio file does not exist: ${audioFile.absolutePath}")
        }
        
        if (!audioFile.name.endsWith(".wav", ignoreCase = true)) {
            throw IllegalArgumentException("Only WAV files are supported. Got: ${audioFile.extension}")
        }
        
        val audioData = WhisperLib.readWavFile(audioFile.absolutePath)
            ?: throw IllegalArgumentException("Failed to read WAV file. Make sure it's 16kHz mono PCM.")
        
        val result = WhisperLib.fullTranscribe(contextPtr, audioData)
        if (result != 0) {
            throw RuntimeException("Transcription failed with code: $result")
        }
        
        WhisperLib.getTranscriptionText(contextPtr)
            ?: throw RuntimeException("Failed to get transcription text")
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
            ?: throw RuntimeException("Failed to get transcription text")
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
