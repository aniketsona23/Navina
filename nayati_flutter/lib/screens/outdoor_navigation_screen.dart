import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OutdoorNavigationScreen extends StatefulWidget {
  const OutdoorNavigationScreen({super.key});

  @override
  State<OutdoorNavigationScreen> createState() => _OutdoorNavigationScreenState();
}

class _OutdoorNavigationScreenState extends State<OutdoorNavigationScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _destination;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoordinates = [];
  bool _isNavigating = false;
  bool _isLoading = false;
  bool _isLocationLoaded = false;
  String _destinationName = '';
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

      // Move camera to current location with proper zoom
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0, // Good zoom level to see surrounding area
            ),
          ),
        );
      }

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
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'Current position',
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

        // Add destination marker
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: _destinationName,
              snippet: 'Destination',
            ),
          ),
        );

        // Move camera to show both locations
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  (_currentPosition?.latitude ?? destination.latitude) - 0.01,
                  (_currentPosition?.longitude ?? destination.longitude) - 0.01,
                ),
                northeast: LatLng(
                  (_currentPosition?.latitude ?? destination.latitude) + 0.01,
                  (_currentPosition?.longitude ?? destination.longitude) + 0.01,
                ),
              ),
              100.0,
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

  void _calculateRoute() {
    if (_currentPosition == null || _destination == null) return;

    // Mock route calculation - in a real app, you would use Google Directions API
    List<LatLng> mockRoute = [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(
        (_currentPosition!.latitude + _destination!.latitude) / 2,
        (_currentPosition!.longitude + _destination!.longitude) / 2,
      ),
      _destination!,
    ];

    setState(() {
      _routeCoordinates = mockRoute;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: mockRoute,
          color: AppTheme.mobilityAssistColor,
          width: 5,
          patterns: [],
        ),
      );
    });
  }

  void _startNavigation() {
    if (_destination == null) return;

    setState(() {
      _isNavigating = true;
    });

    // In a real app, you would start turn-by-turn navigation here
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
                    _buildNavigationStep(
                      'Head north on Main Street',
                      '0.2 mi',
                      Icons.north,
                      true,
                    ),
                    _buildNavigationStep(
                      'Turn right onto Accessible Avenue',
                      '0.1 mi',
                      Icons.turn_right,
                      false,
                    ),
                    _buildNavigationStep(
                      'Continue straight for 500 meters',
                      '0.3 mi',
                      Icons.straight,
                      false,
                    ),
                    _buildNavigationStep(
                      'Arrive at destination',
                      '0 mi',
                      Icons.location_on,
                      false,
                    ),
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
    if (_currentPosition != null && _mapController != null) {
      // Center camera on current location with animation
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 16.0,
          ),
        ),
      );
    } else {
      // If no current position, get it first
      await _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Outdoor Navigation'),
        backgroundColor: AppTheme.mobilityAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // If location is already loaded, move camera to it
              if (_isLocationLoaded && _currentPosition != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 16.0,
                    ),
                  ),
                );
                _addCurrentLocationMarker();
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 16.0, // Better zoom level to see surrounding area
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
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
                              _markers.removeWhere((marker) => marker.markerId.value == 'destination');
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
                                'Destination Found',
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
                      'Location: ${_currentPosition!.accuracy.toStringAsFixed(0)}m',
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
        ],
      ),
    );
  }
}
