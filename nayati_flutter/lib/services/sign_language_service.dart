import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class SignLanguageService {
  static final SignLanguageService _instance = SignLanguageService._internal();
  factory SignLanguageService() => _instance;
  SignLanguageService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  // API Configuration - Change this URL for different environments
  static const String _apiBaseUrl = 'https://signify-10529.uc.r.appspot.com';
  static const String baseUrl = _apiBaseUrl;

  // Initialize TTS
  Future<void> initializeTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Convert sign language video to text
  Future<Map<String, dynamic>> convertSignLanguageToText({
    required String videoPath,
    String? username,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_video'),
      );

      // Add video file
      var videoFile = File(videoPath);
      var multipartFile = await http.MultipartFile.fromPath(
        'video',
        videoPath,
        filename: 'sign_language_video.mp4',
      );
      request.files.add(multipartFile);

      // Add username if provided
      if (username != null) {
        request.fields['username'] = username;
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'text': data['word'] ?? '',
          'confidence': 0.8, // Default confidence score
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to process video: ${response.statusCode}',
          'text': '',
          'confidence': 0.0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error processing video: $e',
        'text': '',
        'confidence': 0.0,
      };
    }
  }

  // Convert sign language image to text (alternative method)
  Future<Map<String, dynamic>> convertSignLanguageImageToText({
    required String imagePath,
    String? username,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_image'),
      );

      // Add image file
      var imageFile = File(imagePath);
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: 'sign_language_image.jpg',
      );
      request.files.add(multipartFile);

      // Add username if provided
      if (username != null) {
        request.fields['username'] = username;
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'text': data['word'] ?? '',
          'confidence': 0.7, // Slightly lower confidence for images
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to process image: ${response.statusCode}',
          'text': '',
          'confidence': 0.0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error processing image: $e',
        'text': '',
        'confidence': 0.0,
      };
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isSpeaking && text.isNotEmpty) {
      _isSpeaking = true;
      await _flutterTts.speak(text);
      _isSpeaking = false;
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  // Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  // Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get available sign language models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['models'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Set sign language model
  Future<bool> setModel(String modelName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/set_model'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': modelName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
