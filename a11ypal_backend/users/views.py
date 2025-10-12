from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.contrib.auth import get_user_model
from .models import UserProfile
from .serializers import (
    UserSerializer, UserRegistrationSerializer, UserUpdateSerializer,
    UserProfileSerializer, UserProfileUpdateSerializer
)

User = get_user_model()


class UserRegistrationView(generics.CreateAPIView):
    """User registration endpoint"""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Create user profile
            UserProfile.objects.create(user=user)
            # Create auth token
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """User login endpoint"""
    username = request.data.get('username')
    password = request.data.get('password')
    
    if username and password:
        user = authenticate(username=username, password=password)
        if user:
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'user': UserSerializer(user).data,
                'token': token.key
            })
        else:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    else:
        return Response({'error': 'Username and password required'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """User logout endpoint"""
    try:
        request.user.auth_token.delete()
        return Response({'message': 'Successfully logged out'})
    except:
        return Response({'error': 'Error logging out'}, status=status.HTTP_400_BAD_REQUEST)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Get and update user profile"""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        return self.request.user


class UserProfileSettingsView(generics.RetrieveUpdateAPIView):
    """Get and update user accessibility settings"""
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        profile, created = UserProfile.objects.get_or_create(user=self.request.user)
        return profile


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_dashboard(request):
    """Get user dashboard data"""
    user = request.user
    profile = user.profile
    
    # Get recent activity (you can implement this based on your needs)
    recent_activity = []
    
    dashboard_data = {
        'user': UserSerializer(user).data,
        'profile': UserProfileSerializer(profile).data,
        'recent_activity': recent_activity,
        'accessibility_score': calculate_accessibility_score(profile),
    }
    
    return Response(dashboard_data)


def calculate_accessibility_score(profile):
    """Calculate user's accessibility score based on their settings"""
    score = 0
    max_score = 100
    
    # Visual accessibility
    if profile.visual_impairment_level == 'none':
        score += 20
    elif profile.visual_impairment_level == 'mild':
        score += 15
    elif profile.visual_impairment_level == 'moderate':
        score += 10
    elif profile.visual_impairment_level == 'severe':
        score += 5
    
    # Hearing accessibility
    if profile.hearing_impairment_level == 'none':
        score += 20
    elif profile.hearing_impairment_level == 'mild':
        score += 15
    elif profile.hearing_impairment_level == 'moderate':
        score += 10
    elif profile.hearing_impairment_level == 'severe':
        score += 5
    
    # Mobility accessibility
    if profile.mobility_impairment_level == 'none':
        score += 20
    elif profile.mobility_impairment_level == 'mild':
        score += 15
    elif profile.mobility_impairment_level == 'moderate':
        score += 10
    elif profile.mobility_impairment_level == 'severe':
        score += 5
    
    # Assistive features
    if profile.screen_reader_enabled:
        score += 10
    if profile.voice_commands_enabled:
        score += 10
    if profile.haptic_feedback_enabled:
        score += 10
    if profile.high_contrast_mode:
        score += 10
    
    return min(score, max_score)