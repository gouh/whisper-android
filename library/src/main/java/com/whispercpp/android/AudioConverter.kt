package com.whispercpp.android

import java.io.File

/**
 * Audio converter using FFmpeg (via reflection)
 * Converts various audio formats to 16kHz mono WAV for Whisper
 * 
 * Requires ffmpeg-kit-audio dependency in your app:
 * implementation("com.arthenica:ffmpeg-kit-audio:5.1")
 */
object AudioConverter {
    
    private var ffmpegAvailable: Boolean? = null
    
    private fun isFFmpegAvailable(): Boolean {
        if (ffmpegAvailable == null) {
            ffmpegAvailable = try {
                Class.forName("com.arthenica.ffmpegkit.FFmpegKit")
                true
            } catch (e: ClassNotFoundException) {
                false
            }
        }
        return ffmpegAvailable!!
    }
    
    /**
     * Convert audio file to WAV format compatible with Whisper
     * 
     * @param inputPath Path to input audio file (MP3, M4A, AAC, OGG, FLAC, etc.)
     * @param outputPath Path for output WAV file (optional, creates temp file if null)
     * @return Path to converted WAV file
     * @throws UnsupportedOperationException if FFmpeg is not available
     * @throws IllegalArgumentException if conversion fails
     */
    fun convertToWav(inputPath: String, outputPath: String? = null): String {
        if (!isFFmpegAvailable()) {
            throw UnsupportedOperationException(
                "FFmpeg not available. Add dependency: implementation(\"com.arthenica:ffmpeg-kit-audio:5.1\")"
            )
        }
        
        val input = File(inputPath)
        if (!input.exists()) {
            throw IllegalArgumentException("Input file not found: $inputPath")
        }
        
        val output = outputPath?.let { File(it) } 
            ?: File.createTempFile("whisper_", ".wav")
        
        // FFmpeg command: convert to 16kHz mono WAV
        val command = "-i \"${input.absolutePath}\" -ar 16000 -ac 1 -c:a pcm_s16le -y \"${output.absolutePath}\""
        
        try {
            // Use reflection to call FFmpegKit.execute()
            val ffmpegKitClass = Class.forName("com.arthenica.ffmpegkit.FFmpegKit")
            val executeMethod = ffmpegKitClass.getMethod("execute", String::class.java)
            val session = executeMethod.invoke(null, command)
            
            // Check return code
            val returnCodeClass = Class.forName("com.arthenica.ffmpegkit.ReturnCode")
            val isSuccessMethod = returnCodeClass.getMethod("isSuccess", Class.forName("com.arthenica.ffmpegkit.ReturnCode"))
            val getReturnCodeMethod = session.javaClass.getMethod("getReturnCode")
            val returnCode = getReturnCodeMethod.invoke(session)
            val success = isSuccessMethod.invoke(null, returnCode) as Boolean
            
            if (!success) {
                val getFailStackTraceMethod = session.javaClass.getMethod("getFailStackTrace")
                val error = getFailStackTraceMethod.invoke(session) as? String ?: "Unknown error"
                throw IllegalArgumentException("Audio conversion failed: $error")
            }
        } catch (e: ClassNotFoundException) {
            throw UnsupportedOperationException("FFmpeg not available", e)
        } catch (e: NoSuchMethodException) {
            throw UnsupportedOperationException("FFmpeg API incompatible", e)
        } catch (e: Exception) {
            throw IllegalArgumentException("Audio conversion failed: ${e.message}", e)
        }
        
        if (!output.exists() || output.length() == 0L) {
            throw IllegalArgumentException("Conversion produced empty file")
        }
        
        return output.absolutePath
    }
    
    /**
     * Check if file format is supported
     */
    fun isSupported(filePath: String): Boolean {
        val extension = File(filePath).extension.lowercase()
        return extension in supportedFormats
    }
    
    /**
     * Get list of supported audio formats
     */
    val supportedFormats = setOf(
        "wav", "mp3", "m4a", "aac", "ogg", 
        "flac", "opus", "wma", "webm", "amr"
    )
}
