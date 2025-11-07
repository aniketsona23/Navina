import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _baseUrl = 'http://10.30.11.234:8000/api';
  String? _token;
  String? _username;

  // Get current token
  String? get token => _token;
  String? get username => _username;
  bool get isAuthenticated => _token != null;

  // Initialize authentication
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
  }

  // Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _username = username;
        
        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('username', username);
        
        return {
          'success': true,
          'token': _token,
          'username': username,
        };
      } else {
        return {
          'success': false,
          'error': 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Login error: $e',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _username = username;
        
        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('username', username);
        
        return {
          'success': true,
          'token': _token,
          'username': username,
        };
      } else {
        return {
          'success': false,
          'error': 'Registration failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration error: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _username = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
  }

  // Get authentication headers
  Map<String, String> getAuthHeaders() {
    if (_token != null) {
      return {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Get authentication headers for multipart requests
  Map<String, String> getAuthHeadersMultipart() {
    if (_token != null) {
      return {
        'Authorization': 'Token $_token',
      };
    }
    return {};
  }

  // Test authentication
  Future<bool> testAuth() async {
    if (_token == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile/'),
        headers: getAuthHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
