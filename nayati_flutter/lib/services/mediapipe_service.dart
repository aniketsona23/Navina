import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

/// MediaPipe-like holistic landmark detection service
/// This simulates MediaPipe holistic detection for ASL recognition
/// Based on the trained model that expects 150 keypoints (30 frames × 5 landmarks per frame)
class MediaPipeService {
  static const int NUM_HAND_LANDMARKS = 21;
  static const int NUM_POSE_LANDMARKS = 33;
  static const int NUM_FACE_LANDMARKS = 468;
  static const int NUM_COORDS = 3; // x, y, z coordinates
  static const int TOTAL_LANDMARKS = 150; // Total keypoints the model expects
  
  /// Detect holistic landmarks from image data (150 keypoints total)
  static Future<List<List<double>>?> detectHandLandmarks(Uint8List imageData) async {
    try {
      // Decode image
      final image = img.decodeImage(imageData);
      if (image == null) return null;
      
      // Simulate holistic landmark detection for ASL
      // The model expects 150 keypoints representing holistic pose, hands, and face
      final landmarks = _simulateHolisticLandmarks(image.width, image.height);
      
      return landmarks;
    } catch (e) {
      print('MediaPipe detection error: $e');
      return null;
    }
  }
  
  /// Simulate holistic landmark detection for ASL recognition
  /// Generates 150 keypoints as expected by the trained model
  static List<List<double>> _simulateHolisticLandmarks(int width, int height) {
    final Random random = Random();
    final List<List<double>> landmarks = [];
    
    // Simulate holistic detection (pose, hands, face)
    // The model expects 150 keypoints total
    
    // Generate pose landmarks (33 points)
    final double centerX = width * 0.5;
    final double centerY = height * 0.4; // Slightly higher for pose
    
    for (int i = 0; i < NUM_POSE_LANDMARKS; i++) {
      final double x = centerX + (random.nextDouble() - 0.5) * width * 0.3;
      final double y = centerY + (random.nextDouble() - 0.5) * height * 0.4;
      final double z = random.nextDouble() * 0.1 - 0.05;
      landmarks.add([x / width, y / height, z]);
    }
    
    // Generate left hand landmarks (21 points)
    final double leftHandX = centerX - width * 0.2;
    final double leftHandY = centerY + height * 0.1;
    
    for (int i = 0; i < NUM_HAND_LANDMARKS; i++) {
      final double x = leftHandX + (random.nextDouble() - 0.5) * width * 0.1;
      final double y = leftHandY + (random.nextDouble() - 0.5) * height * 0.1;
      final double z = random.nextDouble() * 0.1 - 0.05;
      landmarks.add([x / width, y / height, z]);
    }
    
    // Generate right hand landmarks (21 points)
    final double rightHandX = centerX + width * 0.2;
    final double rightHandY = centerY + height * 0.1;
    
    for (int i = 0; i < NUM_HAND_LANDMARKS; i++) {
      final double x = rightHandX + (random.nextDouble() - 0.5) * width * 0.1;
      final double y = rightHandY + (random.nextDouble() - 0.5) * height * 0.1;
      final double z = random.nextDouble() * 0.1 - 0.05;
      landmarks.add([x / width, y / height, z]);
    }
    
    // Generate face landmarks (75 points - subset of 468)
    final double faceX = centerX;
    final double faceY = centerY - height * 0.1;
    
    for (int i = 0; i < 75; i++) {
      final double x = faceX + (random.nextDouble() - 0.5) * width * 0.15;
      final double y = faceY + (random.nextDouble() - 0.5) * height * 0.15;
      final double z = random.nextDouble() * 0.1 - 0.05;
      landmarks.add([x / width, y / height, z]);
    }
    
    return landmarks;
  }
  
  /// Convert landmarks to feature vector for LSTM model
  static List<double> landmarksToFeatureVector(List<List<double>> landmarks) {
    final List<double> features = [];
    
    for (final landmark in landmarks) {
      features.addAll(landmark); // Add x, y, z coordinates
    }
    
    return features;
  }
  
  /// Normalize landmarks relative to wrist position
  static List<List<double>> normalizeLandmarks(List<List<double>> landmarks) {
    if (landmarks.isEmpty) return landmarks;
    
    final List<double> wrist = landmarks.last; // Wrist is the last landmark
    final List<List<double>> normalized = [];
    
    for (final landmark in landmarks) {
      normalized.add([
        landmark[0] - wrist[0],
        landmark[1] - wrist[1],
        landmark[2] - wrist[2],
      ]);
    }
    
    return normalized;
  }
  
  /// Calculate distance between two landmarks
  static double calculateDistance(List<double> landmark1, List<double> landmark2) {
    final double dx = landmark1[0] - landmark2[0];
    final double dy = landmark1[1] - landmark2[1];
    final double dz = landmark1[2] - landmark2[2];
    
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
  
  /// Extract hand gesture features for ASL recognition
  static List<double> extractGestureFeatures(List<List<double>> landmarks) {
    if (landmarks.length != NUM_HAND_LANDMARKS) return [];
    
    final List<double> features = [];
    
    // Add normalized landmark coordinates
    final normalized = normalizeLandmarks(landmarks);
    for (final landmark in normalized) {
      features.addAll(landmark);
    }
    
    // Add finger tip distances from wrist
    final List<double> tipDistances = [];
    final List<double> wrist = landmarks.last;
    
    // Thumb tip (landmark 4)
    tipDistances.add(calculateDistance(landmarks[4], wrist));
    // Index tip (landmark 8)
    tipDistances.add(calculateDistance(landmarks[8], wrist));
    // Middle tip (landmark 12)
    tipDistances.add(calculateDistance(landmarks[12], wrist));
    // Ring tip (landmark 16)
    tipDistances.add(calculateDistance(landmarks[16], wrist));
    // Pinky tip (landmark 20)
    tipDistances.add(calculateDistance(landmarks[20], wrist));
    
    features.addAll(tipDistances);
    
    return features;
  }
}
