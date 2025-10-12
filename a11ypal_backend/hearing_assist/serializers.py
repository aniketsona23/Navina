from rest_framework import serializers
from .models import (
    AudioAnalysis, SpeechToText, NoiseDetection, 
    VolumeAnalysis, FrequencyAnalysis, HearingAssistSession, HearingAidSettings
)


class AudioAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = AudioAnalysis
        fields = [
            'id',
            'audio_file',
            'analysis_type',
            'result',
            'confidence_score',
            'processing_time',
            'duration',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class SpeechToTextSerializer(serializers.ModelSerializer):
    class Meta:
        model = SpeechToText
        fields = [
            'id',
            'audio_file',
            'transcribed_text',
            'language',
            'confidence_score',
            'speaker_count',
            'timestamps',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class NoiseDetectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = NoiseDetection
        fields = [
            'id',
            'audio_file',
            'noise_level',
            'noise_type',
            'recommendations',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class VolumeAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = VolumeAnalysis
        fields = [
            'id',
            'audio_file',
            'average_volume',
            'peak_volume',
            'volume_consistency',
            'recommendations',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class FrequencyAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = FrequencyAnalysis
        fields = [
            'id',
            'audio_file',
            'dominant_frequencies',
            'frequency_spectrum',
            'hearing_aid_recommendations',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class HearingAssistSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = HearingAssistSession
        fields = [
            'id',
            'session_type',
            'start_time',
            'end_time',
            'total_analyses',
            'session_data',
        ]
        read_only_fields = ['id', 'start_time']


class HearingAidSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = HearingAidSettings
        fields = [
            'id',
            'amplification_level',
            'frequency_adjustments',
            'noise_reduction',
            'feedback_cancellation',
            'directional_microphone',
            'tinnitus_masker',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class AudioAnalysisCreateSerializer(serializers.Serializer):
    audio_file = serializers.FileField()
    analysis_type = serializers.ChoiceField(choices=[
        ('speech_to_text', 'Speech to Text'),
        ('noise_detection', 'Noise Detection'),
        ('volume_analysis', 'Volume Analysis'),
        ('frequency_analysis', 'Frequency Analysis'),
        ('emotion_detection', 'Emotion Detection'),
    ])
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return AudioAnalysis.objects.create(**validated_data)
