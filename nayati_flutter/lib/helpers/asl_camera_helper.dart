import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../services/lstm_asl_service.dart';
import '../services/mediapipe_service.dart';
import '../services/real_asl_service.dart';
import '../services/comprehensive_asl_service.dart';
import '../services/real_comprehensive_asl.dart';

class ASLCameraHelper {
  CameraController? _cameraController;
  List<String> _labels = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  DateTime? _lastProcessTime;
  static const int _processIntervalMs = 2000; // Process every 2 seconds
  bool _useRealComprehensiveASL = true; // Flag to use real comprehensive ASL recognition
  bool _useComprehensiveASL = true; // Flag to use comprehensive ASL recognition
  bool _useRealASL = true; // Flag to use real ASL recognition as fallback
  
  // ASL Letters mapping
  static const Map<int, String> _aslLetters = {
    0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F', 6: 'G', 7: 'H', 8: 'I', 9: 'J',
    10: 'K', 11: 'L', 12: 'M', 13: 'N', 14: 'O', 15: 'P', 16: 'Q', 17: 'R', 18: 'S', 19: 'T',
    20: 'U', 21: 'V', 22: 'W', 23: 'X', 24: 'Y', 25: 'Z', 26: 'SPACE', 27: 'DEL', 28: 'NOTHING'
  };
  
  // Callbacks
  Function(String)? onLetterDetected;
  Function(String)? onError;
  Function(bool)? onProcessingStateChanged;
  
  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  
  /// Initialize camera and LSTM ASL model
  Future<bool> initialize() async {
    try {
      print('🚀 Initializing ASL Camera Helper...');
      
      // Initialize camera
      print('📷 Initializing camera...');
      await _initializeCamera();
      print('✅ Camera initialized successfully');
      
      // Initialize ASL labels
      print('🏷️ Loading ASL labels...');
      await _loadLabels();
      print('✅ ASL labels loaded: ${_labels.length} labels');
      
      // Initialize Real Comprehensive ASL service first
      print('🧠 Initializing Real Comprehensive ASL service...');
      final isRealComprehensiveASLWorking = await RealComprehensiveASL.initialize();
      if (!isRealComprehensiveASLWorking) {
        print('⚠️ Real Comprehensive ASL service failed to initialize, falling back to Comprehensive ASL');
        _useRealComprehensiveASL = false;
        
        // Fallback to Comprehensive ASL service
        print('🧠 Initializing Comprehensive ASL service...');
        final isComprehensiveASLWorking = await ComprehensiveASLService.initialize();
        if (!isComprehensiveASLWorking) {
          print('⚠️ Comprehensive ASL service failed to initialize, falling back to Real ASL');
          _useComprehensiveASL = false;
          
          // Fallback to Real ASL service
          print('🧠 Initializing Real ASL service...');
          final isRealASLWorking = await RealASLService.initialize();
          if (!isRealASLWorking) {
            print('⚠️ Real ASL service failed to initialize, falling back to LSTM');
            _useRealASL = false;
            
            // Final fallback to LSTM ASL service
            print('🧠 Initializing LSTM ASL service...');
            final isLSTMWorking = await LSTMASLService.initialize();
            if (!isLSTMWorking) {
              final errorMsg = LSTMASLService.lastError ?? 'Unknown error';
              print('❌ All ASL services initialization failed: $errorMsg');
              onError?.call('Failed to get started ASL model. $errorMsg. Please ensure your hands are visible and try again.');
              return false;
            }
            print('✅ LSTM ASL service initialized successfully');
          } else {
            print('✅ Real ASL service initialized successfully');
          }
        } else {
          print('✅ Comprehensive ASL service initialized successfully');
        }
      } else {
        print('✅ Real Comprehensive ASL service initialized successfully');
      }
      
      _isInitialized = true;
      print('🎉 ASL Camera Helper initialization completed successfully');
      return true;
    } catch (e) {
      print('❌ Failed to initialize ASL camera: $e');
      onError?.call('Failed to get started LSTM ASL model. $e. Please ensure your hands are visible and try again.');
      return false;
    }
  }
  
  /// Initialize camera controller
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    
    await _cameraController!.initialize();
  }
  
  /// Load ASL labels
  Future<void> _loadLabels() async {
    // Use hardcoded ASL letters
    _labels = _aslLetters.values.toList();
  }
  
  /// Start real-time ASL detection
  Future<void> startDetection() async {
    if (!_isInitialized || _cameraController == null) {
      onError?.call('Camera not initialized');
      return;
    }
    
    _cameraController!.startImageStream(_processFrame);
  }
  
  /// Stop ASL detection
  Future<void> stopDetection() async {
    await _cameraController?.stopImageStream();
    _isProcessing = false;
    onProcessingStateChanged?.call(false);
  }
  
  /// Process camera frame for ASL detection
  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    
    // Throttle API calls to avoid excessive requests
    final now = DateTime.now();
    if (_lastProcessTime != null && 
        now.difference(_lastProcessTime!).inMilliseconds < _processIntervalMs) {
      return;
    }
    
    _isProcessing = true;
    _lastProcessTime = now;
    onProcessingStateChanged?.call(true);
    
    try {
      // Convert camera image to processable format
      final processedImage = await _convertCameraImage(image);
      
      if (processedImage != null) {
        // Detect ASL gesture using Gemini API
        final detectedLetter = await _detectASL(processedImage);
        
        if (detectedLetter != null && detectedLetter != 'NOTHING') {
          onLetterDetected?.call(detectedLetter);
        }
      }
    } catch (e) {
      onError?.call('Frame processing error: $e');
    } finally {
      _isProcessing = false;
      onProcessingStateChanged?.call(false);
    }
  }
  
  /// Convert CameraImage to processable format
  Future<Uint8List?> _convertCameraImage(CameraImage image) async {
    try {
      // Convert YUV420 to RGB
      final int width = image.width;
      final int height = image.height;
      
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;
      
      final img.Image convertedImage = img.Image(width: width, height: height, numChannels: 3);
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * width + x;
          final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
          
          final int yValue = image.planes[0].bytes[yIndex];
          final int uValue = image.planes[1].bytes[uvIndex];
          final int vValue = image.planes[2].bytes[uvIndex];
          
          final int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
          final int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round().clamp(0, 255);
          final int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);
          
          convertedImage.setPixelRgb(x, y, r, g, b);
        }
      }
      
      // Resize to model input size (224x224)
      final resizedImage = img.copyResize(convertedImage, width: 224, height: 224);
      
      // Convert to Uint8List
      return Uint8List.fromList(img.encodeJpg(resizedImage));
    } catch (e) {
      print('Image conversion error: $e');
      return null;
    }
  }
  
  /// Detect ASL gesture using real MediaPipe and ML models
  Future<String?> _detectASL(Uint8List imageData) async {
    try {
      String? result;
      double confidence = 0.0;
      
      if (_useRealComprehensiveASL) {
        print('Processing frame with Real Comprehensive ASL recognition...');
        
        // Use real comprehensive ASL recognition with MediaPipe + Trained Patterns
        final classificationResult = await RealComprehensiveASL.recognizeASL(imageData);
        result = classificationResult.gesture;
        confidence = classificationResult.confidence;
        
        print('Real Comprehensive ASL frame processing result: $result (${(confidence * 100).toStringAsFixed(1)}%)');
      } else if (_useComprehensiveASL) {
        print('Processing frame with Comprehensive ASL recognition...');
        
        // Use comprehensive ASL recognition with MediaPipe + Advanced Classification
        final classificationResult = await ComprehensiveASLService.recognizeASL(imageData);
        result = classificationResult.gesture;
        confidence = classificationResult.confidence;
        
        print('Comprehensive ASL frame processing result: $result (${(confidence * 100).toStringAsFixed(1)}%)');
      } else if (_useRealASL) {
        print('Processing frame with Real ASL recognition...');
        
        // Use real ASL recognition with MediaPipe
        result = await RealASLService.recognizeASL(imageData);
        confidence = RealASLService.getLastConfidence();
        
        print('Real ASL frame processing result: $result');
      } else {
        print('Processing frame with LSTM ASL model...');
        
        // Use LSTM model with MediaPipe landmarks for sign language recognition
        result = await LSTMASLService.recognizeSignLanguage(imageData);
        confidence = LSTMASLService.getLastConfidence();
        
        print('LSTM frame processing result: $result');
      }
      
      if (result != null && result != 'NOTHING') {
        print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
        
        // Only return result if confidence is above threshold
        if (confidence > 0.6) {
          return result;
        }
      }
      
      // Return null for "NOTHING" or low confidence to avoid processing empty results
      return null;
    } catch (e) {
      print('ASL detection error: $e');
      onError?.call('ASL detection error: $e');
      return null;
    }
  }
  
  /// Capture current frame for processing
  Future<XFile?> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    
    try {
      return await _cameraController!.takePicture();
    } catch (e) {
      onError?.call('Failed to capture image: $e');
      return null;
    }
  }
  
  /// Analyze a captured image for ASL recognition using real MediaPipe and ML models
  Future<String?> analyzeCapturedImage(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      String? result;
      double confidence = 0.0;
      
      if (_useRealComprehensiveASL) {
        print('Analyzing captured image with Real Comprehensive ASL recognition...');
        
        final classificationResult = await RealComprehensiveASL.recognizeASL(imageBytes);
        result = classificationResult.gesture;
        confidence = classificationResult.confidence;
        
        print('Real Comprehensive ASL captured image analysis result: $result (${(confidence * 100).toStringAsFixed(1)}%)');
      } else if (_useComprehensiveASL) {
        print('Analyzing captured image with Comprehensive ASL recognition...');
        
        final classificationResult = await ComprehensiveASLService.recognizeASL(imageBytes);
        result = classificationResult.gesture;
        confidence = classificationResult.confidence;
        
        print('Comprehensive ASL captured image analysis result: $result (${(confidence * 100).toStringAsFixed(1)}%)');
      } else if (_useRealASL) {
        print('Analyzing captured image with Real ASL recognition...');
        
        result = await RealASLService.recognizeASL(imageBytes);
        confidence = RealASLService.getLastConfidence();
        
        print('Real ASL captured image analysis result: $result');
      } else {
        print('Analyzing captured image with LSTM ASL model...');
        
        result = await LSTMASLService.recognizeSignLanguage(imageBytes);
        confidence = LSTMASLService.getLastConfidence();
        
        print('LSTM captured image analysis result: $result');
      }
      
      if (result != null && result != 'NOTHING') {
        print('Captured image confidence: ${(confidence * 100).toStringAsFixed(1)}%');
        
        if (confidence > 0.5) { // Lower threshold for single image analysis
          onLetterDetected?.call(result);
          return result;
        } else {
          onError?.call('Low confidence in gesture detection. Please try again with a clearer sign.');
          return null;
        }
      } else if (result == 'NOTHING') {
        onError?.call('No clear ASL gesture detected in the captured image. Please try again with a clearer sign.');
        return null;
      }
      
      return null;
    } catch (e) {
      print('Failed to analyze captured image: $e');
      onError?.call('Failed to analyze image: $e');
      return null;
    }
  }
  
  /// Get camera preview widget
  Widget getCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: Text('Camera not initialized'),
      );
    }
    
    return CameraPreview(_cameraController!);
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await stopDetection();
    await _cameraController?.dispose();
    _isInitialized = false;
  }
  
  /// Get available ASL letters
  List<String> getAvailableLetters() {
    return _aslLetters.values.toList();
  }
  
  /// Get letter by index
  String? getLetterByIndex(int index) {
    return _aslLetters[index];
  }
}
