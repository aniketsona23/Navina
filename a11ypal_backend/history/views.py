from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Count, Sum, Avg
from django.utils import timezone
from datetime import timedelta
from .models import (
    ActivityLog, UsageStatistics, FeatureUsage, 
    ErrorLog, UserFeedback, DataExport, PrivacySettings
)
from .serializers import (
    ActivityLogSerializer, UsageStatisticsSerializer, FeatureUsageSerializer,
    ErrorLogSerializer, UserFeedbackSerializer, DataExportSerializer,
    PrivacySettingsSerializer, ActivityLogCreateSerializer, UserFeedbackCreateSerializer
)


class ActivityLogListView(generics.ListCreateAPIView):
    """List and create activity logs"""
    serializer_class = ActivityLogSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ActivityLog.objects.filter(user=self.request.user).order_by('-timestamp')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class UsageStatisticsListView(generics.ListAPIView):
    """List usage statistics"""
    serializer_class = UsageStatisticsSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return UsageStatistics.objects.filter(user=self.request.user).order_by('-date')


class FeatureUsageListView(generics.ListAPIView):
    """List feature usage data"""
    serializer_class = FeatureUsageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return FeatureUsage.objects.filter(user=self.request.user).order_by('-last_used')


class ErrorLogListView(generics.ListCreateAPIView):
    """List and create error logs"""
    serializer_class = ErrorLogSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ErrorLog.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class UserFeedbackListView(generics.ListCreateAPIView):
    """List and create user feedback"""
    serializer_class = UserFeedbackSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return UserFeedback.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class DataExportListView(generics.ListCreateAPIView):
    """List and create data export requests"""
    serializer_class = DataExportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return DataExport.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class PrivacySettingsView(generics.RetrieveUpdateAPIView):
    """Get and update privacy settings"""
    serializer_class = PrivacySettingsSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        settings, created = PrivacySettings.objects.get_or_create(user=self.request.user)
        return settings


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def log_activity(request):
    """Log user activity"""
    serializer = ActivityLogCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        activity_log = serializer.save()
        return Response(ActivityLogSerializer(activity_log).data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_feedback(request):
    """Submit user feedback"""
    serializer = UserFeedbackCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        feedback = serializer.save()
        return Response(UserFeedbackSerializer(feedback).data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def usage_dashboard(request):
    """Get comprehensive usage dashboard data"""
    user = request.user
    
    # Get date range (default to last 30 days)
    days = int(request.query_params.get('days', 30))
    end_date = timezone.now().date()
    start_date = end_date - timedelta(days=days)
    
    # Get usage statistics for the period
    usage_stats = UsageStatistics.objects.filter(
        user=user,
        date__range=[start_date, end_date]
    ).order_by('date')
    
    # Get feature usage data
    feature_usage = FeatureUsage.objects.filter(user=user).order_by('-usage_count')
    
    # Get recent activity
    recent_activity = ActivityLog.objects.filter(
        user=user
    ).order_by('-timestamp')[:20]
    
    # Calculate totals
    total_usage = usage_stats.aggregate(
        total_visual=Sum('visual_assist_count'),
        total_hearing=Sum('hearing_assist_count'),
        total_mobility=Sum('mobility_assist_count'),
        total_navigation=Sum('navigation_count'),
        total_emergency=Sum('emergency_count'),
        total_time=Sum('total_session_time')
    )
    
    # Get most used features
    most_used_features = feature_usage[:5]
    
    # Get error count
    error_count = ErrorLog.objects.filter(
        user=user,
        created_at__date__range=[start_date, end_date]
    ).count()
    
    dashboard_data = {
        'period': {
            'start_date': start_date,
            'end_date': end_date,
            'days': days
        },
        'usage_totals': total_usage,
        'usage_statistics': UsageStatisticsSerializer(usage_stats, many=True).data,
        'feature_usage': FeatureUsageSerializer(feature_usage, many=True).data,
        'most_used_features': FeatureUsageSerializer(most_used_features, many=True).data,
        'recent_activity': ActivityLogSerializer(recent_activity, many=True).data,
        'error_count': error_count,
        'success_rate': calculate_success_rate(user, start_date, end_date)
    }
    
    return Response(dashboard_data)


def calculate_success_rate(user, start_date, end_date):
    """Calculate user's success rate for the period"""
    total_activities = ActivityLog.objects.filter(
        user=user,
        timestamp__date__range=[start_date, end_date]
    ).count()
    
    if total_activities == 0:
        return 0.0
    
    successful_activities = ActivityLog.objects.filter(
        user=user,
        timestamp__date__range=[start_date, end_date],
        details__contains={'success': True}
    ).count()
    
    return round((successful_activities / total_activities) * 100, 2)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def feature_analytics(request):
    """Get detailed feature analytics"""
    user = request.user
    feature_name = request.query_params.get('feature')
    
    if feature_name:
        feature_usage = get_object_or_404(FeatureUsage, user=user, feature_name=feature_name)
        serializer = FeatureUsageSerializer(feature_usage)
        return Response(serializer.data)
    
    # Get all features with analytics
    features = FeatureUsage.objects.filter(user=user).order_by('-usage_count')
    
    analytics_data = {
        'total_features': features.count(),
        'most_used': FeatureUsageSerializer(features[:5], many=True).data,
        'least_used': FeatureUsageSerializer(features.reverse()[:5], many=True).data,
        'average_usage': features.aggregate(avg_usage=Avg('usage_count'))['avg_usage'] or 0,
        'total_time': features.aggregate(total_time=Sum('total_time'))['total_time'] or 0
    }
    
    return Response(analytics_data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_data_export(request):
    """Request data export"""
    export_type = request.data.get('export_type', 'all_data')
    
    if export_type not in ['all_data', 'activity_logs', 'usage_statistics', 'personal_data']:
        return Response({'error': 'Invalid export type'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Create export request
    data_export = DataExport.objects.create(
        user=request.user,
        export_type=export_type,
        status='pending'
    )
    
    # In a real app, you would:
    # 1. Queue the export job
    # 2. Generate the export file
    # 3. Send notification when ready
    
    return Response(DataExportSerializer(data_export).data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def error_analytics(request):
    """Get error analytics and insights"""
    user = request.user
    days = int(request.query_params.get('days', 30))
    end_date = timezone.now().date()
    start_date = end_date - timedelta(days=days)
    
    errors = ErrorLog.objects.filter(
        user=user,
        created_at__date__range=[start_date, end_date]
    )
    
    error_analytics = {
        'total_errors': errors.count(),
        'error_types': errors.values('error_type').annotate(count=Count('id')).order_by('-count'),
        'severity_breakdown': errors.values('severity').annotate(count=Count('id')).order_by('-count'),
        'resolved_errors': errors.filter(resolved=True).count(),
        'unresolved_errors': errors.filter(resolved=False).count(),
        'recent_errors': ErrorLogSerializer(errors.order_by('-created_at')[:10], many=True).data
    }
    
    return Response(error_analytics)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def privacy_dashboard(request):
    """Get privacy settings and data control dashboard"""
    user = request.user
    privacy_settings = PrivacySettings.objects.get_or_create(user=user)[0]
    
    # Get data retention info
    data_counts = {
        'activity_logs': ActivityLog.objects.filter(user=user).count(),
        'usage_statistics': UsageStatistics.objects.filter(user=user).count(),
        'feature_usage': FeatureUsage.objects.filter(user=user).count(),
        'error_logs': ErrorLog.objects.filter(user=user).count(),
        'feedback': UserFeedback.objects.filter(user=user).count()
    }
    
    privacy_dashboard = {
        'settings': PrivacySettingsSerializer(privacy_settings).data,
        'data_counts': data_counts,
        'data_retention_days': privacy_settings.data_retention_days,
        'export_requests': DataExport.objects.filter(user=user).count()
    }
    
    return Response(privacy_dashboard)