from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()


class ImageAnalysis(models.Model):
    """Store image analysis results for visual assistance"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='image_analyses')
    image = models.ImageField(upload_to='visual_assist/images/')
    analysis_type = models.CharField(
        max_length=20,
        choices=[
            ('object_detection', 'Object Detection'),
            ('text_recognition', 'Text Recognition'),
            ('scene_description', 'Scene Description'),
            ('color_analysis', 'Color Analysis'),
            ('face_detection', 'Face Detection'),
        ]
    )
    result = models.JSONField()
    confidence_score = models.FloatField(null=True, blank=True)
    processing_time = models.FloatField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Image Analysis {self.id} - {self.analysis_type}"


class TextRecognition(models.Model):
    """Store OCR text recognition results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='text_recognitions')
    image = models.ImageField(upload_to='visual_assist/ocr/')
    extracted_text = models.TextField()
    language = models.CharField(max_length=10, default='en')
    confidence_score = models.FloatField()
    bounding_boxes = models.JSONField(default=list)  # Store text bounding boxes
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"OCR {self.id} - {self.extracted_text[:50]}..."


class ObjectDetection(models.Model):
    """Store object detection results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='object_detections')
    image = models.ImageField(upload_to='visual_assist/objects/')
    detected_objects = models.JSONField()  # List of detected objects with confidence scores
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Object Detection {self.id}"


class SceneDescription(models.Model):
    """Store AI-generated scene descriptions"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='scene_descriptions')
    image = models.ImageField(upload_to='visual_assist/scenes/')
    description = models.TextField()
    confidence_score = models.FloatField()
    tags = models.JSONField(default=list)  # AI-generated tags
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Scene Description {self.id}"


class ColorAnalysis(models.Model):
    """Store color analysis results"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='color_analyses')
    image = models.ImageField(upload_to='visual_assist/colors/')
    dominant_colors = models.JSONField()  # List of dominant colors with hex codes
    color_palette = models.JSONField()  # Full color palette
    accessibility_rating = models.CharField(
        max_length=20,
        choices=[
            ('excellent', 'Excellent'),
            ('good', 'Good'),
            ('fair', 'Fair'),
            ('poor', 'Poor'),
        ]
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Color Analysis {self.id}"


class VisualAssistSession(models.Model):
    """Track visual assistance sessions"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='visual_sessions')
    session_type = models.CharField(
        max_length=20,
        choices=[
            ('camera', 'Camera'),
            ('gallery', 'Gallery'),
            ('live', 'Live Feed'),
        ]
    )
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    total_analyses = models.IntegerField(default=0)
    session_data = models.JSONField(default=dict)
    
    def __str__(self):
        return f"Visual Session {self.id} - {self.user.username}"