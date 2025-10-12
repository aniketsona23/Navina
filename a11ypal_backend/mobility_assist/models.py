from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()


class LocationData(models.Model):
    """Store user location data for mobility assistance"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='location_data')
    latitude = models.DecimalField(max_digits=10, decimal_places=8)
    longitude = models.DecimalField(max_digits=11, decimal_places=8)
    altitude = models.FloatField(null=True, blank=True)
    accuracy = models.FloatField(null=True, blank=True)  # GPS accuracy in meters
    speed = models.FloatField(null=True, blank=True)  # Speed in m/s
    heading = models.FloatField(null=True, blank=True)  # Direction in degrees
    timestamp = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Location {self.id} - {self.user.username}"


class AccessibilityLocation(models.Model):
    """Store accessibility information for specific locations"""
    name = models.CharField(max_length=200)
    latitude = models.DecimalField(max_digits=10, decimal_places=8)
    longitude = models.DecimalField(max_digits=11, decimal_places=8)
    address = models.TextField()
    location_type = models.CharField(
        max_length=20,
        choices=[
            ('restaurant', 'Restaurant'),
            ('hospital', 'Hospital'),
            ('bank', 'Bank'),
            ('shopping', 'Shopping Center'),
            ('transport', 'Transportation'),
            ('park', 'Park'),
            ('other', 'Other'),
        ]
    )
    wheelchair_accessible = models.BooleanField(default=False)
    has_ramp = models.BooleanField(default=False)
    has_elevator = models.BooleanField(default=False)
    has_accessible_parking = models.BooleanField(default=False)
    has_accessible_restroom = models.BooleanField(default=False)
    has_braille_signage = models.BooleanField(default=False)
    has_audio_announcements = models.BooleanField(default=False)
    has_tactile_paving = models.BooleanField(default=False)
    accessibility_rating = models.IntegerField(
        choices=[(i, i) for i in range(1, 6)],
        default=3
    )
    notes = models.TextField(blank=True)
    verified = models.BooleanField(default=False)
    verified_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='verified_locations')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.name} - {self.location_type}"


class NavigationRoute(models.Model):
    """Store navigation routes with accessibility considerations"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='navigation_routes')
    start_latitude = models.DecimalField(max_digits=10, decimal_places=8)
    start_longitude = models.DecimalField(max_digits=11, decimal_places=8)
    end_latitude = models.DecimalField(max_digits=10, decimal_places=8)
    end_longitude = models.DecimalField(max_digits=11, decimal_places=8)
    route_data = models.JSONField()  # Full route data from navigation API
    accessibility_preferences = models.JSONField(default=dict)
    estimated_duration = models.IntegerField()  # Duration in minutes
    distance = models.FloatField()  # Distance in meters
    accessibility_score = models.IntegerField(
        choices=[(i, i) for i in range(1, 6)],
        default=3
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Route {self.id} - {self.user.username}"


class ObstacleReport(models.Model):
    """Store user-reported obstacles"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='obstacle_reports')
    latitude = models.DecimalField(max_digits=10, decimal_places=8)
    longitude = models.DecimalField(max_digits=11, decimal_places=8)
    obstacle_type = models.CharField(
        max_length=20,
        choices=[
            ('construction', 'Construction'),
            ('pothole', 'Pothole'),
            ('sidewalk_blocked', 'Sidewalk Blocked'),
            ('no_curb_cut', 'No Curb Cut'),
            ('broken_elevator', 'Broken Elevator'),
            ('other', 'Other'),
        ]
    )
    description = models.TextField()
    severity = models.CharField(
        max_length=10,
        choices=[
            ('low', 'Low'),
            ('medium', 'Medium'),
            ('high', 'High'),
            ('critical', 'Critical'),
        ]
    )
    image = models.ImageField(upload_to='mobility_assist/obstacles/', null=True, blank=True)
    status = models.CharField(
        max_length=20,
        choices=[
            ('reported', 'Reported'),
            ('verified', 'Verified'),
            ('in_progress', 'In Progress'),
            ('resolved', 'Resolved'),
            ('dismissed', 'Dismissed'),
        ],
        default='reported'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Obstacle Report {self.id} - {self.obstacle_type}"


class MobilityAssistSession(models.Model):
    """Track mobility assistance sessions"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='mobility_sessions')
    session_type = models.CharField(
        max_length=20,
        choices=[
            ('navigation', 'Navigation'),
            ('location_search', 'Location Search'),
            ('obstacle_reporting', 'Obstacle Reporting'),
            ('accessibility_check', 'Accessibility Check'),
        ]
    )
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    session_data = models.JSONField(default=dict)
    
    def __str__(self):
        return f"Mobility Session {self.id} - {self.user.username}"


class EmergencyContact(models.Model):
    """Store emergency contacts for users"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emergency_contacts')
    name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=15)
    relationship = models.CharField(max_length=50)
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Emergency Contact - {self.name} for {self.user.username}"


class EmergencyAlert(models.Model):
    """Store emergency alerts and responses"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='emergency_alerts')
    alert_type = models.CharField(
        max_length=20,
        choices=[
            ('medical', 'Medical Emergency'),
            ('safety', 'Safety Alert'),
            ('fall', 'Fall Detection'),
            ('panic', 'Panic Button'),
            ('other', 'Other'),
        ]
    )
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    message = models.TextField()
    status = models.CharField(
        max_length=20,
        choices=[
            ('active', 'Active'),
            ('acknowledged', 'Acknowledged'),
            ('resolved', 'Resolved'),
            ('cancelled', 'Cancelled'),
        ],
        default='active'
    )
    emergency_contacts_notified = models.BooleanField(default=False)
    emergency_services_notified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"Emergency Alert {self.id} - {self.alert_type}"