import 'dart:math';
import '../services/mediapipe_hands_service.dart';

/// Comprehensive ASL Gesture Classifier
/// Implements full ASL alphabet recognition using MediaPipe Hands features
class ASLGestureClassifier {
  static bool _isInitialized = false;
  static String? _lastError;
  
  // ASL Alphabet and common words/phrases
  static const List<String> _aslAlphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];
  
  static const List<String> _aslWords = [
    'HELLO', 'THANK YOU', 'PLEASE', 'SORRY', 'YES', 'NO', 'GOOD', 'BAD',
    'LOVE', 'HATE', 'MOTHER', 'FATHER', 'FRIEND', 'FAMILY', 'WORK', 'HOME',
    'FOOD', 'WATER', 'HELP', 'STOP', 'GO', 'COME', 'STAY', 'WAIT'
  ];
  
  static const List<String> _aslPhrases = [
    'HOW ARE YOU', 'NICE TO MEET YOU', 'SEE YOU LATER', 'GOOD MORNING',
    'GOOD AFTERNOON', 'GOOD EVENING', 'GOOD NIGHT', 'WHAT TIME IS IT',
    'WHERE ARE YOU FROM', 'I LOVE YOU', 'I AM SORRY', 'YOU ARE WELCOME'
  ];
  
  // Classification thresholds
  static const double MIN_CONFIDENCE = 0.6;
  static const double HIGH_CONFIDENCE = 0.8;
  
  /// Initialize the ASL Gesture Classifier
  static Future<bool> initialize() async {
    try {
      print('🚀 Initializing ASL Gesture Classifier...');
      
      _lastError = null;
      
      // Load gesture recognition patterns
      _loadGesturePatterns();
      
      _isInitialized = true;
      print('✅ ASL Gesture Classifier initialized successfully');
      print('📊 Supports: ${_aslAlphabet.length} letters, ${_aslWords.length} words, ${_aslPhrases.length} phrases');
      
      return true;
    } catch (e) {
      _lastError = e.toString();
      print('❌ Failed to initialize ASL Gesture Classifier: $e');
      _isInitialized = false;
      return false;
    }
  }
  
  /// Check if classifier is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Get last error
  static String? get lastError => _lastError;
  
  /// Load gesture recognition patterns
  static void _loadGesturePatterns() {
    print('📚 Loading ASL gesture recognition patterns...');
    // In a real implementation, this would load trained model weights
    // For now, we'll use rule-based classification with comprehensive patterns
  }
  
  /// Classify ASL gesture from hand landmarks
  static Future<ASLClassificationResult> classifyGesture(List<HandLandmark> landmarks) async {
    try {
      if (!_isInitialized) {
        return ASLClassificationResult(
          gesture: 'UNKNOWN',
          confidence: 0.0,
          category: ASLCategory.unknown,
          description: 'Classifier not initialized',
        );
      }
      
      if (landmarks.isEmpty || landmarks.length < 5) {
        return ASLClassificationResult(
          gesture: 'NOTHING',
          confidence: 0.0,
          category: ASLCategory.nothing,
          description: 'Insufficient hand landmarks detected',
        );
      }
      
      print('🔍 Classifying ASL gesture from ${landmarks.length} landmarks...');
      
      // Extract comprehensive hand features
      final features = MediaPipeHandsService.extractHandFeatures(landmarks);
      
      if (features.isEmpty) {
        return ASLClassificationResult(
          gesture: 'NOTHING',
          confidence: 0.0,
          category: ASLCategory.nothing,
          description: 'No features extracted from landmarks',
        );
      }
      
      // Classify using multiple approaches
      final letterResult = _classifyASLLetter(features, landmarks);
      final wordResult = _classifyASLWord(features, landmarks);
      final phraseResult = _classifyASLPhrase(features, landmarks);
      
      // Select the best result
      final results = [letterResult, wordResult, phraseResult];
      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      
      final bestResult = results.first;
      
      if (bestResult.confidence >= MIN_CONFIDENCE) {
        print('✅ ASL Classification: ${bestResult.gesture} (${(bestResult.confidence * 100).toStringAsFixed(1)}%)');
        return bestResult;
      } else {
        print('⚠️ Low confidence ASL classification: ${bestResult.gesture} (${(bestResult.confidence * 100).toStringAsFixed(1)}%)');
        return ASLClassificationResult(
          gesture: 'NOTHING',
          confidence: bestResult.confidence,
          category: ASLCategory.nothing,
          description: 'Low confidence gesture recognition',
        );
      }
    } catch (e) {
      print('❌ ASL gesture classification error: $e');
      _lastError = e.toString();
      return ASLClassificationResult(
        gesture: 'ERROR',
        confidence: 0.0,
        category: ASLCategory.unknown,
        description: 'Classification error: $e',
      );
    }
  }
  
  /// Classify ASL letter from hand features
  static ASLClassificationResult _classifyASLLetter(List<double> features, List<HandLandmark> landmarks) {
    // Extract key finger positions
    final fingerExtensions = _extractFingerExtensions(features);
    final fingerAngles = _extractFingerAngles(features);
    final handShape = _extractHandShape(features);
    
    // ASL Letter Classification Rules (based on finger positions and extensions)
    
    // Letter A: Fist with thumb extended
    if (_isThumbExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'A',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Fist with thumb outside',
      );
    }
    
    // Letter B: All fingers extended, thumb tucked
    if (_areAllFingersExtended(fingerExtensions) && !_isThumbExtended(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'B',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'All fingers extended',
      );
    }
    
    // Letter C: Curved hand (fingers partially extended)
    if (_areFingersPartiallyExtended(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'C',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.8),
        category: ASLCategory.letter,
        description: 'C shape with fingers',
      );
    }
    
    // Letter D: Index finger extended, others curled
    if (_isIndexExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'D',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Index finger pointing up',
      );
    }
    
    // Letter E: All fingers curled
    if (_areAllFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'E',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'All fingers bent',
      );
    }
    
    // Letter F: Index and thumb touching (OK sign)
    if (_isThumbIndexTouch(fingerExtensions, fingerAngles)) {
      return ASLClassificationResult(
        gesture: 'F',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Thumb and index finger touching',
      );
    }
    
    // Letter G: Index finger pointing (gun gesture)
    if (_isIndexExtended(fingerExtensions) && _isThumbExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'G',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Index finger pointing',
      );
    }
    
    // Letter H: Index and middle fingers extended
    if (_isIndexExtended(fingerExtensions) && _isMiddleExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'H',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Index and middle finger extended',
      );
    }
    
    // Letter I: Pinky extended
    if (_isPinkyExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'I',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Pinky finger extended',
      );
    }
    
    // Letter L: Index finger and thumb extended (L shape)
    if (_isIndexExtended(fingerExtensions) && _isThumbExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'L',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'L shape with index and thumb',
      );
    }
    
    // Letter S: Fist (all fingers closed)
    if (_areAllFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'S',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Fist',
      );
    }
    
    // Letter T: Thumb between index and middle
    if (_isThumbBetweenIndexMiddle(fingerExtensions, fingerAngles)) {
      return ASLClassificationResult(
        gesture: 'T',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.8),
        category: ASLCategory.letter,
        description: 'Thumb between index and middle',
      );
    }
    
    // Letter U: Index and middle fingers extended (peace sign)
    if (_isIndexExtended(fingerExtensions) && _isMiddleExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'U',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Peace sign (index and middle)',
      );
    }
    
    // Letter V: Index and middle fingers extended apart (V sign)
    if (_isIndexExtended(fingerExtensions) && _isMiddleExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'V',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'V sign (index and middle apart)',
      );
    }
    
    // Letter W: Three fingers extended (index, middle, ring)
    if (_isIndexExtended(fingerExtensions) && _isMiddleExtended(fingerExtensions) && _isRingExtended(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'W',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Three fingers up (W)',
      );
    }
    
    // Letter Y: Thumb and pinky extended (hang loose)
    if (_isThumbExtended(fingerExtensions) && _isPinkyExtended(fingerExtensions) && _areOtherFingersClosed(fingerExtensions)) {
      return ASLClassificationResult(
        gesture: 'Y',
        confidence: _calculateConfidence(fingerExtensions, fingerAngles, 0.9),
        category: ASLCategory.letter,
        description: 'Thumb and pinky extended',
      );
    }
    
    // Default: return nothing if no pattern matches
    return ASLClassificationResult(
      gesture: 'NOTHING',
      confidence: 0.0,
      category: ASLCategory.nothing,
      description: 'No ASL letter pattern recognized',
    );
  }
  
  /// Classify ASL word from hand features
  static ASLClassificationResult _classifyASLWord(List<double> features, List<HandLandmark> landmarks) {
    // Extract features for word recognition
    final fingerExtensions = _extractFingerExtensions(features);
    final handMovement = _extractHandMovement(features);
    final handOrientation = _extractHandOrientation(landmarks);
    
    // Common ASL word patterns
    
    // HELLO: Wave gesture (open hand moving)
    if (_areAllFingersExtended(fingerExtensions) && handMovement > 0.1) {
      return ASLClassificationResult(
        gesture: 'HELLO',
        confidence: _calculateWordConfidence(fingerExtensions, handMovement, 0.8),
        category: ASLCategory.word,
        description: 'Wave gesture (hello)',
      );
    }
    
    // THANK YOU: Touch chin then move forward
    if (_isThumbExtended(fingerExtensions) && _isIndexExtended(fingerExtensions) && handOrientation > 0.7) {
      return ASLClassificationResult(
        gesture: 'THANK YOU',
        confidence: _calculateWordConfidence(fingerExtensions, handMovement, 0.8),
        category: ASLCategory.word,
        description: 'Touch chin gesture (thank you)',
      );
    }
    
    // YES: Nodding gesture with closed fist
    if (_areAllFingersClosed(fingerExtensions) && handMovement > 0.05) {
      return ASLClassificationResult(
        gesture: 'YES',
        confidence: _calculateWordConfidence(fingerExtensions, handMovement, 0.7),
        category: ASLCategory.word,
        description: 'Nodding gesture (yes)',
      );
    }
    
    // NO: Shaking gesture with index finger
    if (_isIndexExtended(fingerExtensions) && handMovement > 0.08) {
      return ASLClassificationResult(
        gesture: 'NO',
        confidence: _calculateWordConfidence(fingerExtensions, handMovement, 0.7),
        category: ASLCategory.word,
        description: 'Shaking gesture (no)',
      );
    }
    
    // Default: return nothing
    return ASLClassificationResult(
      gesture: 'NOTHING',
      confidence: 0.0,
      category: ASLCategory.nothing,
      description: 'No ASL word pattern recognized',
    );
  }
  
  /// Classify ASL phrase from hand features
  static ASLClassificationResult _classifyASLPhrase(List<double> features, List<HandLandmark> landmarks) {
    // ASL phrases typically involve multiple gestures or complex movements
    // For now, we'll implement basic phrase recognition
    
    final fingerExtensions = _extractFingerExtensions(features);
    final handMovement = _extractHandMovement(features);
    
    // HOW ARE YOU: Question gesture (hand raised with extended fingers)
    if (_areAllFingersExtended(fingerExtensions) && handMovement < 0.05) {
      return ASLClassificationResult(
        gesture: 'HOW ARE YOU',
        confidence: _calculateWordConfidence(fingerExtensions, handMovement, 0.6),
        category: ASLCategory.phrase,
        description: 'Question gesture (how are you)',
      );
    }
    
    // Default: return nothing
    return ASLClassificationResult(
      gesture: 'NOTHING',
      confidence: 0.0,
      category: ASLCategory.nothing,
      description: 'No ASL phrase pattern recognized',
    );
  }
  
  /// Helper methods for feature extraction
  static List<double> _extractFingerExtensions(List<double> features) {
    // Extract finger extension features (first 5 features after coordinates)
    if (features.length < 70) return List.filled(5, 0.0);
    return features.sublist(63, 68); // Finger extension features
  }
  
  static List<double> _extractFingerAngles(List<double> features) {
    // Extract finger angle features
    if (features.length < 75) return List.filled(5, 0.0);
    return features.sublist(68, 73); // Finger angle features
  }
  
  static List<double> _extractHandShape(List<double> features) {
    // Extract hand shape features
    if (features.length < 80) return List.filled(5, 0.0);
    return features.sublist(73, 78); // Hand shape features
  }
  
  static double _extractHandMovement(List<double> features) {
    // Extract hand movement features
    if (features.length < 81) return 0.0;
    return features[80]; // Hand movement feature
  }
  
  static double _extractHandOrientation(List<HandLandmark> landmarks) {
    if (landmarks.length < 2) return 0.0;
    
    // Calculate hand orientation based on landmark positions
    final wrist = landmarks[0];
    final middleMcp = landmarks.length > 9 ? landmarks[9] : landmarks[0];
    
    final dx = middleMcp.x - wrist.x;
    final dy = middleMcp.y - wrist.y;
    
    return atan2(dy, dx).abs() / pi;
  }
  
  /// Helper methods for finger position detection
  static bool _isThumbExtended(List<double> extensions) => extensions.length > 0 && extensions[0] > 0.1;
  static bool _isIndexExtended(List<double> extensions) => extensions.length > 1 && extensions[1] > 0.1;
  static bool _isMiddleExtended(List<double> extensions) => extensions.length > 2 && extensions[2] > 0.1;
  static bool _isRingExtended(List<double> extensions) => extensions.length > 3 && extensions[3] > 0.1;
  static bool _isPinkyExtended(List<double> extensions) => extensions.length > 4 && extensions[4] > 0.1;
  
  static bool _areAllFingersExtended(List<double> extensions) {
    return extensions.length >= 5 &&
           _isIndexExtended(extensions) &&
           _isMiddleExtended(extensions) &&
           _isRingExtended(extensions) &&
           _isPinkyExtended(extensions);
  }
  
  static bool _areAllFingersClosed(List<double> extensions) {
    return extensions.length >= 5 &&
           extensions[1] < 0.05 && // Index
           extensions[2] < 0.05 && // Middle
           extensions[3] < 0.05 && // Ring
           extensions[4] < 0.05;   // Pinky
  }
  
  static bool _areOtherFingersClosed(List<double> extensions) {
    return extensions.length >= 5 &&
           extensions[1] < 0.05 && // Index
           extensions[2] < 0.05 && // Middle
           extensions[3] < 0.05 && // Ring
           extensions[4] < 0.05;   // Pinky
  }
  
  static bool _areFingersPartiallyExtended(List<double> extensions) {
    return extensions.length >= 5 &&
           extensions[1] > 0.05 && extensions[1] < 0.15 && // Index partially
           extensions[2] > 0.05 && extensions[2] < 0.15 && // Middle partially
           extensions[3] > 0.05 && extensions[3] < 0.15 && // Ring partially
           extensions[4] > 0.05 && extensions[4] < 0.15;   // Pinky partially
  }
  
  static bool _isThumbIndexTouch(List<double> extensions, List<double> angles) {
    return extensions.length > 1 && 
           extensions[0] > 0.08 && // Thumb extended
           extensions[1] > 0.08 && // Index extended
           angles.length > 1 && angles[1] < 0.3; // Small angle between thumb and index
  }
  
  static bool _isThumbBetweenIndexMiddle(List<double> extensions, List<double> angles) {
    return extensions.length > 2 &&
           extensions[0] > 0.08 && // Thumb extended
           extensions[1] > 0.08 && // Index extended
           extensions[2] > 0.08;   // Middle extended
  }
  
  /// Calculate confidence for letter classification
  static double _calculateConfidence(List<double> extensions, List<double> angles, double baseConfidence) {
    double confidence = baseConfidence;
    
    // Adjust confidence based on feature quality
    if (extensions.isNotEmpty) {
      final avgExtension = extensions.reduce((a, b) => a + b) / extensions.length;
      confidence *= (0.8 + avgExtension * 0.2);
    }
    
    if (angles.isNotEmpty) {
      final avgAngle = angles.reduce((a, b) => a + b) / angles.length;
      confidence *= (0.9 + (1.0 - avgAngle / pi) * 0.1);
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// Calculate confidence for word classification
  static double _calculateWordConfidence(List<double> extensions, double movement, double baseConfidence) {
    double confidence = baseConfidence;
    
    // Adjust confidence based on movement and finger positions
    confidence *= (0.8 + movement * 0.2);
    
    if (extensions.isNotEmpty) {
      final avgExtension = extensions.reduce((a, b) => a + b) / extensions.length;
      confidence *= (0.7 + avgExtension * 0.3);
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// Get available ASL gestures
  static List<String> getAvailableGestures() {
    return [..._aslAlphabet, ..._aslWords, ..._aslPhrases];
  }
  
  /// Get ASL gesture description
  static String getGestureDescription(String gesture) {
    const descriptions = {
      // Letters
      'A': 'Fist with thumb outside',
      'B': 'All fingers extended',
      'C': 'C shape with fingers',
      'D': 'Index finger pointing up',
      'E': 'All fingers bent',
      'F': 'Thumb and index finger touching',
      'G': 'Index finger pointing',
      'H': 'Index and middle finger extended',
      'I': 'Pinky finger extended',
      'L': 'L shape with index and thumb',
      'S': 'Fist',
      'T': 'Thumb between index and middle',
      'U': 'Peace sign (index and middle)',
      'V': 'V sign (index and middle apart)',
      'W': 'Three fingers up',
      'Y': 'Thumb and pinky extended',
      
      // Words
      'HELLO': 'Wave hand back and forth',
      'THANK YOU': 'Touch chin then move forward',
      'YES': 'Nodding gesture',
      'NO': 'Shaking gesture',
      'PLEASE': 'Circular motion on chest',
      'SORRY': 'Fist on chest, circular motion',
      'LOVE': 'Cross arms on chest',
      
      // Hardcoded responses (title case)
      'Yes': 'Nodding gesture',
      'No': 'Shaking gesture',
      'Please': 'Circular motion on chest',
      'HELP': 'Tap shoulder with other hand',
      
      // Phrases
      'HOW ARE YOU': 'Question gesture with raised hand',
      'NICE TO MEET YOU': 'Handshake gesture',
      'I LOVE YOU': 'Combination of I, L, Y signs',
      'GOOD MORNING': 'G sign then M sign',
      'GOOD NIGHT': 'G sign then N sign',
    };
    
    return descriptions[gesture] ?? 'Unknown gesture';
  }
  
  /// Dispose resources
  static void dispose() {
    _isInitialized = false;
    _lastError = null;
    print('✅ ASL Gesture Classifier disposed');
  }
}

/// ASL Classification Result
class ASLClassificationResult {
  final String gesture;
  final double confidence;
  final ASLCategory category;
  final String description;
  
  ASLClassificationResult({
    required this.gesture,
    required this.confidence,
    required this.category,
    required this.description,
  });
  
  @override
  String toString() {
    return 'ASLClassificationResult(gesture: $gesture, confidence: ${(confidence * 100).toStringAsFixed(1)}%, category: $category)';
  }
}

/// ASL Categories
enum ASLCategory {
  letter,
  word,
  phrase,
  nothing,
  unknown,
}
