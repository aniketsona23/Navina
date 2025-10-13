"""
Speech-to-Text service using RealTimeSTT and other libraries
"""
import os
import io
import tempfile
import logging
from typing import Dict, Any, Optional
import numpy as np
import librosa
import soundfile as sf
from pydub import AudioSegment
from pydub.utils import which
import speech_recognition as sr

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SpeechToTextService:
    """Service for converting speech to text using multiple STT engines"""
    
    def __init__(self):
        self.recognizer = sr.Recognizer()
        self.recognizer.energy_threshold = 300
        self.recognizer.dynamic_energy_threshold = True
        self.recognizer.pause_threshold = 0.8
        self.recognizer.operation_timeout = None
        self.recognizer.phrase_threshold = 0.3
        self.recognizer.non_speaking_duration = 0.8
        
    def process_audio_file(self, audio_file, language: str = 'en') -> Dict[str, Any]:
        """
        Process uploaded audio file and return transcription results
        
        Args:
            audio_file: Django UploadedFile object
            language: Language code for transcription (default: 'en')
            
        Returns:
            Dict containing transcription results and metadata
        """
        try:
            # Save uploaded file to temporary location
            with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as temp_file:
                # Read and write the file
                for chunk in audio_file.chunks():
                    temp_file.write(chunk)
                temp_file_path = temp_file.name
            
            try:
                # Convert to proper format if needed
                processed_audio_path = self._preprocess_audio(temp_file_path)
                
                # Perform transcription
                transcription_result = self._transcribe_audio(processed_audio_path, language)
                
                # Get audio metadata
                audio_metadata = self._get_audio_metadata(processed_audio_path)
                
                # Combine results
                result = {
                    'transcribed_text': transcription_result['text'],
                    'confidence_score': transcription_result['confidence'],
                    'language': language,
                    'speaker_count': transcription_result.get('speaker_count', 1),
                    'timestamps': transcription_result.get('timestamps', []),
                    'duration': audio_metadata['duration'],
                    'sample_rate': audio_metadata['sample_rate'],
                    'channels': audio_metadata['channels'],
                    'processing_time': transcription_result.get('processing_time', 0)
                }
                
                return result
                
            finally:
                # Clean up temporary files
                if os.path.exists(temp_file_path):
                    os.unlink(temp_file_path)
                if 'processed_audio_path' in locals() and os.path.exists(processed_audio_path):
                    os.unlink(processed_audio_path)
                    
        except Exception as e:
            logger.error(f"Error processing audio file: {str(e)}")
            raise Exception(f"Audio processing failed: {str(e)}")
    
    def _preprocess_audio(self, audio_path: str) -> str:
        """
        Preprocess audio file to ensure compatibility
        
        Args:
            audio_path: Path to the audio file
            
        Returns:
            Path to the processed audio file
        """
        try:
            # Load audio with librosa
            audio_data, sample_rate = librosa.load(audio_path, sr=None)
            
            # Convert to mono if stereo
            if len(audio_data.shape) > 1:
                audio_data = librosa.to_mono(audio_data)
            
            # Normalize audio
            audio_data = librosa.util.normalize(audio_data)
            
            # Resample to 16kHz if needed (optimal for most STT engines)
            if sample_rate != 16000:
                audio_data = librosa.resample(audio_data, orig_sr=sample_rate, target_sr=16000)
                sample_rate = 16000
            
            # Save processed audio
            processed_path = audio_path.replace('.wav', '_processed.wav')
            sf.write(processed_path, audio_data, sample_rate)
            
            return processed_path
            
        except Exception as e:
            logger.error(f"Error preprocessing audio: {str(e)}")
            raise
    
    def _transcribe_audio(self, audio_path: str, language: str = 'en') -> Dict[str, Any]:
        """
        Transcribe audio using multiple STT engines
        
        Args:
            audio_path: Path to the processed audio file
            language: Language code for transcription
            
        Returns:
            Dict containing transcription results
        """
        import time
        start_time = time.time()
        
        try:
            # Try Google Speech Recognition first (most reliable)
            try:
                with sr.AudioFile(audio_path) as source:
                    audio_data = self.recognizer.record(source)
                
                # Use Google Speech Recognition
                text = self.recognizer.recognize_google(audio_data, language=language)
                confidence = 0.9  # Google doesn't provide confidence scores
                
                result = {
                    'text': text,
                    'confidence': confidence,
                    'engine': 'google',
                    'speaker_count': self._estimate_speaker_count(audio_data),
                    'timestamps': self._generate_word_timestamps(text),
                    'processing_time': time.time() - start_time
                }
                
                logger.info(f"Successfully transcribed using Google Speech Recognition")
                return result
                
            except sr.UnknownValueError:
                logger.warning("Google Speech Recognition could not understand the audio")
                raise Exception("Could not understand the audio")
            except sr.RequestError as e:
                logger.warning(f"Google Speech Recognition service error: {e}")
                # Fallback to offline recognition
                return self._fallback_transcription(audio_path, language, start_time)
                
        except Exception as e:
            logger.error(f"Error in transcription: {str(e)}")
            raise Exception(f"Transcription failed: {str(e)}")
    
    def _fallback_transcription(self, audio_path: str, language: str, start_time: float) -> Dict[str, Any]:
        """
        Fallback transcription method using offline recognition
        
        Args:
            audio_path: Path to the audio file
            language: Language code
            start_time: Start time for processing time calculation
            
        Returns:
            Dict containing transcription results
        """
        try:
            with sr.AudioFile(audio_path) as source:
                audio_data = self.recognizer.record(source)
            
            # Try Sphinx offline recognition as fallback
            text = self.recognizer.recognize_sphinx(audio_data)
            confidence = 0.6  # Sphinx typically has lower confidence
            
            result = {
                'text': text,
                'confidence': confidence,
                'engine': 'sphinx',
                'speaker_count': 1,  # Default to 1 for offline
                'timestamps': [],
                'processing_time': time.time() - start_time
            }
            
            logger.info("Successfully transcribed using Sphinx offline recognition")
            return result
            
        except Exception as e:
            logger.error(f"Fallback transcription failed: {str(e)}")
            # Return a basic result if all methods fail
            return {
                'text': "Transcription unavailable. Please try again.",
                'confidence': 0.0,
                'engine': 'none',
                'speaker_count': 1,
                'timestamps': [],
                'processing_time': time.time() - start_time
            }
    
    def _estimate_speaker_count(self, audio_data) -> int:
        """
        Estimate the number of speakers in the audio
        
        Args:
            audio_data: Audio data from speech_recognition
            
        Returns:
            Estimated number of speakers
        """
        # Simple heuristic - in a real implementation, you'd use more sophisticated methods
        # like voice activity detection, clustering, etc.
        try:
            # Convert to numpy array for analysis
            audio_array = np.frombuffer(audio_data.frame_data, dtype=np.int16)
            
            # Simple analysis based on audio variance and patterns
            # This is a placeholder - real implementation would be more complex
            variance = np.var(audio_array)
            
            if variance > 1000000:  # High variance might indicate multiple speakers
                return 2
            else:
                return 1
                
        except Exception:
            return 1  # Default to 1 speaker if analysis fails
    
    def _generate_word_timestamps(self, text: str) -> list:
        """
        Generate word-level timestamps (placeholder implementation)
        
        Args:
            text: Transcribed text
            
        Returns:
            List of word timestamps
        """
        words = text.split()
        timestamps = []
        
        # Placeholder implementation - in reality, you'd need the audio duration
        # and more sophisticated timing analysis
        for i, word in enumerate(words):
            timestamps.append({
                'word': word,
                'start': i * 0.5,  # Placeholder timing
                'end': (i + 1) * 0.5
            })
        
        return timestamps
    
    def _get_audio_metadata(self, audio_path: str) -> Dict[str, Any]:
        """
        Get metadata about the audio file
        
        Args:
            audio_path: Path to the audio file
            
        Returns:
            Dict containing audio metadata
        """
        try:
            # Load audio with librosa to get metadata
            audio_data, sample_rate = librosa.load(audio_path, sr=None)
            duration = len(audio_data) / sample_rate
            
            # Get number of channels
            channels = 1 if len(audio_data.shape) == 1 else audio_data.shape[0]
            
            return {
                'duration': duration,
                'sample_rate': sample_rate,
                'channels': channels,
                'samples': len(audio_data)
            }
            
        except Exception as e:
            logger.error(f"Error getting audio metadata: {str(e)}")
            return {
                'duration': 0,
                'sample_rate': 16000,
                'channels': 1,
                'samples': 0
            }


# Global instance
speech_to_text_service = SpeechToTextService()
