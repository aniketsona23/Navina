import 'package:flutter/foundation.dart';
import '../services/sign_language_service.dart';

class SignLanguageProvider extends ChangeNotifier {
  final SignLanguageService _signLanguageService = SignLanguageService();
  
  // State variables
  bool _isProcessing = false;
  bool _isRecording = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  String _errorMessage = '';
  List<String> _history = [];
  bool _isConnected = false;
  List<String> _availableModels = [];
  String _selectedModel = '';

  // Getters
  bool get isProcessing => _isProcessing;
  bool get isRecording => _isRecording;
  bool get isSpeaking => _isSpeaking;
  String get recognizedText => _recognizedText;
  double get confidence => _confidence;
  String get errorMessage => _errorMessage;
  List<String> get history => _history;
  bool get isConnected => _isConnected;
  List<String> get availableModels => _availableModels;
  String get selectedModel => _selectedModel;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      await _signLanguageService.initializeTTS();
      _isConnected = await _signLanguageService.testConnection();
      _availableModels = await _signLanguageService.getAvailableModels();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize sign language service: $e';
      notifyListeners();
    }
  }

  // Start recording
  void startRecording() {
    _isRecording = true;
    _errorMessage = '';
    notifyListeners();
  }

  // Stop recording
  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  // Process video file
  Future<void> processVideo({
    required String videoPath,
    String? username,
  }) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      _errorMessage = '';
      notifyListeners();

      final result = await _signLanguageService.convertSignLanguageToText(
        videoPath: videoPath,
        username: username,
      );

      if (result['success']) {
        _recognizedText = result['text'];
        _confidence = result['confidence'];
        
        // Add to history if text is not empty
        if (_recognizedText.isNotEmpty) {
          _history.insert(0, _recognizedText);
          // Keep only last 50 items
          if (_history.length > 50) {
            _history = _history.take(50).toList();
          }
        }
      } else {
        _errorMessage = result['error'] ?? 'Failed to process video';
        _recognizedText = '';
        _confidence = 0.0;
      }
    } catch (e) {
      _errorMessage = 'Error processing video: $e';
      _recognizedText = '';
      _confidence = 0.0;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Process image file
  Future<void> processImage({
    required String imagePath,
    String? username,
  }) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      _errorMessage = '';
      notifyListeners();

      final result = await _signLanguageService.convertSignLanguageImageToText(
        imagePath: imagePath,
        username: username,
      );

      if (result['success']) {
        _recognizedText = result['text'];
        _confidence = result['confidence'];
        
        // Add to history if text is not empty
        if (_recognizedText.isNotEmpty) {
          _history.insert(0, _recognizedText);
          // Keep only last 50 items
          if (_history.length > 50) {
            _history = _history.take(50).toList();
          }
        }
      } else {
        _errorMessage = result['error'] ?? 'Failed to process image';
        _recognizedText = '';
        _confidence = 0.0;
      }
    } catch (e) {
      _errorMessage = 'Error processing image: $e';
      _recognizedText = '';
      _confidence = 0.0;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Speak recognized text
  Future<void> speakText() async {
    if (_recognizedText.isNotEmpty) {
      _isSpeaking = true;
      notifyListeners();
      
      await _signLanguageService.speak(_recognizedText);
      
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _signLanguageService.stopSpeaking();
    _isSpeaking = false;
    notifyListeners();
  }

  // Clear recognized text
  void clearText() {
    _recognizedText = '';
    _confidence = 0.0;
    _errorMessage = '';
    notifyListeners();
  }

  // Clear history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // Set selected model
  Future<void> setModel(String modelName) async {
    try {
      final success = await _signLanguageService.setModel(modelName);
      if (success) {
        _selectedModel = modelName;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to set model: $e';
      notifyListeners();
    }
  }

  // Refresh connection
  Future<void> refreshConnection() async {
    _isConnected = await _signLanguageService.testConnection();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _isProcessing = false;
    _isRecording = false;
    _isSpeaking = false;
    _recognizedText = '';
    _confidence = 0.0;
    _errorMessage = '';
    _isConnected = false;
    _selectedModel = '';
    notifyListeners();
  }
}
