import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class AudioRecordingProvider extends ChangeNotifier {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  String? _recordingPath;
  String? _error;
  bool _isInitialized = false;
  Timer? _durationTimer;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  Duration get duration => _duration;
  String? get recordingPath => _recordingPath;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();
      
      await _recorder!.openRecorder();
      await _player!.openPlayer();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize audio recorder: $e';
      notifyListeners();
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _error = null;
      
      if (!await requestPermissions()) {
        _error = 'Microphone permission denied';
        notifyListeners();
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );
      
      _isRecording = true;
      _isPaused = false;
      _recordingPath = path;
      _duration = Duration.zero;
      
      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _duration = Duration(seconds: timer.tick);
        notifyListeners();
      });
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (_isRecording && _recorder != null) {
        _durationTimer?.cancel();
        _durationTimer = null;
        
        final path = await _recorder!.stopRecorder();
        _isRecording = false;
        _isPaused = false;
        _recordingPath = path;
        notifyListeners();
        return path;
      }
      return null;
    } catch (e) {
      _error = 'Failed to stop recording: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> pauseRecording() async {
    try {
      if (_isRecording && !_isPaused && _recorder != null) {
        await _recorder!.pauseRecorder();
        _isPaused = true;
        _durationTimer?.cancel();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pause recording: $e';
      notifyListeners();
    }
  }

  Future<void> resumeRecording() async {
    try {
      if (_isRecording && _isPaused && _recorder != null) {
        await _recorder!.resumeRecorder();
        _isPaused = false;
        
        // Resume duration timer
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = Duration(seconds: timer.tick);
          notifyListeners();
        });
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to resume recording: $e';
      notifyListeners();
    }
  }

  void resetRecording() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _isRecording = false;
    _isPaused = false;
    _duration = Duration.zero;
    _recordingPath = null;
    _error = null;
    notifyListeners();
  }

  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }
}