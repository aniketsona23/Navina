from django.urls import path
from . import views

urlpatterns = [
    # Location Data
    path('locations/', views.LocationDataListView.as_view(), name='location-data-list'),
    path('update-location/', views.update_location, name='update-location'),
    
    # Accessible Locations
    path('accessible-locations/', views.AccessibilityLocationListView.as_view(), name='accessible-location-list'),
    path('accessible-locations/<int:pk>/', views.AccessibilityLocationDetailView.as_view(), name='accessible-location-detail'),
    path('nearby-accessible/', views.nearby_accessible_locations, name='nearby-accessible-locations'),
    
    # Navigation
    path('routes/', views.NavigationRouteListView.as_view(), name='navigation-route-list'),
    path('create-route/', views.create_navigation_route, name='create-navigation-route'),
    
    # Obstacle Reports
    path('obstacles/', views.ObstacleReportListView.as_view(), name='obstacle-report-list'),
    path('report-obstacle/', views.report_obstacle, name='report-obstacle'),
    
    # Emergency
    path('emergency-contacts/', views.EmergencyContactListView.as_view(), name='emergency-contact-list'),
    path('emergency-contacts/<int:pk>/', views.EmergencyContactDetailView.as_view(), name='emergency-contact-detail'),
    path('emergency-alerts/', views.EmergencyAlertListView.as_view(), name='emergency-alert-list'),
    path('create-emergency-alert/', views.create_emergency_alert, name='create-emergency-alert'),
    
    # Sessions (commented out - view not implemented yet)
    # path('sessions/', views.MobilityAssistSessionListView.as_view(), name='mobility-session-list'),
    
    # Analytics
    path('stats/', views.mobility_assist_stats, name='mobility-assist-stats'),
    path('accessibility-rating/', views.accessibility_rating, name='accessibility-rating'),
    
    # Outdoor Navigation
    path('search-destination/', views.search_destination, name='search-destination'),
    path('get-directions/', views.get_directions, name='get-directions'),
]
