import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/open_route_service.dart';

class FreeOutdoorNavigationScreen extends StatefulWidget {
  const FreeOutdoorNavigationScreen({super.key});

  @override
  State<FreeOutdoorNavigationScreen> createState() => _FreeOutdoorNavigationScreenState();
}

class _FreeOutdoorNavigationScreenState extends State<FreeOutdoorNavigationScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  LatLng? _destination;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _isNavigating = false;
  bool _isLoading = false;
  bool _isLocationLoaded = false;
  String _destinationName = '';
  RouteResult? _currentRoute;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopLocationUpdates();
    super.dispose();
  }

  // Stream for continuous location updates
  StreamSubscription<Position>? _locationSubscription;

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _addCurrentLocationMarker();
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled. Please enable them to use navigation.');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied. Please enable them to use navigation.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _isLocationLoaded = true;
      });

      // Move camera to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16.0, // Good zoom level to see surrounding area
      );

      // Add current location marker
      _addCurrentLocationMarker();
      
      // Start continuous location updates
      _startLocationUpdates();
    } catch (e) {
      setState(() => _isLoading = false);
      _showLocationError('Error getting location: ${e.toString()}');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        // Remove existing current location marker
        _markers.removeWhere((marker) => marker.key == const Key('current_location'));
        
        // Add new current location marker
        _markers.add(
          Marker(
            key: const Key('current_location'),
            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      });
    }
  }

  Future<void> _searchDestination() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng destination = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _destination = destination;
          _destinationName = _searchController.text;
        });

        // Remove existing destination marker
        _markers.removeWhere((marker) => marker.key == const Key('destination'));
        
        // Add destination marker
        _markers.add(
          Marker(
            key: const Key('destination'),
            point: destination,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );

        // Move camera to show both locations
        if (_currentPosition != null) {
          final bounds = LatLngBounds.fromPoints([
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            destination,
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }

        // Calculate route (mock implementation)
        _calculateRoute();
      } else {
        _showLocationError('Location not found. Please try a different search term.');
      }
    } catch (e) {
      _showLocationError('Error searching for location: ${e.toString()}');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _calculateRoute() async {
    if (_currentPosition == null || _destination == null) return;

    setState(() => _isLoading = true);

    try {
      // Get real directions from OpenRouteService
      final route = await OpenRouteService.getDirections(
        start: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        end: _destination!,
        profile: 'foot-walking', // Use walking directions for accessibility
      );

      if (route != null) {
        setState(() {
          _currentRoute = route;
          _polylines = [
            Polyline(
              points: route.points,
              color: AppTheme.mobilityAssistColor,
              strokeWidth: 5.0,
              borderColor: Colors.white,
              borderStrokeWidth: 2.0,
            ),
          ];
        });

        // Fit camera to show the entire route
        if (route.points.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(route.points);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }
      }
    } catch (e) {
      print('Error calculating route: $e');
      // Fallback to mock route
      _calculateMockRoute();
    }

    setState(() => _isLoading = false);
  }

  void _calculateMockRoute() {
    if (_currentPosition == null || _destination == null) return;

    // Mock route calculation as fallback
    List<LatLng> mockRoute = [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(
        (_currentPosition!.latitude + _destination!.latitude) / 2,
        (_currentPosition!.longitude + _destination!.longitude) / 2,
      ),
      _destination!,
    ];

    setState(() {
      _polylines = [
        Polyline(
          points: mockRoute,
          color: AppTheme.mobilityAssistColor,
          strokeWidth: 5.0,
        ),
      ];
    });
  }

  void _startNavigation() {
    if (_destination == null) return;

    setState(() {
      _isNavigating = true;
    });

    _showNavigationInstructions();
  }

  void _showNavigationInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.navigation,
                          color: AppTheme.mobilityAssistColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Navigation Active',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Destination: $_destinationName',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isNavigating = false;
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.stop),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Show route summary
                    if (_currentRoute != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.mobilityAssistColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.directions_walk,
                                  color: AppTheme.mobilityAssistColor,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDistance(_currentRoute!.distance),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.mobilityAssistColor,
                                  ),
                                ),
                                const Text(
                                  'Distance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  color: AppTheme.mobilityAssistColor,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDuration(_currentRoute!.duration),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.mobilityAssistColor,
                                  ),
                                ),
                                const Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Show turn-by-turn instructions
                    if (_currentRoute != null && _currentRoute!.instructions.isNotEmpty) ...[
                      const Text(
                        'Turn-by-Turn Directions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._currentRoute!.instructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final instruction = entry.value;
                        return _buildNavigationStep(
                          instruction.instruction,
                          instruction.formattedDistance,
                          _getInstructionIcon(instruction.instruction),
                          index == 0, // First instruction is current
                        );
                      }).toList(),
                    ] else ...[
                      // Fallback instructions
                      _buildNavigationStep(
                        'Head towards destination',
                        _currentRoute != null ? _formatDistance(_currentRoute!.distance) : 'Calculating...',
                        Icons.navigation,
                        true,
                      ),
                      _buildNavigationStep(
                        'Follow the route on the map',
                        'Continue straight',
                        Icons.map,
                        false,
                      ),
                      _buildNavigationStep(
                        'Arrive at destination',
                        '0 m',
                        Icons.location_on,
                        false,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationStep(String instruction, String distance, IconData icon, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.mobilityAssistColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppTheme.mobilityAssistColor : Colors.grey[300]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent ? AppTheme.mobilityAssistColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isCurrent ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCurrent ? AppTheme.mobilityAssistColor : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            const Icon(
              Icons.arrow_forward,
              color: AppTheme.mobilityAssistColor,
              size: 20,
            ),
        ],
      ),
    );
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => Geolocator.openLocationSettings(),
        ),
      ),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_currentPosition != null) {
      // Center camera on current location
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
    } else {
      // If no current position, get it first
      await _getCurrentLocation();
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatDuration(double duration) {
    final minutes = (duration / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }

  IconData _getInstructionIcon(String instruction) {
    final lowerInstruction = instruction.toLowerCase();
    if (lowerInstruction.contains('turn left')) {
      return Icons.turn_left;
    } else if (lowerInstruction.contains('turn right')) {
      return Icons.turn_right;
    } else if (lowerInstruction.contains('straight') || lowerInstruction.contains('continue')) {
      return Icons.straight;
    } else if (lowerInstruction.contains('head north')) {
      return Icons.north;
    } else if (lowerInstruction.contains('head south')) {
      return Icons.south;
    } else if (lowerInstruction.contains('head east')) {
      return Icons.east;
    } else if (lowerInstruction.contains('head west')) {
      return Icons.west;
    } else if (lowerInstruction.contains('arrive') || lowerInstruction.contains('destination')) {
      return Icons.location_on;
    } else {
      return Icons.navigation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Free Outdoor Navigation'),
        backgroundColor: AppTheme.mobilityAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Free OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(37.7749, -122.4194), // Default to San Francisco
              initialZoom: 16.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nayati_flutter',
                maxZoom: 18,
              ),
              
              // Route polylines
              if (_polylines.isNotEmpty)
                PolylineLayer(
                  polylines: _polylines,
                ),
              
              // Markers
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _destination = null;
                              _destinationName = '';
                              _markers.removeWhere((marker) => marker.key == const Key('destination'));
                              _polylines.clear();
                            });
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _searchDestination(),
              ),
            ),
          ),
          
          // Navigation Controls
          if (_destination != null && !_isNavigating)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.mobilityAssistColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Route Ready',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                _destinationName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (_currentRoute != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDistance(_currentRoute!.distance),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.timer,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(_currentRoute!.duration),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startNavigation,
                        icon: const Icon(Icons.navigation),
                        label: const Text('Start Navigation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mobilityAssistColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Current Location Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerOnCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(
                _isLoading ? Icons.refresh : Icons.my_location,
                color: AppTheme.mobilityAssistColor,
              ),
            ),
          ),
          
          // Loading indicator when getting location
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.mobilityAssistColor,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Getting your location...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Location status indicator
          if (_currentPosition != null && !_isLoading)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GPS: ${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Free map indicator
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'OpenStreetMap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
