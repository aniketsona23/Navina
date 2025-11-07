import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'mediapipe_hands_service.dart';
import 'asl_gesture_classifier.dart';

/// Comprehensive ASL Recognition Service
/// Integrates MediaPipe Hands detection with ASL gesture classification
/// Implements the complete sign language to text conversion pipeline
class ComprehensiveASLService {
  static bool _isInitialized = false;
  static String? _lastError;
  static ASLClassificationResult? _lastResult;
  
  // Recognition settings
  static const double MIN_CONFIDENCE_THRESHOLD = 0.6;
  static const double HIGH_CONFIDENCE_THRESHOLD = 0.8;
  static const int MAX_RETRY_ATTEMPTS = 3;
  
  // Recognition history for context
  static final List<ASLClassificationResult> _recognitionHistory = [];
  static const int MAX_HISTORY_SIZE = 10;
  
  // Real-time processing settings
  static bool _isRealTimeMode = false;
  static StreamController<ASLClassificationResult>? _realTimeController;
  static Timer? _processingTimer;
  
  /// Initialize the comprehensive ASL recognition service
  static Future<bool> initialize() async {
    try {
      print('🚀 Initializing Comprehensive ASL Recognition Service...');
      
      _lastError = null;
      
      // Initialize MediaPipe Hands Service
      print('📦 Initializing MediaPipe Hands Service...');
      final handsInitialized = await MediaPipeHandsService.initialize();
      if (!handsInitialized) {
        _lastError = 'Failed to initialize MediaPipe Hands Service';
        print('❌ $lastError');
        return false;
      }
      
      // Initialize ASL Gesture Classifier
      print('🧠 Initializing ASL Gesture Classifier...');
      final classifierInitialized = await ASLGestureClassifier.initialize();
      if (!classifierInitialized) {
        _lastError = 'Failed to initialize ASL Gesture Classifier';
        print('❌ $lastError');
        return false;
      }
      
      // Initialize real-time processing controller
      _realTimeController = StreamController<ASLClassificationResult>.broadcast();
      
      _isInitialized = true;
      print('✅ Comprehensive ASL Recognition Service initialized successfully');
      print('🎯 Ready for real-time sign language recognition');
      
      return true;
    } catch (e) {
      _lastError = e.toString();
      print('❌ Failed to initialize Comprehensive ASL Service: $e');
      _isInitialized = false;
      return false;
    }
  }
  
  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Get last error
  static String? get lastError => _lastError;
  
  /// Get last recognition result
  static ASLClassificationResult? get lastResult => _lastResult;
  
  /// Get recognition history
  static List<ASLClassificationResult> get recognitionHistory => List.from(_recognitionHistory);
  
  /// Recognize ASL from image data
  static Future<ASLClassificationResult> recognizeASL(Uint8List imageData) async {
    try {
      if (!_isInitialized) {
        return ASLClassificationResult(
          gesture: 'ERROR',
          confidence: 0.0,
          category: ASLCategory.unknown,
          description: 'Service not initialized',
        );
      }
      
      print('🔍 Starting comprehensive ASL recognition...');
      
      // Step 1: Detect hand landmarks using MediaPipe
      final handLandmarks = await MediaPipeHandsService.detectHandLandmarks(imageData);
      
      if (handLandmarks == null || handLandmarks.isEmpty) {
        return ASLClassificationResult(
          gesture: 'NOTHING',
          confidence: 0.0,
          category: ASLCategory.nothing,
          description: 'No hand landmarks detected',
        );
      }
      
      print('📍 Detected ${handLandmarks.length} hand landmarks');
      
      // Step 2: Classify ASL gesture
      final classificationResult = await ASLGestureClassifier.classifyGesture(handLandmarks);
      
      // Step 3: Validate and enhance result
      final enhancedResult = _enhanceClassificationResult(classificationResult, handLandmarks);
      
      // Step 4: Update recognition history
      _updateRecognitionHistory(enhancedResult);
      
      // Step 5: Store as last result
      _lastResult = enhancedResult;
      
      print('✅ ASL Recognition completed: ${enhancedResult.gesture} (${(enhancedResult.confidence * 100).toStringAsFixed(1)}%)');
      
      return enhancedResult;
    } catch (e) {
      print('❌ ASL recognition error: $e');
      _lastError = e.toString();
      
      return ASLClassificationResult(
        gesture: 'ERROR',
        confidence: 0.0,
        category: ASLCategory.unknown,
        description: 'Recognition error: $e',
      );
    }
  }
  
  /// Enhance classification result with additional validation
  static ASLClassificationResult _enhanceClassificationResult(
    ASLClassificationResult result,
    List<HandLandmark> landmarks,
  ) {
    // Apply confidence boost based on landmark quality
    double enhancedConfidence = result.confidence;
    
    // Boost confidence for high-quality landmarks
    final landmarkConfidence = MediaPipeHandsService.lastConfidence;
    if (landmarkConfidence > 0.8) {
      enhancedConfidence = min(1.0, enhancedConfidence * 1.1);
    }
    
    // Boost confidence for consistent results
    if (_recognitionHistory.isNotEmpty) {
      final lastResult = _recognitionHistory.last;
      if (lastResult.gesture == result.gesture) {
        enhancedConfidence = min(1.0, enhancedConfidence * 1.05);
      }
    }
    
    // Apply context-based confidence adjustment
    enhancedConfidence = _applyContextualConfidence(enhancedConfidence, result);
    
    return ASLClassificationResult(
      gesture: result.gesture,
      confidence: enhancedConfidence.clamp(0.0, 1.0),
      category: result.category,
      description: result.description,
    );
  }
  
  /// Apply contextual confidence adjustments
  static double _applyContextualConfidence(double confidence, ASLClassificationResult result) {
    // Boost confidence for common gestures
    const commonGestures = ['HELLO', 'THANK YOU', 'YES', 'NO', 'A', 'B', 'C'];
    if (commonGestures.contains(result.gesture)) {
      confidence *= 1.05;
    }
    
    // Reduce confidence for rare gestures
    const rareGestures = ['X', 'Z', 'Q'];
    if (rareGestures.contains(result.gesture)) {
      confidence *= 0.95;
    }
    
    return confidence;
  }
  
  /// Update recognition history
  static void _updateRecognitionHistory(ASLClassificationResult result) {
    _recognitionHistory.add(result);
    
    // Keep only recent results
    if (_recognitionHistory.length > MAX_HISTORY_SIZE) {
      _recognitionHistory.removeAt(0);
    }
  }
  
  /// Start real-time ASL recognition
  static Stream<ASLClassificationResult> startRealTimeRecognition({
    required Future<Uint8List> Function() imageProvider,
    Duration interval = const Duration(milliseconds: 500),
  }) {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    
    _isRealTimeMode = true;
    _processingTimer?.cancel();
    
    _processingTimer = Timer.periodic(interval, (timer) async {
      try {
        final imageData = await imageProvider();
        final result = await recognizeASL(imageData);
        
        if (result.confidence >= MIN_CONFIDENCE_THRESHOLD) {
          _realTimeController?.add(result);
        }
      } catch (e) {
        print('❌ Real-time recognition error: $e');
      }
    });
    
    return _realTimeController!.stream;
  }
  
  /// Stop real-time ASL recognition
  static void stopRealTimeRecognition() {
    _isRealTimeMode = false;
    _processingTimer?.cancel();
    _processingTimer = null;
    print('⏹️ Real-time ASL recognition stopped');
  }
  
  /// Get real-time recognition status
  static bool get isRealTimeActive => _isRealTimeMode;
  
  /// Recognize ASL sequence (for words/phrases)
  static Future<List<ASLClassificationResult>> recognizeASLSequence(
    List<Uint8List> imageSequence,
  ) async {
    final results = <ASLClassificationResult>[];
    
    for (final imageData in imageSequence) {
      final result = await recognizeASL(imageData);
      results.add(result);
      
      // Add small delay between frames
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }
  
  /// Get most likely gesture from sequence
  static String getMostLikelyGesture(List<ASLClassificationResult> sequence) {
    if (sequence.isEmpty) return 'NOTHING';
    
    // Count gesture occurrences
    final gestureCounts = <String, int>{};
    final gestureConfidences = <String, List<double>>{};
    
    for (final result in sequence) {
      if (result.confidence >= MIN_CONFIDENCE_THRESHOLD) {
        gestureCounts[result.gesture] = (gestureCounts[result.gesture] ?? 0) + 1;
        gestureConfidences[result.gesture] = gestureConfidences[result.gesture] ?? [];
        gestureConfidences[result.gesture]!.add(result.confidence);
      }
    }
    
    if (gestureCounts.isEmpty) return 'NOTHING';
    
    // Find gesture with highest count and confidence
    String bestGesture = 'NOTHING';
    double bestScore = 0.0;
    
    for (final entry in gestureCounts.entries) {
      final gesture = entry.key;
      final count = entry.value;
      final confidences = gestureConfidences[gesture]!;
      final avgConfidence = confidences.reduce((a, b) => a + b) / confidences.length;
      
      // Score based on count and confidence
      final score = count * avgConfidence;
      
      if (score > bestScore) {
        bestScore = score;
        bestGesture = gesture;
      }
    }
    
    return bestGesture;
  }
  
  /// Get gesture statistics
  static Map<String, dynamic> getGestureStatistics() {
    if (_recognitionHistory.isEmpty) {
      return {
        'total_recognitions': 0,
        'most_common_gesture': 'NONE',
        'average_confidence': 0.0,
        'recognition_rate': 0.0,
      };
    }
    
    final gestureCounts = <String, int>{};
    double totalConfidence = 0.0;
    int successfulRecognitions = 0;
    
    for (final result in _recognitionHistory) {
      if (result.gesture != 'NOTHING' && result.gesture != 'ERROR') {
        gestureCounts[result.gesture] = (gestureCounts[result.gesture] ?? 0) + 1;
        totalConfidence += result.confidence;
        successfulRecognitions++;
      }
    }
    
    final mostCommonGesture = gestureCounts.isNotEmpty
        ? gestureCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'NONE';
    
    final averageConfidence = successfulRecognitions > 0
        ? totalConfidence / successfulRecognitions
        : 0.0;
    
    final recognitionRate = _recognitionHistory.isNotEmpty
        ? successfulRecognitions / _recognitionHistory.length
        : 0.0;
    
    return {
      'total_recognitions': _recognitionHistory.length,
      'successful_recognitions': successfulRecognitions,
      'most_common_gesture': mostCommonGesture,
      'average_confidence': averageConfidence,
      'recognition_rate': recognitionRate,
      'gesture_counts': gestureCounts,
    };
  }
  
  /// Clear recognition history
  static void clearHistory() {
    _recognitionHistory.clear();
    _lastResult = null;
    print('🗑️ Recognition history cleared');
  }
  
  /// Get available ASL gestures
  static List<String> getAvailableGestures() {
    return ASLGestureClassifier.getAvailableGestures();
  }
  
  /// Get gesture description
  static String getGestureDescription(String gesture) {
    return ASLGestureClassifier.getGestureDescription(gesture);
  }
  
  /// Validate hand gesture quality
  static bool validateHandGesture(List<HandLandmark> landmarks) {
    if (landmarks.isEmpty) return false;
    
    // Check if we have enough landmarks
    if (landmarks.length < 5) return false;
    
    // Check landmark confidence
    final avgConfidence = landmarks.map((l) => l.confidence).reduce((a, b) => a + b) / landmarks.length;
    if (avgConfidence < 0.5) return false;
    
    // Check if landmarks are within reasonable bounds
    for (final landmark in landmarks) {
      if (landmark.x < 0 || landmark.x > 1 || landmark.y < 0 || landmark.y > 1) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get confidence score for last recognition
  static double getLastConfidence() {
    return _lastResult?.confidence ?? 0.0;
  }
  
  /// Dispose resources
  static Future<void> dispose() async {
    try {
      stopRealTimeRecognition();
      await _realTimeController?.close();
      await MediaPipeHandsService.dispose();
      ASLGestureClassifier.dispose();
      
      _isInitialized = false;
      _recognitionHistory.clear();
      _lastResult = null;
      _lastError = null;
      
      print('✅ Comprehensive ASL Service disposed successfully');
    } catch (e) {
      print('❌ Error disposing Comprehensive ASL Service: $e');
    }
  }
}
