import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/sign_language_service.dart';
import '../services/lstm_asl_service.dart';
import '../services/mediapipe_service.dart';
import '../helpers/asl_camera_helper.dart';

/// Example widget demonstrating LSTM-based ASL recognition
/// Based on the repository: https://github.com/AvishakeAdhikary/Realtime-Sign-Language-Detection-Using-LSTM-Model
class LSTMASLExample extends StatefulWidget {
  const LSTMASLExample({super.key});

  @override
  State<LSTMASLExample> createState() => _LSTMASLExampleState();
}

class _LSTMASLExampleState extends State<LSTMASLExample> {
  final SignLanguageService _signLanguageService = SignLanguageService();
  ASLCameraHelper? _aslCameraHelper;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _detectedText = '';
  String _statusMessage = 'Initializing...';
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeLSTMASL();
  }

  Future<void> _initializeLSTMASL() async {
    try {
      setState(() {
        _statusMessage = 'Initializing LSTM ASL Model...';
      });

      // Initialize the ASL camera helper with LSTM model
      _aslCameraHelper = ASLCameraHelper();
      
      // Set up callbacks
      _aslCameraHelper!.onLetterDetected = (String letter) {
        setState(() {
          _detectedText = letter;
          _confidence = LSTMASLService.getLastConfidence();
        });
        
        // Speak the detected letter
        _signLanguageService.speak('Letter $letter');
      };
      
      _aslCameraHelper!.onError = (String error) {
        setState(() {
          _statusMessage = 'Error: $error';
        });
      };
      
      _aslCameraHelper!.onProcessingStateChanged = (bool isProcessing) {
        setState(() {
          _isProcessing = isProcessing;
        });
      };

      // Initialize the camera and LSTM model
      final success = await _aslCameraHelper!.initialize();
      
      if (success) {
        setState(() {
          _isInitialized = true;
          _statusMessage = 'Ready! Make ASL gestures in front of the camera.';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to initialize LSTM ASL model.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization error: $e';
      });
    }
  }

  Future<void> _startDetection() async {
    if (_aslCameraHelper != null && _isInitialized) {
      await _aslCameraHelper!.startDetection();
      setState(() {
        _statusMessage = 'LSTM ASL Detection Active - Make gestures in front of the camera';
      });
    }
  }

  Future<void> _stopDetection() async {
    if (_aslCameraHelper != null) {
      await _aslCameraHelper!.stopDetection();
      setState(() {
        _statusMessage = 'LSTM ASL Detection Stopped';
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_aslCameraHelper != null && _isInitialized) {
      setState(() {
        _statusMessage = 'Capturing image...';
      });

      final imageFile = await _aslCameraHelper!.captureImage();
      if (imageFile != null) {
        setState(() {
          _statusMessage = 'Analyzing image with LSTM model...';
        });

        final result = await _aslCameraHelper!.analyzeCapturedImage(imageFile);
        if (result != null) {
          setState(() {
            _detectedText = result;
            _confidence = LSTMASLService.getLastConfidence();
            _statusMessage = 'Analysis complete!';
          });
          _signLanguageService.speak('Detected letter $result');
        } else {
          setState(() {
            _statusMessage = 'No gesture detected in the image';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Failed to capture image';
        });
      }
    }
  }

  void _clearSequence() {
    LSTMASLService.clearSequence();
    setState(() {
      _detectedText = '';
      _confidence = 0.0;
    });
  }

  @override
  void dispose() {
    _aslCameraHelper?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LSTM ASL Recognition'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status and detected text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_statusMessage',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detected: ${_detectedText.isEmpty ? "None" : _detectedText}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                if (_confidence > 0)
                  Text(
                    'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: _confidence > 0.8 ? Colors.green : 
                             _confidence > 0.6 ? Colors.orange : Colors.red,
                    ),
                  ),
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Processing...'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Camera preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _isInitialized && _aslCameraHelper != null
                    ? _aslCameraHelper!.getCameraPreview()
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Initializing LSTM Model...'),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isInitialized ? _startDetection : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Detection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _stopDetection,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Detection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isInitialized ? _captureAndAnalyze : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capture & Analyze'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearSequence,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Sequence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LSTM ASL Recognition'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This implementation uses:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• MediaPipe-style hand landmark detection'),
                Text('• LSTM neural network for gesture recognition'),
                Text('• Real-time sequence analysis'),
                Text('• Confidence scoring'),
                SizedBox(height: 16),
                Text(
                  'Based on the repository:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('https://github.com/AvishakeAdhikary/Realtime-Sign-Language-Detection-Using-LSTM-Model'),
                SizedBox(height: 16),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Real-time ASL letter recognition (A-Z)'),
                Text('• Hand landmark extraction'),
                Text('• Gesture sequence analysis'),
                Text('• Confidence-based filtering'),
                Text('• Text-to-speech output'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

/// Usage Instructions:
/// 
/// 1. This example implements LSTM-based ASL recognition similar to the referenced repository
/// 2. Uses MediaPipe-style hand landmark detection for feature extraction
/// 3. LSTM model analyzes sequences of hand landmarks for gesture recognition
/// 4. Real-time detection processes camera frames and builds landmark sequences
/// 5. Confidence scoring helps filter out uncertain predictions
/// 6. All detected letters are spoken using text-to-speech
/// 
/// Key Features:
/// - MediaPipe-style hand landmark detection
/// - LSTM neural network for sequence analysis
/// - Real-time ASL gesture recognition
/// - Confidence-based result filtering
/// - Text-to-speech output for accessibility
/// - Gesture sequence management
