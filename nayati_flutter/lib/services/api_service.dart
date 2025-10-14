import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/logger_util.dart';
import 'config_service.dart';

class ApiService {
  static const int timeout = 30000;

  late final Dio _dio;

  ApiService() {
    _initializeDio();
  }
  
  Future<void> _initializeDio() async {
    final baseUrl = await ConfigService.getBackendUrl();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: timeout),
      receiveTimeout: const Duration(milliseconds: timeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => AppLogger.debug('API: $obj'),
    ));
  }
  
  /// Update the base URL and reinitialize the Dio instance
  Future<void> updateBaseUrl() async {
    await _initializeDio();
  }

  // Health check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final baseUrl = await ConfigService.getBackendUrl();
      AppLogger.info('Attempting to connect to: $baseUrl');
      AppLogger.debug('Full URL: $baseUrl/health/');
      
      final response = await _dio.get('/health/');
      AppLogger.info('Health check successful: ${response.statusCode}');
      return {
        'success': true,
        'status': response.statusCode,
        'data': response.data,
      };
    } catch (e) {
      AppLogger.error('Health check failed: $e');
      AppLogger.debug('Error type: ${e.runtimeType}');
      if (e is DioException) {
        AppLogger.error('Dio error type: ${e.type}');
        AppLogger.error('Dio error message: ${e.message}');
        AppLogger.debug('Dio response: ${e.response?.data}');
        AppLogger.debug('Dio status code: ${e.response?.statusCode}');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Object Detection
  Future<Map<String, dynamic>> detectObjects(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return {
          'success': false,
          'error': 'Image file not found',
        };
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'image.jpg',
        ),
      });

      AppLogger.info('Sending image to backend: $imagePath');
      final response = await _dio.post(
        '/visual-assist/detect-objects/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      AppLogger.debug('Backend response status: ${response.statusCode}');
      AppLogger.debug('Backend response data: ${response.data}');

      return {
        'success': true,
        'detections': response.data['detections'] ?? [],
        'num_detections': response.data['num_detections'] ?? 0,
        'processing_time': response.data['processing_time'] ?? 0.0,
        'session_id': response.data['session_id'] ?? 0,
        'model_info': response.data['model_info'] ?? {},
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to detect objects: ${e.toString()}',
      };
    }
  }

  // Speech to Text
  Future<Map<String, dynamic>> transcribeAudio(String audioPath, {String language = 'en'}) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        return {
          'success': false,
          'error': 'Audio file not found',
        };
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: 'audio.wav',
        ),
        'language': language,
      });

      final response = await _dio.post(
        '/hearing-assist/transcribe/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'success': true,
        'transcribed_text': response.data['transcribed_text'] ?? '',
        'confidence_score': response.data['confidence_score'] ?? 0.0,
        'language': response.data['language'] ?? language,
        'processing_time': response.data['processing_time'] ?? 0.0,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to transcribe audio: ${e.toString()}',
      };
    }
  }

  // Get transcription history
  Future<List<Map<String, dynamic>>> getTranscriptionHistory() async {
    try {
      final response = await _dio.get('/hearing-assist/history/');
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } catch (e) {
      AppLogger.error('Failed to get transcription history: $e');
      return [];
    }
  }

  // Test API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final startTime = DateTime.now();
      final response = await _dio.get('/health/');
      final endTime = DateTime.now();
      
      return {
        'success': true,
        'status': response.statusCode,
        'responseTime': endTime.difference(startTime).inMilliseconds,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'responseTime': 0,
      };
    }
  }

  void dispose() {
    _dio.close();
  }
}
