// Test script to verify outdoor navigation setup
// Run with: dart test_navigation.dart

import 'dart:io';

void main() async {
  print('🧪 Testing Outdoor Navigation Setup...\n');
  
  // Check if pubspec.yaml has required dependencies
  await _checkDependencies();
  
  // Check Android configuration
  await _checkAndroidConfig();
  
  // Check iOS configuration
  await _checkIOSConfig();
  
  print('\n✅ Setup verification complete!');
  print('\n📱 Next steps:');
  print('1. Run: flutter clean && flutter pub get');
  print('2. Run: flutter run');
  print('3. Navigate to Mobility Assist → Outdoor Nav');
  print('\n🗺️ FREE MAP OPTION (OpenStreetMap):');
  print('- ✅ Works immediately - NO API key needed!');
  print('- ✅ Shows your current location with blue dot');
  print('- ✅ Displays real street maps with building details');
  print('- ✅ Search destinations and get directions');
  print('- ✅ Completely free with no usage limits');
  print('\n🗺️ PAID MAP OPTION (Google Maps):');
  print('- ⚠️  Requires API key and billing setup');
  print('- ⚠️  Replace YOUR_GOOGLE_MAPS_API_KEY_HERE in config files');
  print('- ✅ Higher quality maps with more features');
}

Future<void> _checkDependencies() async {
  print('📦 Checking dependencies...');
  
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
          print('  ✅ $dep');
        } else {
          print('  ❌ $dep - MISSING');
        }
      }
    } else {
      print('  ❌ pubspec.yaml not found');
    }
  } catch (e) {
    print('  ❌ Error reading pubspec.yaml: $e');
  }
}

Future<void> _checkAndroidConfig() async {
  print('\n🤖 Checking Android configuration...');
  
  try {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (manifestFile.existsSync()) {
      final content = manifestFile.readAsStringSync();
      
      if (content.contains('ACCESS_FINE_LOCATION')) {
        print('  ✅ Location permissions');
      } else {
        print('  ❌ Location permissions - MISSING');
      }
      
      if (content.contains('com.google.android.geo.API_KEY')) {
        print('  ✅ Google Maps API key configuration');
        if (content.contains('YOUR_GOOGLE_MAPS_API_KEY_HERE')) {
          print('  ⚠️  API key placeholder needs to be replaced');
        }
      } else {
        print('  ❌ Google Maps API key - MISSING');
      }
    } else {
      print('  ❌ AndroidManifest.xml not found');
    }
  } catch (e) {
    print('  ❌ Error reading AndroidManifest.xml: $e');
  }
}

Future<void> _checkIOSConfig() async {
  print('\n🍎 Checking iOS configuration...');
  
  try {
    final infoPlistFile = File('ios/Runner/Info.plist');
    if (infoPlistFile.existsSync()) {
      final content = infoPlistFile.readAsStringSync();
      
      if (content.contains('NSLocationWhenInUseUsageDescription')) {
        print('  ✅ Location permissions');
      } else {
        print('  ❌ Location permissions - MISSING');
      }
      
      if (content.contains('io.flutter.embedded_views_preview')) {
        print('  ✅ Google Maps configuration');
      } else {
        print('  ❌ Google Maps configuration - MISSING');
      }
    } else {
      print('  ❌ Info.plist not found');
    }
    
    final googleServiceFile = File('ios/Runner/GoogleService-Info.plist');
    if (googleServiceFile.existsSync()) {
      final content = googleServiceFile.readAsStringSync();
      if (content.contains('YOUR_GOOGLE_MAPS_API_KEY_HERE')) {
        print('  ⚠️  API key placeholder needs to be replaced');
      } else {
        print('  ✅ GoogleService-Info.plist configured');
      }
    } else {
      print('  ❌ GoogleService-Info.plist not found');
    }
    
    final appDelegateFile = File('ios/Runner/AppDelegate.swift');
    if (appDelegateFile.existsSync()) {
      final content = appDelegateFile.readAsStringSync();
      if (content.contains('GMSServices.provideAPIKey')) {
        print('  ✅ AppDelegate configured for Google Maps');
      } else {
        print('  ❌ AppDelegate not configured for Google Maps');
      }
    } else {
      print('  ❌ AppDelegate.swift not found');
    }
  } catch (e) {
    print('  ❌ Error reading iOS configuration: $e');
  }
}
