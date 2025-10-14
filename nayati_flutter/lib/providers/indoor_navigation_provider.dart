import 'package:flutter/foundation.dart';
import '../services/indoor_navigation_service.dart';

class IndoorNavigationProvider extends ChangeNotifier {
  final IndoorNavigationService _indoorService = IndoorNavigationService();
  
  // Navigation state
  bool _isNavigating = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentBuilding = '';
  String _currentFloor = '';
  String _currentRoom = '';
  String _destinationRoom = '';
  List<Map<String, dynamic>> _navigationSteps = [];
  int _currentStepIndex = 0;
  String _errorMessage = '';

  // Building and floor data
  List<String> _availableBuildings = [];
  List<String> _availableFloors = [];
  Map<String, dynamic> _floorRooms = {};

  // Getters
  bool get isNavigating => _isNavigating;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentBuilding => _currentBuilding;
  String get currentFloor => _currentFloor;
  String get currentRoom => _currentRoom;
  String get destinationRoom => _destinationRoom;
  List<Map<String, dynamic>> get navigationSteps => _navigationSteps;
  int get currentStepIndex => _currentStepIndex;
  String get errorMessage => _errorMessage;
  List<String> get availableBuildings => _availableBuildings;
  List<String> get availableFloors => _availableFloors;
  Map<String, dynamic> get floorRooms => _floorRooms;

  // Get current step
  Map<String, dynamic>? get currentStep {
    if (_navigationSteps.isNotEmpty && _currentStepIndex < _navigationSteps.length) {
      return _navigationSteps[_currentStepIndex];
    }
    return null;
  }

  // Get progress percentage
  double get progressPercentage {
    if (_navigationSteps.isEmpty) return 0.0;
    return (_currentStepIndex + 1) / _navigationSteps.length;
  }

  // Initialize the provider
  Future<void> initialize() async {
    try {
      _availableBuildings = _indoorService.getAvailableBuildings();
      await _indoorService.initializeSpeechRecognition();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize indoor navigation: $e';
      notifyListeners();
    }
  }

  // Load building details
  Future<void> loadBuilding(String buildingId) async {
    try {
      _currentBuilding = buildingId;
      _availableFloors = _indoorService.getFloors(buildingId);
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load building: $e';
      notifyListeners();
    }
  }

  // Load floor rooms
  Future<void> loadFloor(String floorId) async {
    try {
      _currentFloor = floorId;
      final floorData = _indoorService.getFloorRooms(_currentBuilding, floorId);
      if (floorData != null) {
        _floorRooms = floorData['rooms'] as Map<String, dynamic>;
      }
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load floor: $e';
      notifyListeners();
    }
  }

  // Start navigation
  Future<void> startNavigation({
    required String startRoom,
    required String endRoom,
  }) async {
    try {
      _currentRoom = startRoom;
      _destinationRoom = endRoom;
      
      // Find path
      _navigationSteps = _indoorService.findPath(
        buildingId: _currentBuilding,
        floorId: _currentFloor,
        startRoom: startRoom,
        endRoom: endRoom,
      );

      if (_navigationSteps.isEmpty) {
        _errorMessage = 'No path found to destination';
        notifyListeners();
        return;
      }

      _currentStepIndex = 0;
      _isNavigating = true;
      _errorMessage = '';

      // Speak first instruction
      if (_navigationSteps.isNotEmpty) {
        await _indoorService.speak(_navigationSteps[0]['instruction']);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start navigation: $e';
      notifyListeners();
    }
  }

  // Move to next step
  Future<void> nextStep() async {
    if (_currentStepIndex < _navigationSteps.length - 1) {
      _currentStepIndex++;
      
      // Update current room
      if (_currentStepIndex < _navigationSteps.length) {
        _currentRoom = _navigationSteps[_currentStepIndex]['room'];
      }

      // Speak next instruction
      if (_currentStepIndex < _navigationSteps.length) {
        await _indoorService.speak(_navigationSteps[_currentStepIndex]['instruction']);
      }

      notifyListeners();
    } else {
      // Navigation completed
      await completeNavigation();
    }
  }

  // Move to previous step
  Future<void> previousStep() async {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      
      // Update current room
      if (_currentStepIndex < _navigationSteps.length) {
        _currentRoom = _navigationSteps[_currentStepIndex]['room'];
      }

      notifyListeners();
    }
  }

  // Complete navigation
  Future<void> completeNavigation() async {
    _isNavigating = false;
    _currentStepIndex = 0;
    _navigationSteps.clear();
    _currentRoom = '';
    _destinationRoom = '';
    
    await _indoorService.speak('You have reached your destination. Navigation completed.');
    notifyListeners();
  }

  // Stop navigation
  Future<void> stopNavigation() async {
    _isNavigating = false;
    _currentStepIndex = 0;
    _navigationSteps.clear();
    _currentRoom = '';
    _destinationRoom = '';
    
    await _indoorService.stopSpeaking();
    notifyListeners();
  }

  // Start voice listening
  Future<void> startListening() async {
    try {
      _isListening = true;
      _errorMessage = '';
      notifyListeners();

      await _indoorService.startListening((result) {
        _handleVoiceCommand(result);
      });
    } catch (e) {
      _errorMessage = 'Failed to start listening: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  // Stop voice listening
  Future<void> stopListening() async {
    await _indoorService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  // Handle voice commands
  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('next') || lowerCommand.contains('continue')) {
      nextStep();
    } else if (lowerCommand.contains('previous') || lowerCommand.contains('back')) {
      previousStep();
    } else if (lowerCommand.contains('stop') || lowerCommand.contains('end')) {
      stopNavigation();
    } else if (lowerCommand.contains('repeat') || lowerCommand.contains('again')) {
      _repeatCurrentInstruction();
    } else if (lowerCommand.contains('help')) {
      _speakHelp();
    }
  }

  // Repeat current instruction
  Future<void> _repeatCurrentInstruction() async {
    if (currentStep != null) {
      await _indoorService.speak(currentStep!['instruction']);
    }
  }

  // Speak help instructions
  Future<void> _speakHelp() async {
    const helpText = 'You can say: next to continue, previous to go back, stop to end navigation, or repeat to hear the current instruction again.';
    await _indoorService.speak(helpText);
  }

  // Speak current instruction
  Future<void> speakCurrentInstruction() async {
    if (currentStep != null) {
      await _indoorService.speak(currentStep!['instruction']);
    }
  }

  // Toggle voice guidance
  Future<void> toggleVoiceGuidance() async {
    if (_isSpeaking) {
      await _indoorService.stopSpeaking();
      _isSpeaking = false;
    } else {
      _isSpeaking = true;
      if (currentStep != null) {
        await _indoorService.speak(currentStep!['instruction']);
      }
    }
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get building details
  Map<String, dynamic>? getBuildingDetails(String buildingId) {
    return _indoorService.getBuildingDetails(buildingId);
  }

  // Get floor rooms
  Map<String, dynamic>? getFloorRooms(String buildingId, String floorId) {
    return _indoorService.getFloorRooms(buildingId, floorId);
  }

  // Reset provider state
  void reset() {
    _isNavigating = false;
    _isListening = false;
    _isSpeaking = false;
    _currentBuilding = '';
    _currentFloor = '';
    _currentRoom = '';
    _destinationRoom = '';
    _navigationSteps.clear();
    _currentStepIndex = 0;
    _errorMessage = '';
    _availableFloors.clear();
    _floorRooms.clear();
    notifyListeners();
  }
}
