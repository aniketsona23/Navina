import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/logger_util.dart';

class NetworkTest {
  static const List<String> possibleUrls = [
    'http://10.30.11.234:8000/api',
    'http://10.53.175.29:8000/api',
    'http://10.30.8.17:8000/api',
    'http://127.0.0.1:8000/api',
    'http://localhost:8000/api',
    'http://192.168.1.100:8000/api',
    'http://192.168.0.100:8000/api',
  ];

  static Future<Map<String, dynamic>> testAllConnections() async {
    AppLogger.info('Testing network connections...');
    
    for (String url in possibleUrls) {
      AppLogger.debug('Testing: $url');
      
      try {
        final dio = Dio();
        dio.options.baseUrl = url;
        dio.options.connectTimeout = const Duration(seconds: 5);
        dio.options.receiveTimeout = const Duration(seconds: 5);
        
        final response = await dio.get('/health/');
        AppLogger.info('SUCCESS: $url - Status: ${response.statusCode}');
        return {
          'success': true,
          'workingUrl': url,
          'status': response.statusCode,
          'data': response.data,
        };
      } catch (e) {
        AppLogger.warning('FAILED: $url - $e');
      }
    }
    
    return {
      'success': false,
      'error': 'No working connection found',
      'testedUrls': possibleUrls,
    };
  }

  static Future<Map<String, dynamic>> testSpecificUrl(String url) async {
    AppLogger.info('Testing specific URL: $url');
    
    try {
      final dio = Dio();
      dio.options.baseUrl = url;
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      final response = await dio.get('/health/');
      AppLogger.info('SUCCESS: $url - Status: ${response.statusCode}');
      return {
        'success': true,
        'url': url,
        'status': response.statusCode,
        'data': response.data,
      };
    } catch (e) {
      AppLogger.error('FAILED: $url - $e');
      if (e is DioException) {
        return {
          'success': false,
          'url': url,
          'error': e.message ?? 'Unknown error',
          'type': e.type.toString(),
          'statusCode': e.response?.statusCode,
        };
      }
      return {
        'success': false,
        'url': url,
        'error': e.toString(),
      };
    }
  }

  static Future<List<String>> getLocalIPs() async {
    List<String> ips = [];
    
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error getting local IPs: $e');
    }
    
    return ips;
  }
}
