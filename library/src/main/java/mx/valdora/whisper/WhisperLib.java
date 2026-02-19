package mx.valdora.whisper;

public class WhisperLib {
    static {
        System.loadLibrary("whisper_android");
    }

    public static native float[] readWavFile(String path);
    public static native long initContext(String modelPath);
    public static native int fullTranscribe(long contextPtr, float[] audioData);
    public static native String getTranscriptionText(long contextPtr);
    public static native void freeContext(long contextPtr);
}
