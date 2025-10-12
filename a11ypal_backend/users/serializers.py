from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import UserProfile

User = get_user_model()


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'visual_impairment_level',
            'hearing_impairment_level',
            'mobility_impairment_level',
            'preferred_font_size',
            'high_contrast_mode',
            'screen_reader_enabled',
            'voice_commands_enabled',
            'haptic_feedback_enabled',
        ]


class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'phone_number',
            'date_of_birth',
            'accessibility_preferences',
            'emergency_contact_name',
            'emergency_contact_phone',
            'profile',
            'date_joined',
            'last_login',
        ]
        read_only_fields = ['id', 'date_joined', 'last_login']


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = [
            'username',
            'email',
            'password',
            'password_confirm',
            'first_name',
            'last_name',
            'phone_number',
            'date_of_birth',
        ]
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Passwords don't match")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'first_name',
            'last_name',
            'email',
            'phone_number',
            'date_of_birth',
            'accessibility_preferences',
            'emergency_contact_name',
            'emergency_contact_phone',
        ]


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'visual_impairment_level',
            'hearing_impairment_level',
            'mobility_impairment_level',
            'preferred_font_size',
            'high_contrast_mode',
            'screen_reader_enabled',
            'voice_commands_enabled',
            'haptic_feedback_enabled',
        ]
