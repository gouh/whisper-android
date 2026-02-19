package com.whispercpp;

public class WhisperLib {
    
    // Native methods
    public static native long initContext(String modelPath);
    public static native int fullTranscribe(long contextPtr, float[] audioData);
    public static native String getTranscriptionText(long contextPtr);
    public static native void freeContext(long contextPtr);
    public static native float[] readWavFile(String filePath);
}
