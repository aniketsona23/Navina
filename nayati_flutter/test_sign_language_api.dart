import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🔍 Testing Sign Language API Endpoints...\n');
  
  // Test different endpoints
  await testEndpoint('/api/visual-assist/test/', 'Test Endpoint');
  await testEndpoint('/api/visual-assist/describe-scene/', 'Scene Description Endpoint');
  await testEndpoint('/api/visual-assist/', 'Base Visual Assist Endpoint');
  
  print('\n📝 To get actual sign language recognition:');
  print('1. Make sure your Django backend is running');
  print('2. Check which endpoints are available (see results above)');
  print('3. The app will try /test/ first, then /describe-scene/ as fallback');
  print('4. If both fail, you\'ll get an error message');
}

Future<void> testEndpoint(String endpoint, String name) async {
  try {
    final url = 'http://10.30.11.234:8000$endpoint';
    print('Testing $name: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Success: ${response.body}');
    } else {
      print('❌ Error: ${response.body}');
    }
  } catch (e) {
    print('❌ Connection failed: $e');
  }
  print('');
}