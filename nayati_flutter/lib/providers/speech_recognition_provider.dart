import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = '';
  String _fullText = '';
  String _lastWords = '';
  double _confidence = 0.0;
  String _currentLocaleId = 'en_US';
  List<stt.LocaleName> _localeNames = [];
  String? _errorMessage;

  // Getters
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get currentText => _currentText;
  String get fullText => _fullText;
  String get lastWords => _lastWords;
  double get confidence => _confidence;
  String get currentLocaleId => _currentLocaleId;
  List<stt.LocaleName> get localeNames => _localeNames;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    print('🎤 Initializing speech recognition...');
    
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _errorMessage = 'Microphone permission denied';
        notifyListeners();
        return;
      }

      // Initialize speech to text
      _isAvailable = await _speech.initialize(
        onError: (error) {
          print('🎤 Speech error: ${error.errorMsg}');
          _errorMessage = error.errorMsg;
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          print('🎤 Speech status: $status');
          _isListening = status.toString().contains('listening');
          notifyListeners();
        },
      );

      if (_isAvailable) {
        // Get available locales
        _localeNames = await _speech.locales();
        print('🎤 Available locales: ${_localeNames.length}');
        
        // Set default locale to English if available
        final englishLocale = _localeNames.firstWhere(
          (locale) => locale.localeId.startsWith('en'),
          orElse: () => _localeNames.isNotEmpty ? _localeNames.first : stt.LocaleName('en_US', 'English'),
        );
        _currentLocaleId = englishLocale.localeId;
        
        print('🎤 Speech recognition initialized successfully');
      } else {
        _errorMessage = 'Speech recognition not available on this device';
      }
      
      notifyListeners();
    } catch (e) {
      print('🎤 Failed to initialize speech recognition: $e');
      _errorMessage = 'Failed to initialize speech recognition: $e';
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;

    print('🎤 Starting speech recognition...');
    
    try {
      await _speech.listen(
        onResult: (result) {
          print('🎤 Speech result: ${result.recognizedWords}');
          _currentText = result.recognizedWords;
          _confidence = result.confidence;
          notifyListeners();
        },
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: (level) {
          // Optional: Handle sound level changes for visual feedback
        },
      );
    } catch (e) {
      print('🎤 Failed to start listening: $e');
      _errorMessage = 'Failed to start listening: $e';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    print('🎤 Stopping speech recognition...');
    
    try {
      await _speech.stop();
      _lastWords = _currentText;
      _fullText += _currentText.isNotEmpty ? '$_currentText ' : '';
      _currentText = '';
      notifyListeners();
    } catch (e) {
      print('🎤 Failed to stop listening: $e');
      _errorMessage = 'Failed to stop listening: $e';
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    print('🎤 Cancelling speech recognition...');
    
    try {
      await _speech.cancel();
      _currentText = '';
      notifyListeners();
    } catch (e) {
      print('🎤 Failed to cancel listening: $e');
      _errorMessage = 'Failed to cancel listening: $e';
      notifyListeners();
    }
  }

  void clearText() {
    print('🎤 Clearing speech text...');
    _currentText = '';
    _fullText = '';
    _lastWords = '';
    _confidence = 0.0;
    notifyListeners();
  }

  void setLocale(String localeId) {
    if (_localeNames.any((locale) => locale.localeId == localeId)) {
      _currentLocaleId = localeId;
      notifyListeners();
    }
  }

  void addToFullText(String text) {
    if (text.isNotEmpty) {
      _fullText += '$text ';
      notifyListeners();
    }
  }
}
