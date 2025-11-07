import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/sign_language_service.dart';
import '../helpers/asl_camera_helper.dart';

/// Example widget demonstrating how to use the ASL Camera Helper with Gemini AI
class ASLGeminiExample extends StatefulWidget {
  const ASLGeminiExample({super.key});

  @override
  State<ASLGeminiExample> createState() => _ASLGeminiExampleState();
}

class _ASLGeminiExampleState extends State<ASLGeminiExample> {
  final SignLanguageService _signLanguageService = SignLanguageService();
  ASLCameraHelper? _aslCameraHelper;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _detectedText = '';
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeASL();
  }

  Future<void> _initializeASL() async {
    try {
      setState(() {
        _statusMessage = 'Initializing ASL Camera...';
      });

      // Initialize the ASL camera helper
      _aslCameraHelper = ASLCameraHelper();
      
      // Set up callbacks
      _aslCameraHelper!.onLetterDetected = (String letter) {
        setState(() {
          _detectedText = letter;
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

      // Initialize the camera and test Gemini API connection
      final success = await _aslCameraHelper!.initialize();
      
      if (success) {
        setState(() {
          _isInitialized = true;
          _statusMessage = 'Ready! Make ASL gestures in front of the camera.';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to initialize. Please check your camera and internet connection.';
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
        _statusMessage = 'ASL Detection Active - Make gestures in front of the camera';
      });
    }
  }

  Future<void> _stopDetection() async {
    if (_aslCameraHelper != null) {
      await _aslCameraHelper!.stopDetection();
      setState(() {
        _statusMessage = 'ASL Detection Stopped';
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
          _statusMessage = 'Analyzing image with Gemini AI...';
        });

        final result = await _aslCameraHelper!.analyzeCapturedImage(imageFile);
        if (result != null) {
          setState(() {
            _detectedText = result;
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

  @override
  void dispose() {
    _aslCameraHelper?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASL Recognition with Gemini AI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                            Text('Initializing Camera...'),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized ? _captureAndAnalyze : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture & Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Usage Instructions:
/// 
/// 1. This example shows how to integrate ASL camera helper with Gemini AI
/// 2. The camera will capture frames and send them to Gemini API for ASL recognition
/// 3. Real-time detection processes frames every 2 seconds to avoid excessive API calls
/// 4. Manual capture allows you to take a specific photo for analysis
/// 5. All detected letters are spoken using text-to-speech
/// 
/// Key Features:
/// - Real-time ASL gesture recognition using Gemini AI
/// - Automatic throttling to prevent excessive API calls
/// - Manual image capture and analysis
/// - Text-to-speech output for accessibility
/// - Error handling and status feedback
/// - No authentication required (API key embedded)
