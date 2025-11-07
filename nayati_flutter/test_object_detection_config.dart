import 'lib/services/config_service.dart';
import 'lib/services/api_service.dart';

void main() async {
  print('Testing Object Detection Configuration...');
  
  // Initialize config service
  await ConfigService.initialize();
  
  // Get the configured backend URL
  final backendUrl = await ConfigService.getBackendUrl();
  print('✅ Backend URL configured: $backendUrl');
  
  // Test API service
  final apiService = ApiService();
  
  // Test health check
  print('\nTesting backend connection...');
  final healthResult = await apiService.checkHealth();
  
  if (healthResult['success']) {
    print('✅ Backend connection successful!');
    print('   Status: ${healthResult['status']}');
    print('   Data: ${healthResult['data']}');
  } else {
    print('❌ Backend connection failed!');
    print('   Error: ${healthResult['error']}');
    print('\nTroubleshooting:');
    print('1. Make sure Django backend is running on $backendUrl');
    print('2. Check if the IP address is correct');
    print('3. Verify network connectivity');
    print('4. Check Django CORS settings');
  }
  
  // Test connection
  print('\nTesting API connection...');
  final connectionResult = await apiService.testConnection();
  
  if (connectionResult['success']) {
    print('✅ API connection test successful!');
    print('   Response time: ${connectionResult['responseTime']}ms');
  } else {
    print('❌ API connection test failed!');
    print('   Error: ${connectionResult['error']}');
  }
  
  print('\nConfiguration test completed.');
}
