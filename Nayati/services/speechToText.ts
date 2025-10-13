import { Audio } from 'expo-av';
import { AssemblyAI } from 'assemblyai';

export interface TranscriptionResult {
  speaker: string;
  text: string;
  time: string;
  confidence?: number;
}

export class SpeechToTextService {
  private client: AssemblyAI;
  private recording: Audio.Recording | null = null;
  private isRecording = false;
  private transcriptionQueue: string[] = [];
  private isProcessing = false;
  private recordingInterval: NodeJS.Timeout | null = null;

  constructor(apiKey: string) {
    this.client = new AssemblyAI({
      apiKey: apiKey,
    });
  }

  async requestPermissions(): Promise<boolean> {
    try {
      const { status } = await Audio.requestPermissionsAsync();
      return status === 'granted';
    } catch (error) {
      console.error('Error requesting audio permissions:', error);
      return false;
    }
  }

  async startTranscription(
    onTranscript: (result: TranscriptionResult) => void,
    onError: (error: Error) => void
  ): Promise<void> {
    try {
      // Check permissions
      const hasPermission = await this.requestPermissions();
      if (!hasPermission) {
        throw new Error('Audio recording permission denied');
      }

      // Configure audio recording
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
        shouldDuckAndroid: true,
        playThroughEarpieceAndroid: false,
        staysActiveInBackground: true,
      });

      console.log('Starting real speech-to-text recording');
      this.isRecording = true;

      // Start periodic transcription processing
      this.startPeriodicTranscription(onTranscript, onError);

    } catch (error) {
      console.error('Error starting transcription:', error);
      onError(error as Error);
    }
  }

  private async startPeriodicTranscription(
    onTranscript: (result: TranscriptionResult) => void,
    onError: (error: Error) => void
  ): Promise<void> {
    const processAudio = async () => {
      if (!this.isRecording || this.isProcessing) {
        return;
      }

      try {
        // Stop current recording and get URI
        if (this.recording) {
          await this.recording.stopAndUnloadAsync();
          const uri = this.recording.getURI();
          
          if (uri) {
            // Transcribe the audio
            await this.transcribeAudio(uri, onTranscript, onError);
          }

          // Start recording again
          await this.startNewRecording();
        } else {
          // Start first recording
          await this.startNewRecording();
        }
      } catch (error) {
        console.error('Error in periodic transcription:', error);
        onError(error as Error);
      }

      // Schedule next processing
      this.recordingInterval = setTimeout(processAudio, 5000); // Process every 5 seconds
    };

    // Start the first processing
    this.recordingInterval = setTimeout(processAudio, 5000);
  }

  private async startNewRecording(): Promise<void> {
    const recordingOptions = {
      android: {
        extension: '.wav',
        outputFormat: 2, // DEFAULT
        audioEncoder: 3, // DEFAULT
        sampleRate: 16000,
        numberOfChannels: 1,
        bitRate: 128000,
      },
      ios: {
        extension: '.wav',
        outputFormat: 'lpcm',
        audioQuality: 127, // HIGH quality
        sampleRate: 16000,
        numberOfChannels: 1,
        bitRate: 128000,
        linearPCMBitDepth: 16,
        linearPCMIsBigEndian: false,
        linearPCMIsFloat: false,
      },
      web: {
        mimeType: 'audio/wav',
        bitsPerSecond: 128000,
      },
    };

    this.recording = new Audio.Recording();
    await this.recording.prepareToRecordAsync(recordingOptions);
    await this.recording.startAsync();
  }

  private async transcribeAudio(
    uri: string,
    onTranscript: (result: TranscriptionResult) => void,
    onError: (error: Error) => void
  ): Promise<void> {
    this.isProcessing = true;
    
    try {
      // Read the audio file and convert to buffer
      const response = await fetch(uri);
      const audioBuffer = await response.arrayBuffer();

      // Transcribe using AssemblyAI
      const transcript = await this.client.transcripts.transcribe({
        audio: audioBuffer,
        language_detection: true,
        punctuate: true,
        format_text: true,
      });

      if (transcript.text && transcript.text.trim().length > 0) {
        const result: TranscriptionResult = {
          speaker: 'Speaker',
          text: transcript.text,
          time: new Date().toLocaleTimeString(),
          confidence: transcript.confidence || undefined,
        };

        console.log('Transcription result:', result);
        onTranscript(result);
      }
    } catch (error) {
      console.error('Error transcribing audio:', error);
      onError(error as Error);
    } finally {
      this.isProcessing = false;
    }
  }

  async stopTranscription(): Promise<void> {
    try {
      console.log('Stopping speech-to-text recording');
      
      if (this.recordingInterval) {
        clearTimeout(this.recordingInterval);
        this.recordingInterval = null;
      }

      if (this.recording) {
        await this.recording.stopAndUnloadAsync();
        this.recording = null;
      }

      this.isRecording = false;
    } catch (error) {
      console.error('Error stopping transcription:', error);
    }
  }

  getRecordingStatus(): boolean {
    return this.isRecording;
  }
}

// Export a singleton instance
export const speechToTextService = new SpeechToTextService('7515813707144831b2e9965e9c796a7a');
