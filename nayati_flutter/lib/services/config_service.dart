import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ConfigService {
  static const String _backendUrlKey = 'backend_url';
  
  // Default configurations
  static const String _defaultLocalUrl = 'http://localhost:8000/api';
  static const String _defaultNetworkUrl = 'http://10.30.8.17:8000/api';
  
  // Environment variable fallbacks
  static String? get _envBackendUrl => Platform.environment['BACKEND_URL'];
  static String? get _dartDefineBackendUrl => const String.fromEnvironment('BACKEND_URL');
  
  static SharedPreferences? _prefs;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get the backend URL with priority order:
  /// 1. User-saved preference (from settings)
  /// 2. Dart define environment variable
  /// 3. System environment variable
  /// 4. Default network URL (for team development)
  /// 5. Localhost fallback
  static Future<String> getBackendUrl() async {
    if (_prefs == null) {
      await initialize();
    }
    
    // 1. Check user preference first
    final savedUrl = _prefs?.getString(_backendUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }
    
    // 2. Check dart define environment variable
    if (_dartDefineBackendUrl != null && _dartDefineBackendUrl!.isNotEmpty) {
      return _dartDefineBackendUrl!;
    }
    
    // 3. Check system environment variable
    if (_envBackendUrl != null && _envBackendUrl!.isNotEmpty) {
      return _envBackendUrl!;
    }
    
    // 4. Try to detect if running on localhost vs network
    if (await _isNetworkAvailable(_defaultNetworkUrl)) {
      return _defaultNetworkUrl;
    }
    
    // 5. Fallback to localhost
    return _defaultLocalUrl;
  }
  
  /// Save a custom backend URL
  static Future<void> setBackendUrl(String url) async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs?.setString(_backendUrlKey, url);
  }
  
  /// Reset to default configuration
  static Future<void> resetToDefault() async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs?.remove(_backendUrlKey);
  }
  
  /// Get the currently saved URL (without fallbacks)
  static Future<String?> getSavedBackendUrl() async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs?.getString(_backendUrlKey);
  }
  
  /// Check if a URL is reachable
  static Future<bool> _isNetworkAvailable(String url) async {
    try {
      final uri = Uri.parse(url);
      final socket = await Socket.connect(uri.host, uri.port, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get all available configuration options
  static List<ConfigOption> getAvailableConfigs() {
    return [
      ConfigOption(
        name: 'Auto-detect',
        description: 'Automatically detect the best backend URL',
        url: null,
        isDefault: true,
      ),
      ConfigOption(
        name: 'Local Development',
        description: 'Connect to localhost backend',
        url: _defaultLocalUrl,
      ),
      ConfigOption(
        name: 'Team Network',
        description: 'Connect to team network backend (10.30.8.17)',
        url: _defaultNetworkUrl,
      ),
      ConfigOption(
        name: 'Custom',
        description: 'Enter a custom backend URL',
        url: null,
        isCustom: true,
      ),
    ];
  }
}

class ConfigOption {
  final String name;
  final String description;
  final String? url;
  final bool isDefault;
  final bool isCustom;
  
  ConfigOption({
    required this.name,
    required this.description,
    this.url,
    this.isDefault = false,
    this.isCustom = false,
  });
}
