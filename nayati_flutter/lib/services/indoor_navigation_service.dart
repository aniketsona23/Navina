import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

class IndoorNavigationService {
  static final IndoorNavigationService _instance =
      IndoorNavigationService._internal();
  factory IndoorNavigationService() => _instance;
  IndoorNavigationService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isSpeaking = false;

  // Pre-fed indoor maps data
  static const Map<String, Map<String, dynamic>> _indoorMaps = {
    'university_main_building': {
      'name': 'University Main Building',
      'floors': {
        'ground': {
          'name': 'Ground Floor',
          'rooms': {
            'main_entrance': {
              'x': 50,
              'y': 100,
              'name': 'Main Entrance',
              'type': 'entrance'
            },
            'reception': {
              'x': 100,
              'y': 80,
              'name': 'Reception Desk',
              'type': 'service'
            },
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'cafeteria': {
              'x': 250,
              'y': 100,
              'name': 'Cafeteria',
              'type': 'dining'
            },
            'library_entrance': {
              'x': 300,
              'y': 80,
              'name': 'Library Entrance',
              'type': 'entrance'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
          },
          'connections': [
            {
              'from': 'main_entrance',
              'to': 'reception',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'elevator_a',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'elevator_b',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'cafeteria',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'cafeteria',
              'to': 'library_entrance',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
          ]
        },
        'first': {
          'name': 'First Floor',
          'rooms': {
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'room_101': {
              'x': 100,
              'y': 100,
              'name': 'Room 101',
              'type': 'classroom'
            },
            'room_102': {
              'x': 150,
              'y': 100,
              'name': 'Room 102',
              'type': 'classroom'
            },
            'room_103': {
              'x': 200,
              'y': 100,
              'name': 'Room 103',
              'type': 'classroom'
            },
            'room_104': {
              'x': 250,
              'y': 100,
              'name': 'Room 104',
              'type': 'classroom'
            },
            'professor_office_1': {
              'x': 100,
              'y': 150,
              'name': 'Professor Office 1',
              'type': 'office'
            },
            'professor_office_2': {
              'x': 150,
              'y': 150,
              'name': 'Professor Office 2',
              'type': 'office'
            },
            'conference_room': {
              'x': 200,
              'y': 150,
              'name': 'Conference Room',
              'type': 'meeting'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
          },
          'connections': [
            {
              'from': 'elevator_a',
              'to': 'room_101',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'room_102',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'room_103',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'room_104',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_101',
              'to': 'professor_office_1',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_102',
              'to': 'professor_office_2',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_103',
              'to': 'conference_room',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
          ]
        },
        'second': {
          'name': 'Second Floor',
          'rooms': {
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'room_201': {
              'x': 100,
              'y': 100,
              'name': 'Room 201',
              'type': 'classroom'
            },
            'room_202': {
              'x': 150,
              'y': 100,
              'name': 'Room 202',
              'type': 'classroom'
            },
            'room_203': {
              'x': 200,
              'y': 100,
              'name': 'Room 203',
              'type': 'classroom'
            },
            'room_204': {
              'x': 250,
              'y': 100,
              'name': 'Room 204',
              'type': 'classroom'
            },
            'computer_lab': {
              'x': 100,
              'y': 150,
              'name': 'Computer Lab',
              'type': 'lab'
            },
            'research_lab': {
              'x': 150,
              'y': 150,
              'name': 'Research Lab',
              'type': 'lab'
            },
            'library_reading_room': {
              'x': 200,
              'y': 150,
              'name': 'Library Reading Room',
              'type': 'study'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
          },
          'connections': [
            {
              'from': 'elevator_a',
              'to': 'room_201',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'room_202',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'room_203',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'room_204',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_201',
              'to': 'computer_lab',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_202',
              'to': 'research_lab',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'room_203',
              'to': 'library_reading_room',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
          ]
        }
      }
    },
    'shopping_mall': {
      'name': 'City Shopping Mall',
      'floors': {
        'ground': {
          'name': 'Ground Floor',
          'rooms': {
            'main_entrance': {
              'x': 50,
              'y': 100,
              'name': 'Main Entrance',
              'type': 'entrance'
            },
            'information_desk': {
              'x': 100,
              'y': 80,
              'name': 'Information Desk',
              'type': 'service'
            },
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'escalator_a': {
              'x': 250,
              'y': 50,
              'name': 'Escalator A',
              'type': 'escalator'
            },
            'escalator_b': {
              'x': 300,
              'y': 50,
              'name': 'Escalator B',
              'type': 'escalator'
            },
            'food_court': {
              'x': 200,
              'y': 150,
              'name': 'Food Court',
              'type': 'dining'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
            'atm': {'x': 180, 'y': 80, 'name': 'ATM', 'type': 'service'},
          },
          'connections': [
            {
              'from': 'main_entrance',
              'to': 'information_desk',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'information_desk',
              'to': 'elevator_a',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'information_desk',
              'to': 'elevator_b',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'escalator_a',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'escalator_b',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'escalator_a',
              'to': 'food_court',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'information_desk',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'information_desk',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
            {
              'from': 'information_desk',
              'to': 'atm',
              'distance': 80,
              'accessible': true
            },
          ]
        },
        'first': {
          'name': 'First Floor',
          'rooms': {
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'escalator_a': {
              'x': 250,
              'y': 50,
              'name': 'Escalator A',
              'type': 'escalator'
            },
            'escalator_b': {
              'x': 300,
              'y': 50,
              'name': 'Escalator B',
              'type': 'escalator'
            },
            'clothing_store_1': {
              'x': 100,
              'y': 100,
              'name': 'Fashion Store 1',
              'type': 'retail'
            },
            'clothing_store_2': {
              'x': 150,
              'y': 100,
              'name': 'Fashion Store 2',
              'type': 'retail'
            },
            'electronics_store': {
              'x': 200,
              'y': 100,
              'name': 'Electronics Store',
              'type': 'retail'
            },
            'bookstore': {
              'x': 250,
              'y': 100,
              'name': 'Bookstore',
              'type': 'retail'
            },
            'pharmacy': {
              'x': 100,
              'y': 150,
              'name': 'Pharmacy',
              'type': 'service'
            },
            'beauty_store': {
              'x': 150,
              'y': 150,
              'name': 'Beauty Store',
              'type': 'retail'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
          },
          'connections': [
            {
              'from': 'elevator_a',
              'to': 'clothing_store_1',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'clothing_store_2',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'electronics_store',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'bookstore',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'clothing_store_1',
              'to': 'pharmacy',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'clothing_store_2',
              'to': 'beauty_store',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
          ]
        }
      }
    },
    'hospital': {
      'name': 'City General Hospital',
      'floors': {
        'ground': {
          'name': 'Ground Floor',
          'rooms': {
            'main_entrance': {
              'x': 50,
              'y': 100,
              'name': 'Main Entrance',
              'type': 'entrance'
            },
            'reception': {
              'x': 100,
              'y': 80,
              'name': 'Reception Desk',
              'type': 'service'
            },
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'emergency_entrance': {
              'x': 250,
              'y': 100,
              'name': 'Emergency Entrance',
              'type': 'entrance'
            },
            'pharmacy': {
              'x': 100,
              'y': 150,
              'name': 'Pharmacy',
              'type': 'service'
            },
            'cafeteria': {
              'x': 200,
              'y': 150,
              'name': 'Cafeteria',
              'type': 'dining'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
            'atm': {'x': 180, 'y': 80, 'name': 'ATM', 'type': 'service'},
          },
          'connections': [
            {
              'from': 'main_entrance',
              'to': 'reception',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'elevator_a',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'elevator_b',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'emergency_entrance',
              'distance': 100,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'pharmacy',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'cafeteria',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
            {
              'from': 'reception',
              'to': 'atm',
              'distance': 80,
              'accessible': true
            },
          ]
        },
        'first': {
          'name': 'First Floor',
          'rooms': {
            'elevator_a': {
              'x': 150,
              'y': 50,
              'name': 'Elevator A',
              'type': 'elevator'
            },
            'elevator_b': {
              'x': 200,
              'y': 50,
              'name': 'Elevator B',
              'type': 'elevator'
            },
            'ward_101': {
              'x': 100,
              'y': 100,
              'name': 'Ward 101',
              'type': 'ward'
            },
            'ward_102': {
              'x': 150,
              'y': 100,
              'name': 'Ward 102',
              'type': 'ward'
            },
            'ward_103': {
              'x': 200,
              'y': '100',
              'name': 'Ward 103',
              'type': 'ward'
            },
            'ward_104': {
              'x': 250,
              'y': 100,
              'name': 'Ward 104',
              'type': 'ward'
            },
            'nurse_station': {
              'x': 150,
              'y': 150,
              'name': 'Nurse Station',
              'type': 'service'
            },
            'doctor_office_1': {
              'x': 100,
              'y': 150,
              'name': 'Doctor Office 1',
              'type': 'office'
            },
            'doctor_office_2': {
              'x': 200,
              'y': 150,
              'name': 'Doctor Office 2',
              'type': 'office'
            },
            'restroom_male': {
              'x': 80,
              'y': 120,
              'name': 'Men\'s Restroom',
              'type': 'restroom'
            },
            'restroom_female': {
              'x': 120,
              'y': 120,
              'name': 'Women\'s Restroom',
              'type': 'restroom'
            },
          },
          'connections': [
            {
              'from': 'elevator_a',
              'to': 'ward_101',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'ward_102',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'ward_103',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'elevator_b',
              'to': 'ward_104',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'ward_101',
              'to': 'doctor_office_1',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'ward_102',
              'to': 'nurse_station',
              'distance': 0,
              'accessible': true
            },
            {
              'from': 'ward_103',
              'to': 'doctor_office_2',
              'distance': 50,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_male',
              'distance': 30,
              'accessible': true
            },
            {
              'from': 'elevator_a',
              'to': 'restroom_female',
              'distance': 20,
              'accessible': true
            },
          ]
        }
      }
    }
  };

  // Get available buildings
  List<String> getAvailableBuildings() {
    return _indoorMaps.keys.toList();
  }

  // Get building details
  Map<String, dynamic>? getBuildingDetails(String buildingId) {
    return _indoorMaps[buildingId];
  }

  // Get floors for a building
  List<String> getFloors(String buildingId) {
    final building = _indoorMaps[buildingId];
    if (building == null) return [];
    return building['floors'].keys.toList();
  }

  // Get rooms for a specific floor
  Map<String, dynamic>? getFloorRooms(String buildingId, String floorId) {
    final building = _indoorMaps[buildingId];
    if (building == null) return null;
    return building['floors'][floorId];
  }

  // Find path between two rooms
  List<Map<String, dynamic>> findPath({
    required String buildingId,
    required String floorId,
    required String startRoom,
    required String endRoom,
  }) {
    final floor = getFloorRooms(buildingId, floorId);
    if (floor == null) return [];

    final rooms = floor['rooms'] as Map<String, dynamic>;
    final connections = floor['connections'] as List<dynamic>;

    // Simple pathfinding using BFS
    final queue = <String>[];
    final visited = <String>{};
    final parent = <String, String>{};

    queue.add(startRoom);
    visited.add(startRoom);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current == endRoom) {
        // Reconstruct path
        final path = <String>[];
        String? node = endRoom;
        while (node != null) {
          path.insert(0, node);
          node = parent[node];
        }
        return _convertPathToInstructions(path, rooms, connections);
      }

      // Find connected rooms
      for (final connection in connections) {
        if (connection['from'] == current &&
            !visited.contains(connection['to'])) {
          queue.add(connection['to']);
          visited.add(connection['to']);
          parent[connection['to']] = current;
        } else if (connection['to'] == current &&
            !visited.contains(connection['from'])) {
          queue.add(connection['from']);
          visited.add(connection['from']);
          parent[connection['from']] = current;
        }
      }
    }

    return [];
  }

  // Convert path to navigation instructions
  List<Map<String, dynamic>> _convertPathToInstructions(
    List<String> path,
    Map<String, dynamic> rooms,
    List<dynamic> connections,
  ) {
    final instructions = <Map<String, dynamic>>[];

    for (int i = 0; i < path.length - 1; i++) {
      final currentRoom = path[i];
      final nextRoom = path[i + 1];

      // Find connection between current and next room
      final connection = connections.firstWhere(
        (conn) =>
            (conn['from'] == currentRoom && conn['to'] == nextRoom) ||
            (conn['to'] == currentRoom && conn['from'] == nextRoom),
        orElse: () => {'distance': 0, 'accessible': true},
      );

      final currentRoomData = rooms[currentRoom] as Map<String, dynamic>;
      final nextRoomData = rooms[nextRoom] as Map<String, dynamic>;

      String instruction = _generateInstruction(
        currentRoomData,
        nextRoomData,
        connection,
        i == 0, // is first step
      );

      instructions.add({
        'instruction': instruction,
        'distance': '${connection['distance']} ft',
        'room': nextRoom,
        'roomName': nextRoomData['name'],
        'roomType': nextRoomData['type'],
        'accessible': connection['accessible'],
        'icon': _getIconForRoomType(nextRoomData['type']),
      });
    }

    return instructions;
  }

  // Generate voice instruction
  String _generateInstruction(
    Map<String, dynamic> currentRoom,
    Map<String, dynamic> nextRoom,
    Map<String, dynamic> connection,
    bool isFirstStep,
  ) {
    final currentName = currentRoom['name'];
    final nextName = nextRoom['name'];
    // final distance = connection['distance'];
    // final accessible = connection['accessible'];

    if (isFirstStep) {
      return 'Start from $currentName. Head towards $nextName.';
    }

    if (nextRoom['type'] == 'elevator') {
      return 'Take the elevator to reach $nextName.';
    } else if (nextRoom['type'] == 'escalator') {
      return 'Take the escalator to reach $nextName.';
    } else if (nextRoom['type'] == 'restroom') {
      return 'Continue to $nextName.';
    } else if (nextRoom['type'] == 'entrance') {
      return 'Head towards the $nextName.';
    } else {
      return 'Continue to $nextName.';
    }
  }

  // Get icon for room type
  IconData _getIconForRoomType(String type) {
    switch (type) {
      case 'entrance':
        return Icons.door_front_door;
      case 'elevator':
        return Icons.elevator;
      case 'escalator':
        return Icons.stairs;
      case 'restroom':
        return Icons.wc;
      case 'service':
        return Icons.help_outline;
      case 'dining':
        return Icons.restaurant;
      case 'classroom':
        return Icons.school;
      case 'office':
        return Icons.work;
      case 'lab':
        return Icons.science;
      case 'ward':
        return Icons.local_hospital;
      case 'retail':
        return Icons.store;
      case 'meeting':
        return Icons.meeting_room;
      case 'study':
        return Icons.menu_book;
      default:
        return Icons.room;
    }
  }

  // Initialize speech recognition
  Future<bool> initializeSpeechRecognition() async {
    return await _speechToText.initialize();
  }

  // Start listening for voice commands
  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        onSoundLevelChange: (level) {},
        listenOptions: SpeechListenOptions(
          partialResults: false,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isSpeaking) {
      _isSpeaking = true;
      await _flutterTts.speak(text);
      _isSpeaking = false;
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  // Check if speech recognition is available
  bool get isSpeechRecognitionAvailable => _speechToText.isAvailable;

  // Check if currently listening
  bool get isListening => _isListening;

  // Check if currently speaking
  bool get isSpeaking => _isSpeaking;
}
