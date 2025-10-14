import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenRouteService {
  // You can get a free API key from https://openrouteservice.org/
  // For demo purposes, we'll use a mock implementation
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions';
  
  // Free tier allows 2000 requests/day
  // Get your free API key at: https://openrouteservice.org/dev/#/signup
  // 🔑 REPLACE THE KEY BELOW WITH YOUR ACTUAL API KEY FROM OPENROUTESERVICE.ORG
  static const String _apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjZmNTVlMjFmZTJmYzQ0OWFiYTlkMTczNmI4OWE4ZDE5IiwiaCI6Im11cm11cjY0In0='; // ← PUT YOUR API KEY HERE
  
  /// Get directions between two points using OpenRouteService
  static Future<RouteResult?> getDirections({
    required LatLng start,
    required LatLng end,
    String profile = 'foot-walking', // foot-walking, driving-car, cycling-regular
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$profile/geojson'),
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': [
            [start.longitude, start.latitude],
            [end.longitude, end.latitude],
          ],
          'format': 'geojson',
          'instructions': true,
          'geometry': true,
          'maneuvers': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseRouteResult(data);
      } else {
        print('OpenRouteService error: ${response.statusCode} - ${response.body}');
        return _getMockRoute(start, end);
      }
    } catch (e) {
      print('Error getting directions: $e');
      return _getMockRoute(start, end);
    }
  }

  /// Parse OpenRouteService response
  static RouteResult? _parseRouteResult(Map<String, dynamic> data) {
    try {
      final features = data['features'] as List;
      if (features.isEmpty) return null;

      final feature = features.first;
      final properties = feature['properties'];
      final geometry = feature['geometry'];
      
      final coordinates = geometry['coordinates'] as List;
      final routePoints = coordinates.map((coord) => 
        LatLng(coord[1].toDouble(), coord[0].toDouble())
      ).toList();

      final summary = properties['summary'];
      final duration = (summary['duration'] ?? 0).toDouble();
      final distance = (summary['distance'] ?? 0).toDouble();

      final segments = properties['segments'] as List?;
      final instructions = <NavigationInstruction>[];
      
      if (segments != null) {
        for (final segment in segments) {
          final steps = segment['steps'] as List;
          for (final step in steps) {
            final instruction = step['instruction'] as String;
            final distance = (step['distance'] ?? 0).toDouble();
            final duration = (step['duration'] ?? 0).toDouble();
            
            instructions.add(NavigationInstruction(
              instruction: instruction,
              distance: distance,
              duration: duration,
            ));
          }
        }
      }

      return RouteResult(
        points: routePoints,
        distance: distance,
        duration: duration,
        instructions: instructions,
      );
    } catch (e) {
      print('Error parsing route result: $e');
      return null;
    }
  }

  /// Mock route for when API is not available
  static RouteResult _getMockRoute(LatLng start, LatLng end) {
    // Calculate a simple straight-line route with some waypoints
    final distance = const Distance().as(LengthUnit.Meter, start, end);
    final bearing = const Distance().bearing(start, end);
    
    final routePoints = <LatLng>[];
    final numPoints = (distance / 50).ceil(); // Points every 50 meters
    
    for (int i = 0; i <= numPoints; i++) {
      final fraction = i / numPoints;
      final point = const Distance().offset(start, distance * fraction, bearing);
      routePoints.add(point);
    }

    final instructions = <NavigationInstruction>[
      NavigationInstruction(
        instruction: 'Head ${_getDirection(bearing)} for ${_formatDistance(distance)}',
        distance: distance,
        duration: distance / 1.4, // Walking speed ~1.4 m/s
      ),
      NavigationInstruction(
        instruction: 'Arrive at destination',
        distance: 0,
        duration: 0,
      ),
    ];

    return RouteResult(
      points: routePoints,
      distance: distance,
      duration: distance / 1.4,
      instructions: instructions,
    );
  }

  static String _getDirection(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'north';
    if (bearing >= 22.5 && bearing < 67.5) return 'northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'east';
    if (bearing >= 112.5 && bearing < 157.5) return 'southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'south';
    if (bearing >= 202.5 && bearing < 247.5) return 'southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'west';
    return 'northwest';
  }

  static String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distance;
  final double duration;
  final List<NavigationInstruction> instructions;

  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
    required this.instructions,
  });
}

class NavigationInstruction {
  final String instruction;
  final double distance;
  final double duration;

  NavigationInstruction({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String get formattedDuration {
    final minutes = (duration / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }
}
