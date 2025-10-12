from rest_framework import serializers
from .models import (
    ImageAnalysis, TextRecognition, ObjectDetection, 
    SceneDescription, ColorAnalysis, VisualAssistSession
)


class ImageAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImageAnalysis
        fields = [
            'id',
            'image',
            'analysis_type',
            'result',
            'confidence_score',
            'processing_time',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class TextRecognitionSerializer(serializers.ModelSerializer):
    class Meta:
        model = TextRecognition
        fields = [
            'id',
            'image',
            'extracted_text',
            'language',
            'confidence_score',
            'bounding_boxes',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class ObjectDetectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ObjectDetection
        fields = [
            'id',
            'image',
            'detected_objects',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class SceneDescriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = SceneDescription
        fields = [
            'id',
            'image',
            'description',
            'confidence_score',
            'tags',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class ColorAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = ColorAnalysis
        fields = [
            'id',
            'image',
            'dominant_colors',
            'color_palette',
            'accessibility_rating',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class VisualAssistSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = VisualAssistSession
        fields = [
            'id',
            'session_type',
            'start_time',
            'end_time',
            'total_analyses',
            'session_data',
        ]
        read_only_fields = ['id', 'start_time']


class ImageAnalysisCreateSerializer(serializers.Serializer):
    image = serializers.ImageField()
    analysis_type = serializers.ChoiceField(choices=[
        ('object_detection', 'Object Detection'),
        ('text_recognition', 'Text Recognition'),
        ('scene_description', 'Scene Description'),
        ('color_analysis', 'Color Analysis'),
        ('face_detection', 'Face Detection'),
    ])
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return ImageAnalysis.objects.create(**validated_data)
