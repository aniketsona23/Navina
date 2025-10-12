from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import (
    ImageAnalysis, TextRecognition, ObjectDetection, 
    SceneDescription, ColorAnalysis, VisualAssistSession
)
from .serializers import (
    ImageAnalysisSerializer, TextRecognitionSerializer, ObjectDetectionSerializer,
    SceneDescriptionSerializer, ColorAnalysisSerializer, VisualAssistSessionSerializer,
    ImageAnalysisCreateSerializer
)


class ImageAnalysisListView(generics.ListCreateAPIView):
    """List and create image analyses"""
    serializer_class = ImageAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ImageAnalysis.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ImageAnalysisDetailView(generics.RetrieveDestroyAPIView):
    """Retrieve and delete specific image analysis"""
    serializer_class = ImageAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ImageAnalysis.objects.filter(user=self.request.user)


class TextRecognitionListView(generics.ListCreateAPIView):
    """List and create text recognition analyses"""
    serializer_class = TextRecognitionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return TextRecognition.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ObjectDetectionListView(generics.ListCreateAPIView):
    """List and create object detection analyses"""
    serializer_class = ObjectDetectionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ObjectDetection.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class SceneDescriptionListView(generics.ListCreateAPIView):
    """List and create scene description analyses"""
    serializer_class = SceneDescriptionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return SceneDescription.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ColorAnalysisListView(generics.ListCreateAPIView):
    """List and create color analysis"""
    serializer_class = ColorAnalysisSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return ColorAnalysis.objects.filter(user=self.request.user).order_by('-created_at')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class VisualAssistSessionListView(generics.ListCreateAPIView):
    """List and create visual assist sessions"""
    serializer_class = VisualAssistSessionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return VisualAssistSession.objects.filter(user=self.request.user).order_by('-start_time')
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_image(request):
    """Analyze uploaded image with AI"""
    serializer = ImageAnalysisCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        # Here you would integrate with your AI service
        # For now, we'll create a mock response
        image_analysis = serializer.save()
        
        # Mock AI analysis results
        mock_result = {
            'objects_detected': ['person', 'car', 'building'],
            'confidence_scores': [0.95, 0.87, 0.92],
            'bounding_boxes': [
                {'object': 'person', 'x': 100, 'y': 150, 'width': 80, 'height': 120},
                {'object': 'car', 'x': 200, 'y': 200, 'width': 150, 'height': 100},
                {'object': 'building', 'x': 50, 'y': 50, 'width': 200, 'height': 300}
            ]
        }
        
        image_analysis.result = mock_result
        image_analysis.confidence_score = 0.91
        image_analysis.processing_time = 2.5
        image_analysis.save()
        
        return Response(ImageAnalysisSerializer(image_analysis).data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def extract_text(request):
    """Extract text from uploaded image using OCR"""
    if 'image' not in request.FILES:
        return Response({'error': 'Image file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    image = request.FILES['image']
    language = request.data.get('language', 'en')
    
    # Mock OCR result
    mock_text = "This is a sample text extracted from the image using OCR technology."
    mock_confidence = 0.95
    mock_bounding_boxes = [
        {'text': 'This is a sample', 'x': 10, 'y': 20, 'width': 200, 'height': 30},
        {'text': 'text extracted from', 'x': 10, 'y': 60, 'width': 250, 'height': 30},
        {'text': 'the image using OCR', 'x': 10, 'y': 100, 'width': 220, 'height': 30}
    ]
    
    text_recognition = TextRecognition.objects.create(
        user=request.user,
        image=image,
        extracted_text=mock_text,
        language=language,
        confidence_score=mock_confidence,
        bounding_boxes=mock_bounding_boxes
    )
    
    return Response(TextRecognitionSerializer(text_recognition).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def describe_scene(request):
    """Generate AI description of the scene in uploaded image"""
    if 'image' not in request.FILES:
        return Response({'error': 'Image file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    image = request.FILES['image']
    
    # Mock scene description
    mock_description = "A busy city street with pedestrians walking on the sidewalk, cars driving on the road, and tall buildings in the background. The scene appears to be during daylight hours with good lighting conditions."
    mock_confidence = 0.88
    mock_tags = ['city', 'street', 'pedestrians', 'cars', 'buildings', 'daylight']
    
    scene_description = SceneDescription.objects.create(
        user=request.user,
        image=image,
        description=mock_description,
        confidence_score=mock_confidence,
        tags=mock_tags
    )
    
    return Response(SceneDescriptionSerializer(scene_description).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_colors(request):
    """Analyze colors in uploaded image for accessibility"""
    if 'image' not in request.FILES:
        return Response({'error': 'Image file required'}, status=status.HTTP_400_BAD_REQUEST)
    
    image = request.FILES['image']
    
    # Mock color analysis
    mock_dominant_colors = [
        {'color': '#FF5733', 'percentage': 35},
        {'color': '#33FF57', 'percentage': 25},
        {'color': '#3357FF', 'percentage': 20},
        {'color': '#FF33F5', 'percentage': 20}
    ]
    
    mock_color_palette = [
        '#FF5733', '#33FF57', '#3357FF', '#FF33F5', '#F5FF33',
        '#33F5FF', '#F533FF', '#57FF33', '#FF3357', '#33FF57'
    ]
    
    accessibility_rating = 'good'  # Based on color contrast analysis
    
    color_analysis = ColorAnalysis.objects.create(
        user=request.user,
        image=image,
        dominant_colors=mock_dominant_colors,
        color_palette=mock_color_palette,
        accessibility_rating=accessibility_rating
    )
    
    return Response(ColorAnalysisSerializer(color_analysis).data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def visual_assist_stats(request):
    """Get visual assistance usage statistics"""
    user = request.user
    
    stats = {
        'total_analyses': ImageAnalysis.objects.filter(user=user).count(),
        'text_extractions': TextRecognition.objects.filter(user=user).count(),
        'object_detections': ObjectDetection.objects.filter(user=user).count(),
        'scene_descriptions': SceneDescription.objects.filter(user=user).count(),
        'color_analyses': ColorAnalysis.objects.filter(user=user).count(),
        'total_sessions': VisualAssistSession.objects.filter(user=user).count(),
    }
    
    return Response(stats)