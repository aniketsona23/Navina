import 'package:flutter/foundation.dart';
import '../providers/text_to_speech_provider.dart';
import '../providers/object_detection_provider.dart';

class VisualNarrationService extends ChangeNotifier {
  final TextToSpeechProvider _ttsProvider;
  
  bool _isNarrating = false;
  bool _isEnabled = true;
  String _lastNarration = '';
  List<String> _recentNarrations = [];
  String _currentLanguage = 'English';
  static const int _maxRecentNarrations = 5;

  // Language-specific templates
  static const Map<String, Map<String, String>> _languageTemplates = {
    'English': {
      'no_objects': 'No objects detected in front of you.',
      'single_object_center': 'There is a {object} in front of you, {distance}.',
      'single_object_left': 'There is a {object} on your left, {distance}.',
      'single_object_right': 'There is a {object} on your right, {distance}.',
      'multiple_objects_center': 'There is a {object} {distance} and {count} other objects in front of you.',
      'multiple_objects_left': 'There is a {object} {distance} and {count} other objects on your left.',
      'multiple_objects_right': 'There is a {object} {distance} and {count} other objects on your right.',
      'two_objects_center': 'There are a {object1} {distance1} and a {object2} {distance2} in front of you.',
      'two_objects_left': 'There are a {object1} {distance1} and a {object2} {distance2} on your left.',
      'two_objects_right': 'There are a {object1} {distance1} and a {object2} {distance2} on your right.',
      'close': 'very close',
      'medium': 'at medium distance',
      'far': 'far away',
      'clearly_visible': 'clearly visible',
      'visible': 'visible',
      'possibly': 'possibly',
    },
    'Hindi': {
      'no_objects': 'आपके सामने कोई वस्तु नहीं दिखाई दे रही।',
      'single_object_center': 'आपके सामने {object} है, {distance}।',
      'single_object_left': 'आपके बाईं ओर {object} है, {distance}।',
      'single_object_right': 'आपके दाईं ओर {object} है, {distance}।',
      'multiple_objects_center': 'आपके सामने {object} {distance} और {count} अन्य वस्तुएं हैं।',
      'multiple_objects_left': 'आपके बाईं ओर {object} {distance} और {count} अन्य वस्तुएं हैं।',
      'multiple_objects_right': 'आपके दाईं ओर {object} {distance} और {count} अन्य वस्तुएं हैं।',
      'two_objects_center': 'आपके सामने {object1} {distance1} और {object2} {distance2} हैं।',
      'two_objects_left': 'आपके बाईं ओर {object1} {distance1} और {object2} {distance2} हैं।',
      'two_objects_right': 'आपके दाईं ओर {object1} {distance1} और {object2} {distance2} हैं।',
      'close': 'बहुत पास',
      'medium': 'मध्यम दूरी पर',
      'far': 'दूर',
      'clearly_visible': 'स्पष्ट रूप से दिखाई दे रहा',
      'visible': 'दिखाई दे रहा',
      'possibly': 'संभवतः',
    },
    'German': {
      'no_objects': 'Keine Objekte vor Ihnen erkannt.',
      'single_object_center': 'Es gibt ein {object} vor Ihnen, {distance}.',
      'single_object_left': 'Es gibt ein {object} links von Ihnen, {distance}.',
      'single_object_right': 'Es gibt ein {object} rechts von Ihnen, {distance}.',
      'multiple_objects_center': 'Es gibt ein {object} {distance} und {count} andere Objekte vor Ihnen.',
      'multiple_objects_left': 'Es gibt ein {object} {distance} und {count} andere Objekte links von Ihnen.',
      'multiple_objects_right': 'Es gibt ein {object} {distance} und {count} andere Objekte rechts von Ihnen.',
      'two_objects_center': 'Es gibt ein {object1} {distance1} und ein {object2} {distance2} vor Ihnen.',
      'two_objects_left': 'Es gibt ein {object1} {distance1} und ein {object2} {distance2} links von Ihnen.',
      'two_objects_right': 'Es gibt ein {object1} {distance1} und ein {object2} {distance2} rechts von Ihnen.',
      'close': 'sehr nah',
      'medium': 'in mittlerer Entfernung',
      'far': 'weit weg',
      'clearly_visible': 'deutlich sichtbar',
      'visible': 'sichtbar',
      'possibly': 'möglicherweise',
    },
    'French': {
      'no_objects': 'Aucun objet détecté devant vous.',
      'single_object_center': 'Il y a un {object} devant vous, {distance}.',
      'single_object_left': 'Il y a un {object} à votre gauche, {distance}.',
      'single_object_right': 'Il y a un {object} à votre droite, {distance}.',
      'multiple_objects_center': 'Il y a un {object} {distance} et {count} autres objets devant vous.',
      'multiple_objects_left': 'Il y a un {object} {distance} et {count} autres objets à votre gauche.',
      'multiple_objects_right': 'Il y a un {object} {distance} et {count} autres objets à votre droite.',
      'two_objects_center': 'Il y a un {object1} {distance1} et un {object2} {distance2} devant vous.',
      'two_objects_left': 'Il y a un {object1} {distance1} et un {object2} {distance2} à votre gauche.',
      'two_objects_right': 'Il y a un {object1} {distance1} et un {object2} {distance2} à votre droite.',
      'close': 'très proche',
      'medium': 'à distance moyenne',
      'far': 'loin',
      'clearly_visible': 'clairement visible',
      'visible': 'visible',
      'possibly': 'possiblement',
    },
  };

  VisualNarrationService(this._ttsProvider);

  // Getters
  bool get isNarrating => _isNarrating;
  bool get isEnabled => _isEnabled;
  String get lastNarration => _lastNarration;
  List<String> get recentNarrations => _recentNarrations;
  String get currentLanguage => _currentLanguage;
  List<String> get supportedLanguages => _languageTemplates.keys.toList();

  /// Set the narration language
  void setLanguage(String language) {
    if (_languageTemplates.containsKey(language)) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  /// Enable or disable narration
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  /// Get template for current language
  String _getTemplate(String key) {
    return _languageTemplates[_currentLanguage]?[key] ?? _languageTemplates['English']![key]!;
  }

  /// Generate position description based on object bounds
  String _getPositionDescription(Map<String, double> bounds) {
    final centerX = bounds['x']! + (bounds['width']! / 2);
    
    // Determine horizontal position
    String horizontalPosition;
    if (centerX < 0.33) {
      horizontalPosition = 'left';
    } else if (centerX > 0.67) {
      horizontalPosition = 'right';
    } else {
      horizontalPosition = 'center';
    }
    
    return horizontalPosition;
  }

  /// Get distance description based on object size
  String _getDistanceDescription(Map<String, double> bounds) {
    final area = bounds['width']! * bounds['height']!;
    if (area > 0.25) {
      return _getTemplate('close');
    } else if (area > 0.1) {
      return _getTemplate('medium');
    } else {
      return _getTemplate('far');
    }
  }

  /// Get confidence description
  String _getConfidenceDescription(double confidence) {
    if (confidence > 0.8) {
      return _getTemplate('clearly_visible');
    } else if (confidence > 0.6) {
      return _getTemplate('visible');
    } else {
      return _getTemplate('possibly');
    }
  }

  /// Generate natural language description for detected objects
  String _generateObjectDescription(List<DetectionResult> detections) {
    if (detections.isEmpty) {
      return _getTemplate('no_objects');
    }

    // Group objects by position for better narration
    final leftObjects = <DetectionResult>[];
    final centerObjects = <DetectionResult>[];
    final rightObjects = <DetectionResult>[];

    for (final detection in detections) {
      final centerX = detection.bounds['x']! + (detection.bounds['width']! / 2);
      if (centerX < 0.33) {
        leftObjects.add(detection);
      } else if (centerX > 0.67) {
        rightObjects.add(detection);
      } else {
        centerObjects.add(detection);
      }
    }

    final descriptions = <String>[];

    // Describe center objects first (most important)
    if (centerObjects.isNotEmpty) {
      final centerDescription = _describeObjectsInPosition(centerObjects, 'center');
      descriptions.add(centerDescription);
    }

    // Describe left objects
    if (leftObjects.isNotEmpty) {
      final leftDescription = _describeObjectsInPosition(leftObjects, 'left');
      descriptions.add(leftDescription);
    }

    // Describe right objects
    if (rightObjects.isNotEmpty) {
      final rightDescription = _describeObjectsInPosition(rightObjects, 'right');
      descriptions.add(rightDescription);
    }

    return descriptions.join('. ') + '.';
  }

  /// Describe objects in a specific position
  String _describeObjectsInPosition(List<DetectionResult> objects, String position) {
    if (objects.isEmpty) return '';

    // Sort by confidence (highest first)
    objects.sort((a, b) => b.confidence.compareTo(a.confidence));

    if (objects.length == 1) {
      final obj = objects.first;
      final distance = _getDistanceDescription(obj.bounds);
      return _getTemplate('single_object_$position')
          .replaceAll('{object}', obj.name)
          .replaceAll('{distance}', distance);
    } else if (objects.length == 2) {
      final obj1 = objects[0];
      final obj2 = objects[1];
      final distance1 = _getDistanceDescription(obj1.bounds);
      final distance2 = _getDistanceDescription(obj2.bounds);
      return _getTemplate('two_objects_$position')
          .replaceAll('{object1}', obj1.name)
          .replaceAll('{distance1}', distance1)
          .replaceAll('{object2}', obj2.name)
          .replaceAll('{distance2}', distance2);
    } else {
      final primaryObj = objects.first;
      final distance = _getDistanceDescription(primaryObj.bounds);
      final otherCount = objects.length - 1;
      return _getTemplate('multiple_objects_$position')
          .replaceAll('{object}', primaryObj.name)
          .replaceAll('{distance}', distance)
          .replaceAll('{count}', otherCount.toString());
    }
  }

  /// Narrate detected objects
  Future<void> narrateDetections(List<DetectionResult> detections) async {
    if (!_isEnabled || _isNarrating || detections.isEmpty) return;

    try {
      _isNarrating = true;
      notifyListeners();

      final description = _generateObjectDescription(detections);
      
      // Avoid repeating the same narration
      if (description == _lastNarration) {
        VisualNarrationLogger.debug('Skipping duplicate narration');
        return;
      }

      _lastNarration = description;
      _addToRecentNarrations(description);

      VisualNarrationLogger.info('Narrating in $_currentLanguage: $description');
      
      // Stop any current speech before starting new narration
      if (_ttsProvider.isSpeaking) {
        await _ttsProvider.stop();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Set TTS language based on current narration language
      await _ttsProvider.setLanguage(_ttsProvider.getLanguageCodeForLanguage(_currentLanguage));
      await _ttsProvider.speak(description);
      
    } catch (e) {
      VisualNarrationLogger.error('Failed to narrate detections: $e');
    } finally {
      _isNarrating = false;
      notifyListeners();
    }
  }

  /// Add narration to recent list
  void _addToRecentNarrations(String narration) {
    _recentNarrations.insert(0, narration);
    if (_recentNarrations.length > _maxRecentNarrations) {
      _recentNarrations.removeLast();
    }
    notifyListeners();
  }

  /// Stop current narration
  Future<void> stopNarration() async {
    if (_isNarrating) {
      await _ttsProvider.stop();
      _isNarrating = false;
      notifyListeners();
    }
  }

  /// Clear recent narrations
  void clearRecentNarrations() {
    _recentNarrations.clear();
    _lastNarration = '';
    notifyListeners();
  }

  /// Generate a summary of all detected objects
  String generateSummary(List<DetectionResult> detections) {
    if (detections.isEmpty) {
      return _getTemplate('no_objects');
    }

    final objectCounts = <String, int>{};
    for (final detection in detections) {
      objectCounts[detection.name] = (objectCounts[detection.name] ?? 0) + 1;
    }

    final summaryParts = <String>[];
    objectCounts.forEach((name, count) {
      if (count == 1) {
        summaryParts.add('1 $name');
      } else {
        summaryParts.add('$count ${name}s');
      }
    });

    return 'Detected: ${summaryParts.join(', ')}.';
  }

  /// Generate detailed description for accessibility
  String generateDetailedDescription(List<DetectionResult> detections) {
    if (detections.isEmpty) {
      return _getTemplate('no_objects');
    }

    final descriptions = <String>[];
    
    for (final detection in detections) {
      final position = _getPositionDescription(detection.bounds);
      final confidence = _getConfidenceDescription(detection.confidence);
      final distance = _getDistanceDescription(detection.bounds);
      
      descriptions.add(
        'A ${detection.name} $confidence $position, $distance, with ${(detection.confidence * 100).toStringAsFixed(0)}% confidence'
      );
    }

    return descriptions.join('. ') + '.';
  }
}

// Logger for visual narration
class VisualNarrationLogger {
  static void info(String message) {
    if (kDebugMode) {
      print('🔊 Visual Narration: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('🔊 Visual Narration Debug: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('🔊 Visual Narration Error: $message');
    }
  }
}