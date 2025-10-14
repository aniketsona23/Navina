// Test script to verify outdoor navigation setup
// Run with: dart test_navigation.dart

import 'dart:io';
import 'lib/utils/logger_util.dart';

void main() async {
  AppLogger.info('🧪 Testing Outdoor Navigation Setup...\n');
  
  // Check if pubspec.yaml has required dependencies
  await _checkDependencies();
  
  // Check Android configuration
  await _checkAndroidConfig();
  
  // Check iOS configuration
  await _checkIOSConfig();
  
  AppLogger.info('\n✅ Setup verification complete!');
  AppLogger.info('\n📱 Next steps:');
  AppLogger.info('1. Run: flutter clean && flutter pub get');
  AppLogger.info('2. Run: flutter run');
  AppLogger.info('3. Navigate to Mobility Assist → Outdoor Nav');
  AppLogger.info('\n🗺️ FREE MAP OPTION (OpenStreetMap):');
  AppLogger.info('- ✅ Works immediately - NO API key needed!');
  AppLogger.info('- ✅ Shows your current location with blue dot');
  AppLogger.info('- ✅ Displays real street maps with building details');
  AppLogger.info('- ✅ Search destinations and get directions');
  AppLogger.info('- ✅ Completely free with no usage limits');
  AppLogger.info('\n🗺️ PAID MAP OPTION (Google Maps):');
  AppLogger.info('- ⚠️  Requires API key and billing setup');
  AppLogger.info('- ⚠️  Replace YOUR_GOOGLE_MAPS_API_KEY_HERE in config files');
  AppLogger.info('- ✅ Higher quality maps with more features');
}

Future<void> _checkDependencies() async {
  AppLogger.info('📦 Checking dependencies...');
  
  try {
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      
      final requiredDeps = [
        'flutter_map',        // Free OpenStreetMap
        'latlong2',          // Coordinates for OpenStreetMap
        'google_maps_flutter', // Paid Google Maps (optional)
        'geolocator',        // Location services
        'geocoding',         // Address search
      ];
      
      for (final dep in requiredDeps) {
        if (content.contains(dep)) {
          AppLogger.info('  ✅ $dep');
        } else {
          AppLogger.warning('  ❌ $dep - MISSING');
        }
      }
    } else {
      AppLogger.error('  ❌ pubspec.yaml not found');
    }
  } catch (e) {
    AppLogger.error('  ❌ Error reading pubspec.yaml: $e');
  }
}

Future<void> _checkAndroidConfig() async {
  AppLogger.info('\n🤖 Checking Android configuration...');
  
  try {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (manifestFile.existsSync()) {
      final content = manifestFile.readAsStringSync();
      
      if (content.contains('ACCESS_FINE_LOCATION')) {
        AppLogger.info('  ✅ Location permissions');
      } else {
        AppLogger.warning('  ❌ Location permissions - MISSING');
      }
      
      if (content.contains('com.google.android.geo.API_KEY')) {
        AppLogger.info('  ✅ Google Maps API key configuration');
        if (content.contains('YOUR_GOOGLE_MAPS_API_KEY_HERE')) {
          AppLogger.warning('  ⚠️  API key placeholder needs to be replaced');
        }
      } else {
        AppLogger.warning('  ❌ Google Maps API key - MISSING');
      }
    } else {
      AppLogger.error('  ❌ AndroidManifest.xml not found');
    }
  } catch (e) {
    AppLogger.error('  ❌ Error reading AndroidManifest.xml: $e');
  }
}

Future<void> _checkIOSConfig() async {
  AppLogger.info('\n🍎 Checking iOS configuration...');
  
  try {
    final infoPlistFile = File('ios/Runner/Info.plist');
    if (infoPlistFile.existsSync()) {
      final content = infoPlistFile.readAsStringSync();
      
      if (content.contains('NSLocationWhenInUseUsageDescription')) {
        AppLogger.info('  ✅ Location permissions');
      } else {
        AppLogger.warning('  ❌ Location permissions - MISSING');
      }
      
      if (content.contains('io.flutter.embedded_views_preview')) {
        AppLogger.info('  ✅ Google Maps configuration');
      } else {
        AppLogger.warning('  ❌ Google Maps configuration - MISSING');
      }
    } else {
      AppLogger.error('  ❌ Info.plist not found');
    }
    
    final googleServiceFile = File('ios/Runner/GoogleService-Info.plist');
    if (googleServiceFile.existsSync()) {
      final content = googleServiceFile.readAsStringSync();
      if (content.contains('YOUR_GOOGLE_MAPS_API_KEY_HERE')) {
        AppLogger.warning('  ⚠️  API key placeholder needs to be replaced');
      } else {
        AppLogger.info('  ✅ GoogleService-Info.plist configured');
      }
    } else {
      AppLogger.error('  ❌ GoogleService-Info.plist not found');
    }
    
    final appDelegateFile = File('ios/Runner/AppDelegate.swift');
    if (appDelegateFile.existsSync()) {
      final content = appDelegateFile.readAsStringSync();
      if (content.contains('GMSServices.provideAPIKey')) {
        AppLogger.info('  ✅ AppDelegate configured for Google Maps');
      } else {
        AppLogger.warning('  ❌ AppDelegate not configured for Google Maps');
      }
    } else {
      AppLogger.error('  ❌ AppDelegate.swift not found');
    }
  } catch (e) {
    AppLogger.error('  ❌ Error reading iOS configuration: $e');
  }
}
