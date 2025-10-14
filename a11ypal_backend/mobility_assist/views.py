from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db.models import Q
from .models import (
    LocationData, AccessibilityLocation, NavigationRoute, 
    ObstacleReport, MobilityAssistSession, EmergencyContact, EmergencyAlert
)
from .serializers import (
    LocationDataSerializer, AccessibilityLocationSerializer, NavigationRouteSerializer,
    ObstacleReportSerializer, MobilityAssistSessionSerializer, EmergencyContactSerializer,
    EmergencyAlertSerializer, LocationDataCreateSerializer, ObstacleReportCreateSerializer
)


class LocationDataListView(generics.ListCreateAPIView):
    """List and create location data"""
    serializer_class = LocationDataSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return LocationData.objects.filter(user=self.request.user).order_by('-timestamp')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class AccessibilityLocationListView(generics.ListAPIView):
    """List accessible locations"""
    serializer_class = AccessibilityLocationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = AccessibilityLocation.objects.all()
        
        # Filter by location type if provided
        location_type = self.request.query_params.get('type', None)
        if location_type:
            queryset = queryset.filter(location_type=location_type)
        
        # Filter by wheelchair accessibility if provided
        wheelchair_accessible = self.request.query_params.get('wheelchair_accessible', None)
        if wheelchair_accessible is not None:
            queryset = queryset.filter(wheelchair_accessible=wheelchair_accessible.lower() == 'true')
        
        # Filter by accessibility rating if provided
        min_rating = self.request.query_params.get('min_rating', None)
        if min_rating:
            queryset = queryset.filter(accessibility_rating__gte=min_rating)
        
        return queryset.order_by('-accessibility_rating')


class AccessibilityLocationDetailView(generics.RetrieveUpdateAPIView):
    """Retrieve and update specific accessible location"""
    serializer_class = AccessibilityLocationSerializer
    permission_classes = [IsAuthenticated]
    queryset = AccessibilityLocation.objects.all()


class NavigationRouteListView(generics.ListCreateAPIView):
    """List and create navigation routes"""
    serializer_class = NavigationRouteSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return NavigationRoute.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ObstacleReportListView(generics.ListCreateAPIView):
    """List and create obstacle reports"""
    serializer_class = ObstacleReportSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ObstacleReport.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class EmergencyContactListView(generics.ListCreateAPIView):
    """List and create emergency contacts"""
    serializer_class = EmergencyContactSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user).order_by('-is_primary', 'name')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class EmergencyContactDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Retrieve, update, and delete emergency contacts"""
    serializer_class = EmergencyContactSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user)


class EmergencyAlertListView(generics.ListCreateAPIView):
    """List and create emergency alerts"""
    serializer_class = EmergencyAlertSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return EmergencyAlert.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_location(request):
    """Update user's current location"""
    serializer = LocationDataCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        location_data = serializer.save()
        return Response(LocationDataSerializer(location_data).data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def nearby_accessible_locations(request):
    """Find nearby accessible locations"""
    latitude = request.query_params.get('latitude')
    longitude = request.query_params.get('longitude')
    radius = float(request.query_params.get('radius', 1000))  # Default 1km radius
    
    if not latitude or not longitude:
        return Response({'error': 'Latitude and longitude required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Mock nearby locations (in a real app, you'd use geospatial queries)
    nearby_locations = AccessibilityLocation.objects.filter(
        wheelchair_accessible=True,
        accessibility_rating__gte=4
    )[:10]  # Limit to 10 results
    
    serializer = AccessibilityLocationSerializer(nearby_locations, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_navigation_route(request):
    """Create navigation route with accessibility preferences"""
    start_lat = request.data.get('start_latitude')
    start_lng = request.data.get('start_longitude')
    end_lat = request.data.get('end_latitude')
    end_lng = request.data.get('end_longitude')
    preferences = request.data.get('accessibility_preferences', {})
    route_type = request.data.get('route_type', 'indoor')  # indoor or outdoor
    
    if not all([start_lat, start_lng, end_lat, end_lng]):
        return Response({'error': 'Start and end coordinates required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Enhanced route data for outdoor navigation
    if route_type == 'outdoor':
        # More detailed outdoor route data
        mock_route_data = {
            'waypoints': [
                {'lat': float(start_lat), 'lng': float(start_lng)},
                {'lat': float(end_lat), 'lng': float(end_lng)}
            ],
            'instructions': [
                'Head north on Main Street for 0.3 miles',
                'Turn right onto Accessible Avenue',
                'Continue straight for 0.5 miles',
                'Turn left onto Accessible Lane',
                'Arrive at destination on your right'
            ],
            'accessibility_features': [
                'Wheelchair accessible sidewalks',
                'Audio announcements available at intersections',
                'Tactile paving at crosswalks',
                'Accessible pedestrian signals',
                'Wide sidewalks (minimum 5 feet)'
            ],
            'hazards': [
                {'type': 'construction', 'description': 'Construction zone ahead', 'location': {'lat': 0, 'lng': 0}},
                {'type': 'steep_incline', 'description': 'Steep incline on Accessible Avenue', 'location': {'lat': 0, 'lng': 0}}
            ],
            'alternative_routes': [
                {
                    'name': 'Wheelchair Accessible Route',
                    'distance': 1.2,
                    'duration': 18,
                    'accessibility_score': 5
                },
                {
                    'name': 'Fastest Route',
                    'distance': 0.8,
                    'duration': 12,
                    'accessibility_score': 3
                }
            ]
        }
        estimated_duration = 18  # minutes
        distance = 1200  # meters
        accessibility_score = 4
    else:
        # Indoor route data
        mock_route_data = {
            'waypoints': [
                {'lat': float(start_lat), 'lng': float(start_lng)},
                {'lat': float(end_lat), 'lng': float(end_lng)}
            ],
            'instructions': [
                'Head north towards the main entrance',
                'Use the accessible ramp on your left',
                'Enter through the automatic doors',
                'Turn right at the information desk'
            ],
            'accessibility_features': [
                'Wheelchair accessible path',
                'Audio announcements available',
                'Tactile paving present'
            ]
        }
        estimated_duration = 15  # minutes
        distance = 800  # meters
        accessibility_score = 4
    
    route = NavigationRoute.objects.create(
        user=request.user,
        start_latitude=start_lat,
        start_longitude=start_lng,
        end_latitude=end_lat,
        end_longitude=end_lng,
        route_data=mock_route_data,
        accessibility_preferences=preferences,
        estimated_duration=estimated_duration,
        distance=distance,
        accessibility_score=accessibility_score
    )
    
    return Response(NavigationRouteSerializer(route).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def report_obstacle(request):
    """Report an accessibility obstacle"""
    serializer = ObstacleReportCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        obstacle_report = serializer.save()
        return Response(ObstacleReportSerializer(obstacle_report).data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_emergency_alert(request):
    """Create emergency alert"""
    alert_type = request.data.get('alert_type')
    message = request.data.get('message')
    latitude = request.data.get('latitude')
    longitude = request.data.get('longitude')
    
    if not alert_type or not message:
        return Response({'error': 'Alert type and message required'}, status=status.HTTP_400_BAD_REQUEST)
    
    emergency_alert = EmergencyAlert.objects.create(
        user=request.user,
        alert_type=alert_type,
        message=message,
        latitude=latitude,
        longitude=longitude
    )
    
    # In a real app, you would:
    # 1. Send notifications to emergency contacts
    # 2. Contact emergency services
    # 3. Send location data
    
    return Response(EmergencyAlertSerializer(emergency_alert).data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def mobility_assist_stats(request):
    """Get mobility assistance usage statistics"""
    user = request.user
    
    stats = {
        'total_locations': LocationData.objects.filter(user=user).count(),
        'navigation_routes': NavigationRoute.objects.filter(user=user).count(),
        'obstacle_reports': ObstacleReport.objects.filter(user=user).count(),
        'emergency_alerts': EmergencyAlert.objects.filter(user=user).count(),
        'emergency_contacts': EmergencyContact.objects.filter(user=user).count(),
        'total_sessions': MobilityAssistSession.objects.filter(user=user).count(),
    }
    
    return Response(stats)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def accessibility_rating(request):
    """Get accessibility rating for a location"""
    latitude = request.query_params.get('latitude')
    longitude = request.query_params.get('longitude')
    
    if not latitude or not longitude:
        return Response({'error': 'Latitude and longitude required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Mock accessibility rating calculation
    rating_data = {
        'overall_rating': 4.2,
        'wheelchair_accessibility': 4.5,
        'visual_accessibility': 3.8,
        'hearing_accessibility': 4.0,
        'features': [
            'Wheelchair accessible entrance',
            'Elevator available',
            'Accessible restrooms',
            'Audio announcements',
            'Braille signage'
        ],
        'improvements': [
            'Add tactile paving',
            'Improve lighting',
            'Add more audio cues'
        ]
    }
    
    return Response(rating_data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def search_destination(request):
    """Search for outdoor destinations"""
    query = request.data.get('query')
    latitude = request.data.get('latitude')
    longitude = request.data.get('longitude')
    radius = float(request.data.get('radius', 5000))  # Default 5km radius
    
    if not query:
        return Response({'error': 'Search query required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Mock search results - in a real app, you'd use Google Places API or similar
    mock_results = [
        {
            'place_id': '1',
            'name': f'{query} - Main Location',
            'address': '123 Main Street, City, State',
            'latitude': float(latitude) + 0.01 if latitude else 37.7749,
            'longitude': float(longitude) + 0.01 if longitude else -122.4194,
            'rating': 4.5,
            'accessibility_rating': 4.2,
            'types': ['establishment', 'point_of_interest'],
            'accessibility_features': [
                'Wheelchair accessible entrance',
                'Accessible parking',
                'Audio announcements'
            ]
        },
        {
            'place_id': '2',
            'name': f'{query} - Branch Location',
            'address': '456 Oak Avenue, City, State',
            'latitude': float(latitude) + 0.02 if latitude else 37.7849,
            'longitude': float(longitude) + 0.02 if longitude else -122.4094,
            'rating': 4.2,
            'accessibility_rating': 3.8,
            'types': ['establishment', 'point_of_interest'],
            'accessibility_features': [
                'Wheelchair accessible entrance',
                'Elevator available'
            ]
        }
    ]
    
    return Response({
        'results': mock_results,
        'status': 'OK'
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_directions(request):
    """Get detailed directions for outdoor navigation"""
    origin_lat = request.data.get('origin_latitude')
    origin_lng = request.data.get('origin_longitude')
    destination_lat = request.data.get('destination_latitude')
    destination_lng = request.data.get('destination_longitude')
    mode = request.data.get('mode', 'walking')  # walking, driving, transit
    accessibility_preferences = request.data.get('accessibility_preferences', {})
    
    if not all([origin_lat, origin_lng, destination_lat, destination_lng]):
        return Response({'error': 'Origin and destination coordinates required'}, status=status.HTTP_400_BAD_REQUEST)
    
    # Mock directions data - in a real app, you'd use Google Directions API
    directions_data = {
        'routes': [
            {
                'route_id': '1',
                'summary': 'Wheelchair Accessible Route',
                'legs': [
                    {
                        'distance': {'text': '1.2 mi', 'value': 1931},
                        'duration': {'text': '18 mins', 'value': 1080},
                        'steps': [
                            {
                                'instruction': 'Head north on Main Street',
                                'distance': {'text': '0.3 mi', 'value': 483},
                                'duration': {'text': '5 mins', 'value': 300},
                                'start_location': {'lat': float(origin_lat), 'lng': float(origin_lng)},
                                'end_location': {'lat': float(origin_lat) + 0.005, 'lng': float(origin_lng)},
                                'accessibility_features': ['Wide sidewalk', 'Tactile paving'],
                                'hazards': []
                            },
                            {
                                'instruction': 'Turn right onto Accessible Avenue',
                                'distance': {'text': '0.5 mi', 'value': 805},
                                'duration': {'text': '8 mins', 'value': 480},
                                'start_location': {'lat': float(origin_lat) + 0.005, 'lng': float(origin_lng)},
                                'end_location': {'lat': float(origin_lat) + 0.008, 'lng': float(origin_lng) + 0.008},
                                'accessibility_features': ['Accessible pedestrian signal', 'Audio announcements'],
                                'hazards': []
                            },
                            {
                                'instruction': 'Turn left onto Accessible Lane',
                                'distance': {'text': '0.4 mi', 'value': 643},
                                'duration': {'text': '5 mins', 'value': 300},
                                'start_location': {'lat': float(origin_lat) + 0.008, 'lng': float(origin_lng) + 0.008},
                                'end_location': {'lat': float(destination_lat), 'lng': float(destination_lng)},
                                'accessibility_features': ['Wheelchair accessible path', 'Elevated crosswalk'],
                                'hazards': []
                            }
                        ]
                    }
                ],
                'accessibility_score': 4.5,
                'accessibility_features': [
                    'Wheelchair accessible sidewalks',
                    'Audio announcements at intersections',
                    'Tactile paving at crosswalks',
                    'Accessible pedestrian signals'
                ]
            }
        ],
        'status': 'OK'
    }
    
    return Response(directions_data)