import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class OutdoorNavigationService {
  // API Configuration - Change this URL for different environments
  static const String _apiBaseUrl = 'http://localhost:8000/api/mobility-assist';
  static const String baseUrl = _apiBaseUrl;
  
  // Search for destinations
  static Future<List<Map<String, dynamic>>> searchDestination({
    required String query,
    required Position currentPosition,
    double radius = 5000,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search-destination/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'query': query,
          'latitude': currentPosition.latitude,
          'longitude': currentPosition.longitude,
          'radius': radius,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Failed to search destination: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching destination: $e');
    }
  }

  // Get directions between two points
  static Future<Map<String, dynamic>> getDirections({
    required Position origin,
    required Position destination,
    String mode = 'walking',
    Map<String, dynamic>? accessibilityPreferences,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get-directions/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'origin_latitude': origin.latitude,
          'origin_longitude': origin.longitude,
          'destination_latitude': destination.latitude,
          'destination_longitude': destination.longitude,
          'mode': mode,
          'accessibility_preferences': accessibilityPreferences ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting directions: $e');
    }
  }

  // Create a navigation route
  static Future<Map<String, dynamic>> createNavigationRoute({
    required Position origin,
    required Position destination,
    Map<String, dynamic>? accessibilityPreferences,
    String routeType = 'outdoor',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-route/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'start_latitude': origin.latitude,
          'start_longitude': origin.longitude,
          'end_latitude': destination.latitude,
          'end_longitude': destination.longitude,
          'accessibility_preferences': accessibilityPreferences ?? {},
          'route_type': routeType,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create route: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating route: $e');
    }
  }

  // Get nearby accessible locations
  static Future<List<Map<String, dynamic>>> getNearbyAccessibleLocations({
    required Position currentPosition,
    double radius = 1000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/nearby-accessible/?latitude=${currentPosition.latitude}&longitude=${currentPosition.longitude}&radius=$radius'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to get nearby locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting nearby locations: $e');
    }
  }

  // Update user location
  static Future<void> updateLocation(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-location/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'heading': position.heading,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  // Report an obstacle
  static Future<void> reportObstacle({
    required Position position,
    required String obstacleType,
    required String description,
    required String severity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/report-obstacle/'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'obstacle_type': obstacleType,
          'description': description,
          'severity': severity,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to report obstacle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reporting obstacle: $e');
    }
  }

  // Get accessibility rating for a location
  static Future<Map<String, dynamic>> getAccessibilityRating({
    required Position position,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accessibility-rating/?latitude=${position.latitude}&longitude=${position.longitude}'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get accessibility rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting accessibility rating: $e');
    }
  }
}
