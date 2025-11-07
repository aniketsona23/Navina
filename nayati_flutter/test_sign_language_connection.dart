import 'dart:io';
import 'lib/services/sign_language_service.dart';

void main() async {
  print('Testing Sign Language Service Connection...');
  
  final service = SignLanguageService();
  
  // Test connection
  print('Testing connection to: ${SignLanguageService.baseUrl}');
  final isConnected = await service.testConnection();
  
  if (isConnected) {
    print('✅ Connection successful!');
  } else {
    print('❌ Connection failed!');
    print('Please check:');
    print('1. Django backend is running on http://10.30.11.234:8000');
    print('2. Sign language API endpoints are available');
    print('3. Network connectivity');
  }
  
  // Test TTS initialization
  print('\nTesting TTS initialization...');
  try {
    await service.initializeTTS();
    print('✅ TTS initialized successfully!');
  } catch (e) {
    print('❌ TTS initialization failed: $e');
  }
  
  print('\nTest completed.');
}
