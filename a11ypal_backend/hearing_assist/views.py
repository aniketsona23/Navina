from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
import logging
from .models import (
    AudioAnalysis, SpeechToText, NoiseDetection, 
    VolumeAnalysis, FrequencyAnalysis, HearingAssistSession, HearingAidSettings
)
from .serializers import (
    AudioAnalysisSerializer, SpeechToTextSerializer, NoiseDetectionSerializer,
    VolumeAnalysisSerializer, FrequencyAnalysisSerializer, HearingAssistSessionSerializer,
    HearingAidSettingsSerializer, AudioAnalysisCreateSerializer
)
from services.speech_to_text_service import speech_to_text_service

logger = logging.getLogger(__name__)


class AudioAnalysisListView(generics.ListCreateAPIView):
    """List and create audio analyses"""
    serializer_class = AudioAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return AudioAnalysis.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class SpeechToTextListView(generics.ListCreateAPIView):
    """List and create speech-to-text analyses"""
    serializer_class = SpeechToTextSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return SpeechToText.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class NoiseDetectionListView(generics.ListCreateAPIView):
    """List and create noise detection analyses"""
    serializer_class = NoiseDetectionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return NoiseDetection.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class VolumeAnalysisListView(generics.ListCreateAPIView):
    """List and create volume analysis"""
    serializer_class = VolumeAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return VolumeAnalysis.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class FrequencyAnalysisListView(generics.ListCreateAPIView):
    """List and create frequency analysis"""
    serializer_class = FrequencyAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return FrequencyAnalysis.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class HearingAssistSessionListView(generics.ListCreateAPIView):
    """List and create hearing assist sessions"""
    serializer_class = HearingAssistSessionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return HearingAssistSession.objects.filter(user=self.request.user).order_by('-start_time')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class HearingAidSettingsView(generics.RetrieveUpdateAPIView):
    """Get and update hearing aid settings"""
    serializer_class = HearingAidSettingsSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        settings, created = HearingAidSettings.objects.get_or_create(user=self.request.user)
        return settings


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def transcribe_audio(request):
    """Transcribe audio file to text using RealTimeSTT and other STT engines"""
    try:
        if 'audio_file' not in request.FILES:
            return Response({'error': 'Audio file required'}, status=status.HTTP_400_BAD_REQUEST)
        
        audio_file = request.FILES['audio_file']
        language = request.data.get('language', 'en')
        
        # Validate file type
        allowed_types = ['audio/wav', 'audio/mp3', 'audio/mpeg', 'audio/ogg', 'audio/m4a']
        if audio_file.content_type not in allowed_types:
            return Response({
                'error': 'Unsupported audio format. Please upload WAV, MP3, OGG, or M4A files.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Validate file size (max 10MB)
        max_size = 10 * 1024 * 1024  # 10MB
        if audio_file.size > max_size:
            return Response({
                'error': 'File too large. Maximum size is 10MB.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Processing audio file: {audio_file.name}, size: {audio_file.size} bytes, language: {language}")
        
        # Process audio using speech-to-text service
        transcription_result = speech_to_text_service.process_audio_file(audio_file, language)
        
        # Save to database
        speech_to_text = SpeechToText.objects.create(
            user=request.user,
            audio_file=audio_file,
            transcribed_text=transcription_result['transcribed_text'],
            language=transcription_result['language'],
            confidence_score=transcription_result['confidence_score'],
            speaker_count=transcription_result['speaker_count'],
            timestamps=transcription_result['timestamps']
        )
        
        logger.info(f"Successfully transcribed audio for user {request.user.id}")
        
        # Return the result
        return Response({
            'id': speech_to_text.id,
            'transcribed_text': speech_to_text.transcribed_text,
            'confidence_score': speech_to_text.confidence_score,
            'language': speech_to_text.language,
            'speaker_count': speech_to_text.speaker_count,
            'timestamps': speech_to_text.timestamps,
            'duration': transcription_result['duration'],
            'processing_time': transcription_result['processing_time'],
            'created_at': speech_to_text.created_at
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        logger.error(f"Error transcribing audio: {str(e)}")
        return Response({
            'error': f'Transcription failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def detect_noise(request):
    """Analyze audio file for noise detection"""
    if 'audio_file' not in request.FILES:
        return Response({'error': 'Audio file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    audio_file = request.FILES['audio_file']
    
    # Mock noise detection result
    mock_noise_level = 75.5  # Decibels
    mock_noise_type = 'traffic'
    mock_recommendations = "Consider using noise-canceling headphones or moving to a quieter location for better audio clarity."
    
    noise_detection = NoiseDetection.objects.create(
        user=request.user,
        audio_file=audio_file,
        noise_level=mock_noise_level,
        noise_type=mock_noise_type,
        recommendations=mock_recommendations
    )
    
    return Response(NoiseDetectionSerializer(noise_detection).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_volume(request):
    """Analyze audio volume levels"""
    if 'audio_file' not in request.FILES:
        return Response({'error': 'Audio file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    audio_file = request.FILES['audio_file']
    
    # Mock volume analysis result
    mock_avg_volume = 65.2  # Average decibels
    mock_peak_volume = 85.7  # Peak decibels
    mock_consistency = 'consistent'
    mock_recommendations = "Volume levels are within normal range. Consider adjusting if you experience hearing difficulties."
    
    volume_analysis = VolumeAnalysis.objects.create(
        user=request.user,
        audio_file=audio_file,
        average_volume=mock_avg_volume,
        peak_volume=mock_peak_volume,
        volume_consistency=mock_consistency,
        recommendations=mock_recommendations
    )
    
    return Response(VolumeAnalysisSerializer(volume_analysis).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_frequency(request):
    """Analyze audio frequency spectrum"""
    if 'audio_file' not in request.FILES:
        return Response({'error': 'Audio file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    audio_file = request.FILES['audio_file']
    
    # Mock frequency analysis result
    mock_dominant_frequencies = [250, 500, 1000, 2000, 4000, 8000]  # Hz
    mock_frequency_spectrum = {
        '250Hz': 0.8,
        '500Hz': 0.9,
        '1000Hz': 0.95,
        '2000Hz': 0.85,
        '4000Hz': 0.7,
        '8000Hz': 0.6
    }
    mock_recommendations = "Consider hearing aid adjustments for frequencies below 2000Hz where sensitivity is reduced."
    
    frequency_analysis = FrequencyAnalysis.objects.create(
        user=request.user,
        audio_file=audio_file,
        dominant_frequencies=mock_dominant_frequencies,
        frequency_spectrum=mock_frequency_spectrum,
        hearing_aid_recommendations=mock_recommendations
    )
    
    return Response(FrequencyAnalysisSerializer(frequency_analysis).data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def hearing_assist_stats(request):
    """Get hearing assistance usage statistics"""
    user = request.user
    
    stats = {
        'total_analyses': AudioAnalysis.objects.filter(user=user).count(),
        'speech_transcriptions': SpeechToText.objects.filter(user=user).count(),
        'noise_detections': NoiseDetection.objects.filter(user=user).count(),
        'volume_analyses': VolumeAnalysis.objects.filter(user=user).count(),
        'frequency_analyses': FrequencyAnalysis.objects.filter(user=user).count(),
        'total_sessions': HearingAssistSession.objects.filter(user=user).count(),
    }
    
    return Response(stats)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_hearing_aid_settings(request):
    """Update user's hearing aid settings"""
    settings, created = HearingAidSettings.objects.get_or_create(user=request.user)
    serializer = HearingAidSettingsSerializer(settings, data=request.data, partial=True)
    
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)