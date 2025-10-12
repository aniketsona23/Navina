from django.urls import path
from . import views

urlpatterns = [
    # Audio Analysis
    path('analyses/', views.AudioAnalysisListView.as_view(), name='audio-analysis-list'),
    path('analyze/', views.AudioAnalysisListView.as_view(), name='analyze-audio'),
    
    # Speech to Text
    path('speech-to-text/', views.SpeechToTextListView.as_view(), name='speech-to-text-list'),
    path('transcribe/', views.transcribe_audio, name='transcribe-audio'),
    
    # Noise Detection
    path('noise-detection/', views.NoiseDetectionListView.as_view(), name='noise-detection-list'),
    path('detect-noise/', views.detect_noise, name='detect-noise'),
    
    # Volume Analysis
    path('volume-analysis/', views.VolumeAnalysisListView.as_view(), name='volume-analysis-list'),
    path('analyze-volume/', views.analyze_volume, name='analyze-volume'),
    
    # Frequency Analysis
    path('frequency-analysis/', views.FrequencyAnalysisListView.as_view(), name='frequency-analysis-list'),
    path('analyze-frequency/', views.analyze_frequency, name='analyze-frequency'),
    
    # Sessions
    path('sessions/', views.HearingAssistSessionListView.as_view(), name='hearing-session-list'),
    
    # Hearing Aid Settings
    path('hearing-aid-settings/', views.HearingAidSettingsView.as_view(), name='hearing-aid-settings'),
    path('update-hearing-aid-settings/', views.update_hearing_aid_settings, name='update-hearing-aid-settings'),
    
    # Statistics
    path('stats/', views.hearing_assist_stats, name='hearing-assist-stats'),
]
