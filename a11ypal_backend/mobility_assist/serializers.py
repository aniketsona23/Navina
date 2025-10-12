from rest_framework import serializers
from .models import (
    LocationData, AccessibilityLocation, NavigationRoute, 
    ObstacleReport, MobilityAssistSession, EmergencyContact, EmergencyAlert
)


class LocationDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = LocationData
        fields = [
            'id',
            'latitude',
            'longitude',
            'altitude',
            'accuracy',
            'speed',
            'heading',
            'timestamp',
        ]
        read_only_fields = ['id', 'timestamp']


class AccessibilityLocationSerializer(serializers.ModelSerializer):
    verified_by_username = serializers.CharField(source='verified_by.username', read_only=True)
    
    class Meta:
        model = AccessibilityLocation
        fields = [
            'id',
            'name',
            'latitude',
            'longitude',
            'address',
            'location_type',
            'wheelchair_accessible',
            'has_ramp',
            'has_elevator',
            'has_accessible_parking',
            'has_accessible_restroom',
            'has_braille_signage',
            'has_audio_announcements',
            'has_tactile_paving',
            'accessibility_rating',
            'notes',
            'verified',
            'verified_by_username',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class NavigationRouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = NavigationRoute
        fields = [
            'id',
            'start_latitude',
            'start_longitude',
            'end_latitude',
            'end_longitude',
            'route_data',
            'accessibility_preferences',
            'estimated_duration',
            'distance',
            'accessibility_score',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class ObstacleReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = ObstacleReport
        fields = [
            'id',
            'latitude',
            'longitude',
            'obstacle_type',
            'description',
            'severity',
            'image',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class MobilityAssistSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MobilityAssistSession
        fields = [
            'id',
            'session_type',
            'start_time',
            'end_time',
            'session_data',
        ]
        read_only_fields = ['id', 'start_time']


class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = [
            'id',
            'name',
            'phone_number',
            'relationship',
            'is_primary',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class EmergencyAlertSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyAlert
        fields = [
            'id',
            'alert_type',
            'latitude',
            'longitude',
            'message',
            'status',
            'emergency_contacts_notified',
            'emergency_services_notified',
            'created_at',
            'resolved_at',
        ]
        read_only_fields = ['id', 'created_at']


class LocationDataCreateSerializer(serializers.Serializer):
    latitude = serializers.DecimalField(max_digits=10, decimal_places=8)
    longitude = serializers.DecimalField(max_digits=11, decimal_places=8)
    altitude = serializers.FloatField(required=False, allow_null=True)
    accuracy = serializers.FloatField(required=False, allow_null=True)
    speed = serializers.FloatField(required=False, allow_null=True)
    heading = serializers.FloatField(required=False, allow_null=True)
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return LocationData.objects.create(**validated_data)


class ObstacleReportCreateSerializer(serializers.Serializer):
    latitude = serializers.DecimalField(max_digits=10, decimal_places=8)
    longitude = serializers.DecimalField(max_digits=11, decimal_places=8)
    obstacle_type = serializers.ChoiceField(choices=[
        ('construction', 'Construction'),
        ('pothole', 'Pothole'),
        ('sidewalk_blocked', 'Sidewalk Blocked'),
        ('no_curb_cut', 'No Curb Cut'),
        ('broken_elevator', 'Broken Elevator'),
        ('other', 'Other'),
    ])
    description = serializers.CharField()
    severity = serializers.ChoiceField(choices=[
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ])
    image = serializers.ImageField(required=False, allow_null=True)
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return ObstacleReport.objects.create(**validated_data)
