from rest_framework import serializers
from .models import (
    ActivityLog, UsageStatistics, FeatureUsage, 
    ErrorLog, UserFeedback, DataExport, PrivacySettings
)


class ActivityLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ActivityLog
        fields = [
            'id',
            'activity_type',
            'action',
            'details',
            'timestamp',
            'session_id',
        ]
        read_only_fields = ['id', 'timestamp']


class UsageStatisticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UsageStatistics
        fields = [
            'id',
            'date',
            'visual_assist_count',
            'hearing_assist_count',
            'mobility_assist_count',
            'navigation_count',
            'emergency_count',
            'total_session_time',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class FeatureUsageSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeatureUsage
        fields = [
            'id',
            'feature_name',
            'usage_count',
            'total_time',
            'last_used',
            'success_rate',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ErrorLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ErrorLog
        fields = [
            'id',
            'error_type',
            'error_message',
            'stack_trace',
            'device_info',
            'app_version',
            'severity',
            'resolved',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class UserFeedbackSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserFeedback
        fields = [
            'id',
            'feature',
            'rating',
            'comment',
            'feedback_type',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class DataExportSerializer(serializers.ModelSerializer):
    class Meta:
        model = DataExport
        fields = [
            'id',
            'export_type',
            'status',
            'file_path',
            'created_at',
            'completed_at',
        ]
        read_only_fields = ['id', 'created_at', 'completed_at']


class PrivacySettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrivacySettings
        fields = [
            'id',
            'data_collection_enabled',
            'analytics_enabled',
            'crash_reporting_enabled',
            'location_tracking_enabled',
            'usage_statistics_enabled',
            'data_retention_days',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ActivityLogCreateSerializer(serializers.Serializer):
    activity_type = serializers.ChoiceField(choices=[
        ('visual_assist', 'Visual Assistance'),
        ('hearing_assist', 'Hearing Assistance'),
        ('mobility_assist', 'Mobility Assistance'),
        ('navigation', 'Navigation'),
        ('emergency', 'Emergency'),
        ('settings_change', 'Settings Change'),
        ('login', 'Login'),
        ('logout', 'Logout'),
    ])
    action = serializers.CharField(max_length=100)
    details = serializers.JSONField(default=dict)
    session_id = serializers.CharField(max_length=100, required=False, allow_blank=True)
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return ActivityLog.objects.create(**validated_data)


class UserFeedbackCreateSerializer(serializers.Serializer):
    feature = serializers.CharField(max_length=50)
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, allow_blank=True)
    feedback_type = serializers.ChoiceField(choices=[
        ('bug_report', 'Bug Report'),
        ('feature_request', 'Feature Request'),
        ('general_feedback', 'General Feedback'),
        ('complaint', 'Complaint'),
        ('compliment', 'Compliment'),
    ])
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return UserFeedback.objects.create(**validated_data)
