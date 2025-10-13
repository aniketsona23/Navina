import apiClient from './api';

export interface SpeechToTextRequest {
  audio_file: string; // Base64 encoded audio or file URI
  language?: string;
}

export interface SpeechToTextResponse {
  id: number;
  transcribed_text: string;
  confidence_score: number;
  language: string;
  speaker_count: number;
  timestamps: Array<{
    word: string;
    start: number;
    end: number;
  }>;
  duration: number;
  processing_time: number;
  created_at: string;
}

export interface SpeechToTextError {
  error: string;
}

export class SpeechToTextService {
  /**
   * Transcribe audio file to text
   */
  static async transcribeAudio(
    audioUri: string,
    language: string = 'en'
  ): Promise<SpeechToTextResponse> {
    try {
      console.log('Starting transcription for audio URI:', audioUri);
      
      // Check if backend is reachable first
      try {
        await apiClient.get('/health/');
        console.log('Backend is reachable');
      } catch (healthError) {
        console.warn('Backend health check failed, proceeding anyway:', healthError);
      }
      
      // Create form data
      const formData = new FormData();
      
      // Add audio file
      formData.append('audio_file', {
        uri: audioUri,
        type: 'audio/wav',
        name: 'recording.wav',
      } as any);
      
      // Add language parameter
      formData.append('language', language);

      console.log('Sending transcription request...');
      
      // Make API call
      const response = await apiClient.post('/hearing-assist/transcribe/', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        timeout: 60000, // 60 seconds timeout for audio processing
      });

      console.log('Transcription successful:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('Speech-to-text API error:', error);
      
      if (error.code === 'NETWORK_ERROR' || error.message === 'Network Error') {
        throw new Error('Network error: Please check if the backend server is running and accessible');
      } else if (error.response) {
        // Server responded with error status
        const errorMessage = error.response.data?.error || 'Transcription failed';
        throw new Error(errorMessage);
      } else if (error.request) {
        // Request was made but no response received
        throw new Error('Network error: Unable to reach server. Please check if the backend is running on http://10.30.9.162:8000');
      } else {
        // Something else happened
        throw new Error(`Unexpected error: ${error.message || 'Unknown error occurred'}`);
      }
    }
  }

  /**
   * Get transcription history
   */
  static async getTranscriptionHistory(): Promise<SpeechToTextResponse[]> {
    try {
      const response = await apiClient.get('/hearing-assist/speech-to-text/');
      return response.data.results || response.data;
    } catch (error: any) {
      console.error('Get transcription history error:', error);
      throw new Error('Failed to fetch transcription history');
    }
  }

  /**
   * Get specific transcription by ID
   */
  static async getTranscription(id: number): Promise<SpeechToTextResponse> {
    try {
      const response = await apiClient.get(`/hearing-assist/speech-to-text/${id}/`);
      return response.data;
    } catch (error: any) {
      console.error('Get transcription error:', error);
      throw new Error('Failed to fetch transcription');
    }
  }

  /**
   * Delete transcription
   */
  static async deleteTranscription(id: number): Promise<void> {
    try {
      await apiClient.delete(`/hearing-assist/speech-to-text/${id}/`);
    } catch (error: any) {
      console.error('Delete transcription error:', error);
      throw new Error('Failed to delete transcription');
    }
  }

  /**
   * Get hearing assist statistics
   */
  static async getStats(): Promise<{
    total_analyses: number;
    speech_transcriptions: number;
    noise_detections: number;
    volume_analyses: number;
    frequency_analyses: number;
    total_sessions: number;
  }> {
    try {
      const response = await apiClient.get('/hearing-assist/stats/');
      return response.data;
    } catch (error: any) {
      console.error('Get hearing assist stats error:', error);
      throw new Error('Failed to fetch statistics');
    }
  }
}
