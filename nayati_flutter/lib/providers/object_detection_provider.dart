import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DetectionResult {
  final String id;
  final String name;
  final double confidence;
  final Map<String, double> bounds;
  final Map<String, double> center;

  DetectionResult({
    required this.id,
    required this.name,
    required this.confidence,
    required this.bounds,
    required this.center,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      bounds: Map<String, double>.from(json['bounds'] ?? {}),
      center: Map<String, double>.from(json['center'] ?? {}),
    );
  }
}

class ObjectDetectionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<DetectionResult> _detections = [];
  bool _isDetecting = false;
  String? _error;
  double _processingTime = 0.0;
  DateTime? _lastDetectionTime;

  List<DetectionResult> get detections => _detections;
  bool get isDetecting => _isDetecting;
  String? get error => _error;
  double get processingTime => _processingTime;
  DateTime? get lastDetectionTime => _lastDetectionTime;

  Future<void> detectObjects(String imagePath) async {
    if (_isDetecting) return;

    try {
      _isDetecting = true;
      _error = null;
      notifyListeners();

      print('🔍 Starting object detection for: $imagePath');
      final startTime = DateTime.now();
      final result = await _apiService.detectObjects(imagePath);
      final endTime = DateTime.now();

      _processingTime = endTime.difference(startTime).inMilliseconds.toDouble();
      _lastDetectionTime = DateTime.now();

      print('📊 Detection result: $result');

      if (result['success'] == true) {
        final detectionsList = result['detections'] as List<dynamic>? ?? [];
        print('🎯 Found ${detectionsList.length} detections');
        
        _detections = detectionsList
            .map((item) => DetectionResult.fromJson(item as Map<String, dynamic>))
            .toList();
        
        print('✅ Detections processed: ${_detections.length}');
      } else {
        _error = result['error'] ?? 'Detection failed';
        print('❌ Detection failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to detect objects: $e';
      print('💥 Detection error: $e');
    } finally {
      _isDetecting = false;
      notifyListeners();
    }
  }

  void clearDetections() {
    _detections.clear();
    _error = null;
    _processingTime = 0.0;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }
}
