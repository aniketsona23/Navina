from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()


class AudioAnalysis(models.Model):
    """Store audio analysis results for hearing assistance"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='audio_analyses')
    audio_file = models.FileField(upload_to='hearing_assist/audio/')
    analysis_type = models.CharField(
        max_length=20,
        choices=[
            ('speech_to_text', 'Speech to Text'),
            ('noise_detection', 'Noise Detection'),
            ('volume_analysis', 'Volume Analysis'),
            ('frequency_analysis', 'Frequency Analysis'),
            ('emotion_detection', 'Emotion Detection'),
        ]
    )
    result = models.JSONField()
    confidence_score = models.FloatField(null=True, blank=True)
    processing_time = models.FloatField(null=True, blank=True)
    duration = models.FloatField(null=True, blank=True)  # Audio duration in seconds
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Audio Analysis {self.id} - {self.analysis_type}"


class SpeechToText(models.Model):
    """Store speech-to-text conversion results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='speech_to_texts')
    audio_file = models.FileField(upload_to='hearing_assist/speech/')
    transcribed_text = models.TextField()
    language = models.CharField(max_length=10, default='en')
    confidence_score = models.FloatField()
    speaker_count = models.IntegerField(default=1)
    timestamps = models.JSONField(default=list)  # Word-level timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Speech-to-Text {self.id} - {self.transcribed_text[:50]}..."


class NoiseDetection(models.Model):
    """Store noise detection and analysis results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='noise_detections')
    audio_file = models.FileField(upload_to='hearing_assist/noise/')
    noise_level = models.FloatField()  # Decibel level
    noise_type = models.CharField(
        max_length=20,
        choices=[
            ('traffic', 'Traffic'),
            ('construction', 'Construction'),
            ('crowd', 'Crowd'),
            ('music', 'Music'),
            ('speech', 'Speech'),
            ('other', 'Other'),
        ]
    )
    recommendations = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Noise Detection {self.id} - {self.noise_type}"


class VolumeAnalysis(models.Model):
    """Store volume analysis results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='volume_analyses')
    audio_file = models.FileField(upload_to='hearing_assist/volume/')
    average_volume = models.FloatField()  # Average decibel level
    peak_volume = models.FloatField()  # Peak decibel level
    volume_consistency = models.CharField(
        max_length=20,
        choices=[
            ('very_consistent', 'Very Consistent'),
            ('consistent', 'Consistent'),
            ('variable', 'Variable'),
            ('inconsistent', 'Inconsistent'),
        ]
    )
    recommendations = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Volume Analysis {self.id}"


class FrequencyAnalysis(models.Model):
    """Store frequency analysis results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='frequency_analyses')
    audio_file = models.FileField(upload_to='hearing_assist/frequency/')
    dominant_frequencies = models.JSONField()  # List of dominant frequencies
    frequency_spectrum = models.JSONField()  # Full frequency spectrum data
    hearing_aid_recommendations = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Frequency Analysis {self.id}"


class HearingAssistSession(models.Model):
    """Track hearing assistance sessions"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='hearing_sessions')
    session_type = models.CharField(
        max_length=20,
        choices=[
            ('microphone', 'Microphone'),
            ('file_upload', 'File Upload'),
            ('live_stream', 'Live Stream'),
        ]
    )
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    total_analyses = models.IntegerField(default=0)
    session_data = models.JSONField(default=dict)
    
    def __str__(self):
        return f"Hearing Session {self.id} - {self.user.username}"


class HearingAidSettings(models.Model):
    """Store user's hearing aid settings and preferences"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='hearing_aid_settings')
    amplification_level = models.IntegerField(default=50)  # 0-100
    frequency_adjustments = models.JSONField(default=dict)  # Frequency-specific adjustments
    noise_reduction = models.BooleanField(default=True)
    feedback_cancellation = models.BooleanField(default=True)
    directional_microphone = models.BooleanField(default=True)
    tinnitus_masker = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Hearing Aid Settings - {self.user.username}"