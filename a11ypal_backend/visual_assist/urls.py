from django.urls import path
from . import views

urlpatterns = [
    # Image Analysis
    path('analyses/', views.ImageAnalysisListView.as_view(), name='image-analysis-list'),
    path('analyses/<int:pk>/', views.ImageAnalysisDetailView.as_view(), name='image-analysis-detail'),
    path('analyze/', views.analyze_image, name='analyze-image'),
    
    # Text Recognition
    path('text-recognition/', views.TextRecognitionListView.as_view(), name='text-recognition-list'),
    path('extract-text/', views.extract_text, name='extract-text'),
    
    # Object Detection
    path('object-detection/', views.ObjectDetectionListView.as_view(), name='object-detection-list'),
    path('detect-objects/', views.detect_objects_realtime, name='detect-objects-realtime'),
    path('detect-test/', views.detect_objects_test, name='detect-objects-test'),
    
    # Scene Description
    path('scene-description/', views.SceneDescriptionListView.as_view(), name='scene-description-list'),
    path('describe-scene/', views.describe_scene, name='describe-scene'),
    
    # Color Analysis
    path('color-analysis/', views.ColorAnalysisListView.as_view(), name='color-analysis-list'),
    path('analyze-colors/', views.analyze_colors, name='analyze-colors'),
    
    # Sessions
    path('sessions/', views.VisualAssistSessionListView.as_view(), name='visual-session-list'),
    
    # Statistics
    path('stats/', views.visual_assist_stats, name='visual-assist-stats'),
    
    # Test endpoint (no authentication required)
    path('test/', views.test_api, name='test-api'),
]
