from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()


class ActivityLog(models.Model):
    """Store user activity logs"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='activity_logs')
    activity_type = models.CharField(
        max_length=30,
        choices=[
            ('visual_assist', 'Visual Assistance'),
            ('hearing_assist', 'Hearing Assistance'),
            ('mobility_assist', 'Mobility Assistance'),
            ('navigation', 'Navigation'),
            ('emergency', 'Emergency'),
            ('settings_change', 'Settings Change'),
            ('login', 'Login'),
            ('logout', 'Logout'),
        ]
    )
    action = models.CharField(max_length=100)
    details = models.JSONField(default=dict)
    timestamp = models.DateTimeField(auto_now_add=True)
    session_id = models.CharField(max_length=100, blank=True)
    
    def __str__(self):
        return f"{self.user.username} - {self.activity_type} - {self.action}"


class UsageStatistics(models.Model):
    """Store aggregated usage statistics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='usage_statistics')
    date = models.DateField()
    visual_assist_count = models.IntegerField(default=0)
    hearing_assist_count = models.IntegerField(default=0)
    mobility_assist_count = models.IntegerField(default=0)
    navigation_count = models.IntegerField(default=0)
    emergency_count = models.IntegerField(default=0)
    total_session_time = models.IntegerField(default=0)  # Total time in minutes
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user', 'date']
    
    def __str__(self):
        return f"Usage Stats - {self.user.username} - {self.date}"


class FeatureUsage(models.Model):
    """Store detailed feature usage data"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='feature_usage')
    feature_name = models.CharField(max_length=50)
    usage_count = models.IntegerField(default=0)
    total_time = models.IntegerField(default=0)  # Time in seconds
    last_used = models.DateTimeField(null=True, blank=True)
    success_rate = models.FloatField(default=0.0)  # Success rate as percentage
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user', 'feature_name']
    
    def __str__(self):
        return f"Feature Usage - {self.user.username} - {self.feature_name}"


class ErrorLog(models.Model):
    """Store application errors and issues"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='error_logs', null=True, blank=True)
    error_type = models.CharField(max_length=50)
    error_message = models.TextField()
    stack_trace = models.TextField(blank=True)
    device_info = models.JSONField(default=dict)
    app_version = models.CharField(max_length=20, blank=True)
    severity = models.CharField(
        max_length=10,
        choices=[
            ('low', 'Low'),
            ('medium', 'Medium'),
            ('high', 'High'),
            ('critical', 'Critical'),
        ],
        default='medium'
    )
    resolved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Error Log {self.id} - {self.error_type}"


class UserFeedback(models.Model):
    """Store user feedback and ratings"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='feedback')
    feature = models.CharField(max_length=50)
    rating = models.IntegerField(
        choices=[(i, i) for i in range(1, 6)],
        default=3
    )
    comment = models.TextField(blank=True)
    feedback_type = models.CharField(
        max_length=20,
        choices=[
            ('bug_report', 'Bug Report'),
            ('feature_request', 'Feature Request'),
            ('general_feedback', 'General Feedback'),
            ('complaint', 'Complaint'),
            ('compliment', 'Compliment'),
        ]
    )
    status = models.CharField(
        max_length=20,
        choices=[
            ('new', 'New'),
            ('in_review', 'In Review'),
            ('acknowledged', 'Acknowledged'),
            ('resolved', 'Resolved'),
            ('dismissed', 'Dismissed'),
        ],
        default='new'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Feedback {self.id} - {self.user.username} - {self.feature}"


class DataExport(models.Model):
    """Store data export requests"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='data_exports')
    export_type = models.CharField(
        max_length=20,
        choices=[
            ('all_data', 'All Data'),
            ('activity_logs', 'Activity Logs'),
            ('usage_statistics', 'Usage Statistics'),
            ('personal_data', 'Personal Data'),
        ]
    )
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('processing', 'Processing'),
            ('completed', 'Completed'),
            ('failed', 'Failed'),
        ],
        default='pending'
    )
    file_path = models.CharField(max_length=500, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"Data Export {self.id} - {self.user.username} - {self.export_type}"


class PrivacySettings(models.Model):
    """Store user privacy settings"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='privacy_settings')
    data_collection_enabled = models.BooleanField(default=True)
    analytics_enabled = models.BooleanField(default=True)
    crash_reporting_enabled = models.BooleanField(default=True)
    location_tracking_enabled = models.BooleanField(default=True)
    usage_statistics_enabled = models.BooleanField(default=True)
    data_retention_days = models.IntegerField(default=365)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Privacy Settings - {self.user.username}"