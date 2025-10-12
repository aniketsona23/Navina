from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class User(AbstractUser):
    """Extended User model for A11yPal app"""
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    accessibility_preferences = models.JSONField(default=dict, blank=True)
    emergency_contact_name = models.CharField(max_length=100, blank=True, null=True)
    emergency_contact_phone = models.CharField(max_length=15, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Fix reverse accessor clashes
    groups = models.ManyToManyField(
        'auth.Group',
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='a11ypal_user_set',
        related_query_name='a11ypal_user',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='a11ypal_user_set',
        related_query_name='a11ypal_user',
    )
    
    def __str__(self):
        return self.username


class UserProfile(models.Model):
    """User profile with accessibility settings"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    visual_impairment_level = models.CharField(
        max_length=20,
        choices=[
            ('none', 'None'),
            ('mild', 'Mild'),
            ('moderate', 'Moderate'),
            ('severe', 'Severe'),
            ('blind', 'Blind'),
        ],
        default='none'
    )
    hearing_impairment_level = models.CharField(
        max_length=20,
        choices=[
            ('none', 'None'),
            ('mild', 'Mild'),
            ('moderate', 'Moderate'),
            ('severe', 'Severe'),
            ('deaf', 'Deaf'),
        ],
        default='none'
    )
    mobility_impairment_level = models.CharField(
        max_length=20,
        choices=[
            ('none', 'None'),
            ('mild', 'Mild'),
            ('moderate', 'Moderate'),
            ('severe', 'Severe'),
            ('wheelchair', 'Wheelchair User'),
        ],
        default='none'
    )
    preferred_font_size = models.CharField(
        max_length=15,
        choices=[
            ('small', 'Small'),
            ('medium', 'Medium'),
            ('large', 'Large'),
            ('extra_large', 'Extra Large'),
        ],
        default='medium'
    )
    high_contrast_mode = models.BooleanField(default=False)
    screen_reader_enabled = models.BooleanField(default=False)
    voice_commands_enabled = models.BooleanField(default=False)
    haptic_feedback_enabled = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"