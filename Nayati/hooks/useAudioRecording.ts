import { useState, useRef, useEffect } from 'react';
import { useAudioRecorder, requestRecordingPermissionsAsync, setAudioModeAsync } from 'expo-audio';

interface AudioRecordingState {
  isRecording: boolean;
  isPaused: boolean;
  duration: number;
  recordingUri: string | null;
  error: string | null;
}

interface AudioRecordingActions {
  startRecording: () => Promise<void>;
  stopRecording: () => Promise<string | null>;
  pauseRecording: () => Promise<void>;
  resumeRecording: () => Promise<void>;
  resetRecording: () => void;
}

export const useAudioRecording = (): AudioRecordingState & AudioRecordingActions => {
  const [isRecording, setIsRecording] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [duration, setDuration] = useState(0);
  const [recordingUri, setRecordingUri] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  
  const durationIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Create audio recorder with proper configuration
  const recorder = useAudioRecorder({
    android: {
      extension: '.wav',
      outputFormat: 'default',
      audioEncoder: 'default',
      sampleRate: 16000,
    },
    ios: {
      extension: '.wav',
      outputFormat: 'LINEARPCM',
      audioQuality: 1, // HIGH quality as number
      sampleRate: 16000,
      linearPCMBitDepth: 16,
      linearPCMIsBigEndian: false,
      linearPCMIsFloat: false,
    },
    web: {
      mimeType: 'audio/wav',
      bitsPerSecond: 128000,
    },
    extension: '.wav',
    sampleRate: 16000,
    numberOfChannels: 1,
    bitRate: 128000,
    isMeteringEnabled: true,
  });

  useEffect(() => {
    // Request permissions on mount
    requestPermissions();
    
    return () => {
      // Cleanup on unmount
      if (durationIntervalRef.current) {
        clearInterval(durationIntervalRef.current);
      }
    };
  }, []);

  const requestPermissions = async () => {
    try {
      const { status } = await requestRecordingPermissionsAsync();
      if (status !== 'granted') {
        setError('Audio recording permission denied');
      }
    } catch (error) {
      setError('Failed to request audio permissions');
      console.error('Permission request error:', error);
    }
  };

  const startDurationTimer = () => {
    durationIntervalRef.current = setInterval(() => {
      setDuration(prev => prev + 0.1);
    }, 100);
  };

  const stopDurationTimer = () => {
    if (durationIntervalRef.current) {
      clearInterval(durationIntervalRef.current);
      durationIntervalRef.current = null;
    }
  };

  const startRecording = async () => {
    try {
      setError(null);
      
      // Configure audio mode for recording
      await setAudioModeAsync({
        allowsRecording: true,
        playsInSilentMode: true,
        shouldPlayInBackground: false,
      });

      // Prepare the recorder first
      await recorder.prepareToRecordAsync();
      
      // Start recording
      recorder.record();
      setIsRecording(true);
      setIsPaused(false);
      setDuration(0);
      startDurationTimer();
      
    } catch (err) {
      setError(`Failed to start recording: ${err}`);
      console.error('Recording start error:', err);
    }
  };

  const stopRecording = async (): Promise<string | null> => {
    try {
      console.log('Stopping recording...');
      
      // Stop recording
      await recorder.stop();
      console.log('Recording stopped');
      
      // Wait a moment for the URI to be available
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Get the recording URI
      const uri = recorder.uri;
      console.log('Recorder URI:', uri);
      
      // Get recorder state for debugging
      const state = recorder.getStatus();
      console.log('Recorder state:', state);
      
      if (!uri && !state.url) {
        throw new Error('No recording URI available');
      }
      
      // Use the URI from either source
      const finalUri = uri || state.url;
      console.log('Final URI to use:', finalUri);
      
      if (!finalUri) {
        throw new Error('No recording URI available');
      }
      
      // Convert to a format suitable for upload
      const convertedUri = await convertAudioForUpload(finalUri);
      
      // Reset state
      setIsRecording(false);
      setIsPaused(false);
      stopDurationTimer();
      setRecordingUri(convertedUri);
      
      return convertedUri;
      
    } catch (err) {
      setError(`Failed to stop recording: ${err}`);
      console.error('Recording stop error:', err);
      return null;
    }
  };

  const pauseRecording = async () => {
    try {
      if (isRecording && !isPaused) {
        await recorder.pause();
        setIsPaused(true);
        stopDurationTimer();
      }
    } catch (err) {
      setError(`Failed to pause recording: ${err}`);
      console.error('Recording pause error:', err);
    }
  };

  const resumeRecording = async () => {
    try {
      if (isRecording && isPaused) {
        await recorder.record();
        setIsPaused(false);
        startDurationTimer();
      }
    } catch (err) {
      setError(`Failed to resume recording: ${err}`);
      console.error('Recording resume error:', err);
    }
  };

  const resetRecording = () => {
    setIsRecording(false);
    setIsPaused(false);
    setDuration(0);
    setRecordingUri(null);
    setError(null);
    stopDurationTimer();
  };

  const convertAudioForUpload = async (uri: string): Promise<string> => {
    try {
      // For now, return the original URI
      // In a production app, you might want to convert to a specific format
      return uri;
    } catch (err) {
      console.error('Audio conversion error:', err);
      return uri; // Return original URI as fallback
    }
  };

  return {
    // State
    isRecording,
    isPaused,
    duration,
    recordingUri,
    error,
    
    // Actions
    startRecording,
    stopRecording,
    pauseRecording,
    resumeRecording,
    resetRecording,
  };
};
