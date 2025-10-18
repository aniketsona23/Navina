import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger_util.dart';

class TextToSpeechProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentLanguage = 'en-US';
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  String? _errorMessage;
  List<dynamic> _availableLanguages = [];
  List<dynamic> _availableVoices = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get currentLanguage => _currentLanguage;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String? get errorMessage => _errorMessage;
  List<dynamic> get availableLanguages => _availableLanguages;
  List<dynamic> get availableVoices => _availableVoices;

  Future<void> initialize() async {
    TTSLogger.info('Initializing text-to-speech...');
    
    try {
      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        TTSLogger.debug('TTS started');
        _isSpeaking = true;
        _isPaused = false;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        TTSLogger.debug('TTS completed');
        _isSpeaking = false;
        _isPaused = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((message) {
        TTSLogger.error('TTS error: $message');
        _errorMessage = message;
        _isSpeaking = false;
        _isPaused = false;
        notifyListeners();
      });

      _flutterTts.setPauseHandler(() {
        TTSLogger.debug('TTS paused');
        _isPaused = true;
        notifyListeners();
      });

      _flutterTts.setContinueHandler(() {
        TTSLogger.debug('TTS continued');
        _isPaused = false;
        notifyListeners();
      });

      // Get available languages and voices
      _availableLanguages = await _flutterTts.getLanguages;
      _availableVoices = await _flutterTts.getVoices;
      
      TTSLogger.debug('Available languages: ${_availableLanguages.length}');
      TTSLogger.debug('Available voices: ${_availableVoices.length}');

      // Set default language to English if available
      if (_availableLanguages.isNotEmpty) {
        final englishLang = _availableLanguages.firstWhere(
          (lang) => lang.toString().toLowerCase().contains('en'),
          orElse: () => _availableLanguages.first,
        );
        _currentLanguage = englishLang.toString();
        await _flutterTts.setLanguage(_currentLanguage);
      }

      // Set default parameters
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      _isInitialized = true;
      TTSLogger.info('Text-to-speech initialized successfully');
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to initialize text-to-speech: $e');
      _errorMessage = 'Failed to initialize text-to-speech: $e';
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized || text.isEmpty) return;

    TTSLogger.info('Speaking: $text');
    
    try {
      // Stop any current speech first
      if (_isSpeaking) {
        await _flutterTts.stop();
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      TTSLogger.error('Failed to speak: $e');
      _errorMessage = 'Failed to speak: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!_isSpeaking) return;

    TTSLogger.info('Stopping speech');
    
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to stop speech: $e');
      _errorMessage = 'Failed to stop speech: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (!_isSpeaking || _isPaused) return;

    TTSLogger.debug('Pausing speech');
    
    try {
      await _flutterTts.pause();
    } catch (e) {
      TTSLogger.error('Failed to pause speech: $e');
      _errorMessage = 'Failed to pause speech: $e';
      notifyListeners();
    }
  }

  Future<void> resume() async {
    if (!_isPaused) return;

    TTSLogger.debug('Resuming speech');
    
    try {
      await _flutterTts.speak('');
    } catch (e) {
      TTSLogger.error('Failed to resume speech: $e');
      _errorMessage = 'Failed to resume speech: $e';
      notifyListeners();
    }
  }

  Future<void> setLanguage(String language) async {
    if (!_isInitialized) return;

    TTSLogger.debug('Setting language to: $language');
    
    try {
      await _flutterTts.setLanguage(language);
      _currentLanguage = language;
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to set language: $e');
      _errorMessage = 'Failed to set language: $e';
      notifyListeners();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    TTSLogger.debug('Setting speech rate to: $rate');
    
    try {
      await _flutterTts.setSpeechRate(rate);
      _speechRate = rate;
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to set speech rate: $e');
      _errorMessage = 'Failed to set speech rate: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    TTSLogger.debug('Setting volume to: $volume');
    
    try {
      await _flutterTts.setVolume(volume);
      _volume = volume;
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to set volume: $e');
      _errorMessage = 'Failed to set volume: $e';
      notifyListeners();
    }
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    TTSLogger.debug('Setting pitch to: $pitch');
    
    try {
      await _flutterTts.setPitch(pitch);
      _pitch = pitch;
      notifyListeners();
    } catch (e) {
      TTSLogger.error('Failed to set pitch: $e');
      _errorMessage = 'Failed to set pitch: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Maps language names to their corresponding TTS language codes
  String getLanguageCodeForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'en-US';
      case 'spanish':
        return 'es-ES';
      case 'french':
        return 'fr-FR';
      case 'german':
        return 'de-DE';
      case 'italian':
        return 'it-IT';
      case 'hindi':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }

  /// Sets the language for text-to-speech
  Future<void> setLanguageByName(String language) async {
    final languageCode = getLanguageCodeForLanguage(language);
    await setLanguage(languageCode);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
