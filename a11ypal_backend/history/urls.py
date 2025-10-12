from django.urls import path
from . import views

urlpatterns = [
    # Activity Logs
    path('activities/', views.ActivityLogListView.as_view(), name='activity-log-list'),
    path('log-activity/', views.log_activity, name='log-activity'),
    
    # Usage Statistics
    path('usage-stats/', views.UsageStatisticsListView.as_view(), name='usage-statistics-list'),
    path('feature-usage/', views.FeatureUsageListView.as_view(), name='feature-usage-list'),
    
    # Error Logs
    path('errors/', views.ErrorLogListView.as_view(), name='error-log-list'),
    
    # User Feedback
    path('feedback/', views.UserFeedbackListView.as_view(), name='user-feedback-list'),
    path('submit-feedback/', views.submit_feedback, name='submit-feedback'),
    
    # Data Export
    path('exports/', views.DataExportListView.as_view(), name='data-export-list'),
    path('request-export/', views.request_data_export, name='request-data-export'),
    
    # Privacy Settings
    path('privacy-settings/', views.PrivacySettingsView.as_view(), name='privacy-settings'),
    
    # Dashboards and Analytics
    path('dashboard/', views.usage_dashboard, name='usage-dashboard'),
    path('feature-analytics/', views.feature_analytics, name='feature-analytics'),
    path('error-analytics/', views.error_analytics, name='error-analytics'),
    path('privacy-dashboard/', views.privacy_dashboard, name='privacy-dashboard'),
]
