// Quick script to get your app's package name and bundle ID
// Run with: dart get_app_info.dart

import 'dart:io';

void main() {
  print('🔍 Getting your app information for Google Maps API setup...\n');
  
  // Get package name from pubspec.yaml
  try {
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      final nameMatch = RegExp(r'name:\s*(.+)').firstMatch(content);
      if (nameMatch != null) {
        print('📦 Package Name: ${nameMatch.group(1)}');
      }
    }
  } catch (e) {
    print('❌ Could not read pubspec.yaml: $e');
  }
  
  // Get Android package name
  try {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (manifestFile.existsSync()) {
      final content = manifestFile.readAsStringSync();
      final packageMatch = RegExp(r'package="([^"]+)"').firstMatch(content);
      if (packageMatch != null) {
        print('🤖 Android Package: ${packageMatch.group(1)}');
      }
    }
  } catch (e) {
    print('❌ Could not read AndroidManifest.xml: $e');
  }
  
  // Get iOS bundle ID
  try {
    final infoPlistFile = File('ios/Runner/Info.plist');
    if (infoPlistFile.existsSync()) {
      final content = infoPlistFile.readAsStringSync();
      final bundleMatch = RegExp(r'<key>CFBundleIdentifier</key>\s*<string>([^<]+)</string>').firstMatch(content);
      if (bundleMatch != null) {
        print('🍎 iOS Bundle ID: ${bundleMatch.group(1)}');
      }
    }
  } catch (e) {
    print('❌ Could not read Info.plist: $e');
  }
  
  print('\n📋 Next Steps:');
  print('1. Go to Google Cloud Console');
  print('2. Create a new project or select existing');
  print('3. Enable Maps SDK for Android and iOS APIs');
  print('4. Create API key with the restrictions above');
  print('5. Replace YOUR_GOOGLE_MAPS_API_KEY_HERE in your config files');
  print('\n📖 See GOOGLE_MAPS_SETUP_GUIDE.md for detailed instructions');
}
