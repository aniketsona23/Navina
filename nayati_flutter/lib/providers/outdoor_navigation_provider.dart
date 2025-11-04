import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/outdoor_navigation_service.dart';

class OutdoorNavigationProvider extends ChangeNotifier {
  Position? _currentPosition;
  Position? _destinationPosition;
  String _destinationName = '';
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _currentRoute;
  List<Map<String, dynamic>> _navigationSteps = [];
  bool _isNavigating = false;
  bool _isLoading = false;
  String _error = '';

  // Getters
  Position? get currentPosition => _currentPosition;
  Position? get destinationPosition => _destinationPosition;
  String get destinationName => _destinationName;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  Map<String, dynamic>? get currentRoute => _currentRoute;
  List<Map<String, dynamic>> get navigationSteps => _navigationSteps;
  bool get isNavigating => _isNavigating;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Set current position
  void setCurrentPosition(Position position) {
    _currentPosition = position;
    notifyListeners();
  }

  // Search for destinations
  Future<void> searchDestination(String query) async {
    if (_currentPosition == null || query.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      _searchResults = await OutdoorNavigationService.searchDestination(
        query: query,
        currentPosition: _currentPosition!,
      );
    } catch (e) {
      _setError('Failed to search destination: $e');
    }

    _setLoading(false);
  }

  // Set destination
  void setDestination(Position position, String name) {
    _destinationPosition = position;
    _destinationName = name;
    notifyListeners();
  }

  // Get directions
  Future<void> getDirections() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    _setLoading(true);
    _clearError();

    try {
      _currentRoute = await OutdoorNavigationService.getDirections(
        origin: _currentPosition!,
        destination: _destinationPosition!,
      );

      // Extract navigation steps from the route
      if (_currentRoute != null && _currentRoute!['routes'].isNotEmpty) {
        final route = _currentRoute!['routes'][0];
        if (route['legs'].isNotEmpty && route['legs'][0]['steps'].isNotEmpty) {
          _navigationSteps = List<Map<String, dynamic>>.from(
            route['legs'][0]['steps'].map((step) => {
                  'instruction': step['instruction'],
                  'distance': step['distance']['text'],
                  'duration': step['duration']['text'],
                  'accessibility_features':
                      step['accessibility_features'] ?? [],
                  'hazards': step['hazards'] ?? [],
                }),
          );
        }
      }
    } catch (e) {
      _setError('Failed to get directions: $e');
    }

    _setLoading(false);
  }

  // Start navigation
  void startNavigation() {
    if (_currentRoute != null && _navigationSteps.isNotEmpty) {
      _isNavigating = true;
      notifyListeners();
    }
  }

  // Stop navigation
  void stopNavigation() {
    _isNavigating = false;
    notifyListeners();
  }

  // Create and save navigation route
  Future<void> createNavigationRoute() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    try {
      await OutdoorNavigationService.createNavigationRoute(
        origin: _currentPosition!,
        destination: _destinationPosition!,
        routeType: 'outdoor',
      );
    } catch (e) {
      _setError('Failed to save route: $e');
    }
  }

  // Update current location
  Future<void> updateCurrentLocation() async {
    try {
      // Ensure permissions are granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setError('Location permissions are denied.');
        return;
      }

      // Use the new locationSettings parameter (desiredAccuracy deprecated)
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setCurrentPosition(position);

      // Update location on server
      await OutdoorNavigationService.updateLocation(position);
    } catch (e) {
      _setError('Failed to update location: $e');
    }
  }

  // Report obstacle
  Future<void> reportObstacle({
    required Position position,
    required String obstacleType,
    required String description,
    required String severity,
  }) async {
    try {
      await OutdoorNavigationService.reportObstacle(
        position: position,
        obstacleType: obstacleType,
        description: description,
        severity: severity,
      );
    } catch (e) {
      _setError('Failed to report obstacle: $e');
    }
  }

  // Get accessibility rating
  Future<Map<String, dynamic>?> getAccessibilityRating(
      Position position) async {
    try {
      return await OutdoorNavigationService.getAccessibilityRating(
          position: position);
    } catch (e) {
      _setError('Failed to get accessibility rating: $e');
      return null;
    }
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  // Clear destination
  void clearDestination() {
    _destinationPosition = null;
    _destinationName = '';
    _currentRoute = null;
    _navigationSteps.clear();
    notifyListeners();
  }

  // Clear all data
  void clearAll() {
    _currentPosition = null;
    _destinationPosition = null;
    _destinationName = '';
    _searchResults.clear();
    _currentRoute = null;
    _navigationSteps.clear();
    _isNavigating = false;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
    notifyListeners();
  }

  // Get distance between two positions
  double getDistanceBetween(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  // Get bearing between two positions
  double getBearingBetween(Position from, Position to) {
    return Geolocator.bearingBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }
}
