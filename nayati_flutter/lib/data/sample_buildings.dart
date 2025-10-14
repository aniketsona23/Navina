// Sample building data for indoor navigation
// This file contains additional building maps that can be easily added to the system

const Map<String, Map<String, dynamic>> sampleBuildings = {
  'office_building': {
    'name': 'Corporate Office Building',
    'floors': {
      'ground': {
        'name': 'Ground Floor',
        'rooms': {
          'main_entrance': {'x': 50, 'y': 100, 'name': 'Main Entrance', 'type': 'entrance'},
          'reception': {'x': 100, 'y': 80, 'name': 'Reception Desk', 'type': 'service'},
          'elevator_a': {'x': 150, 'y': 50, 'name': 'Elevator A', 'type': 'elevator'},
          'elevator_b': {'x': 200, 'y': 50, 'name': 'Elevator B', 'type': 'elevator'},
          'cafeteria': {'x': 250, 'y': 100, 'name': 'Employee Cafeteria', 'type': 'dining'},
          'conference_room_a': {'x': 100, 'y': 150, 'name': 'Conference Room A', 'type': 'meeting'},
          'conference_room_b': {'x': 150, 'y': 150, 'name': 'Conference Room B', 'type': 'meeting'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
          'atm': {'x': 180, 'y': 80, 'name': 'ATM', 'type': 'service'},
        },
        'connections': [
          {'from': 'main_entrance', 'to': 'reception', 'distance': 50, 'accessible': true},
          {'from': 'reception', 'to': 'elevator_a', 'distance': 50, 'accessible': true},
          {'from': 'reception', 'to': 'elevator_b', 'distance': 100, 'accessible': true},
          {'from': 'elevator_a', 'to': 'cafeteria', 'distance': 100, 'accessible': true},
          {'from': 'reception', 'to': 'conference_room_a', 'distance': 50, 'accessible': true},
          {'from': 'reception', 'to': 'conference_room_b', 'distance': 50, 'accessible': true},
          {'from': 'reception', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'reception', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
          {'from': 'reception', 'to': 'atm', 'distance': 80, 'accessible': true},
        ]
      },
      'first': {
        'name': 'First Floor',
        'rooms': {
          'elevator_a': {'x': 150, 'y': 50, 'name': 'Elevator A', 'type': 'elevator'},
          'elevator_b': {'x': 200, 'y': 50, 'name': 'Elevator B', 'type': 'elevator'},
          'office_101': {'x': 100, 'y': 100, 'name': 'Office 101', 'type': 'office'},
          'office_102': {'x': 150, 'y': 100, 'name': 'Office 102', 'type': 'office'},
          'office_103': {'x': 200, 'y': 100, 'name': 'Office 103', 'type': 'office'},
          'office_104': {'x': 250, 'y': 100, 'name': 'Office 104', 'type': 'office'},
          'meeting_room_1': {'x': 100, 'y': 150, 'name': 'Meeting Room 1', 'type': 'meeting'},
          'meeting_room_2': {'x': 150, 'y': 150, 'name': 'Meeting Room 2', 'type': 'meeting'},
          'break_room': {'x': 200, 'y': 150, 'name': 'Break Room', 'type': 'dining'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
        },
        'connections': [
          {'from': 'elevator_a', 'to': 'office_101', 'distance': 50, 'accessible': true},
          {'from': 'elevator_a', 'to': 'office_102', 'distance': 0, 'accessible': true},
          {'from': 'elevator_b', 'to': 'office_103', 'distance': 0, 'accessible': true},
          {'from': 'elevator_b', 'to': 'office_104', 'distance': 50, 'accessible': true},
          {'from': 'office_101', 'to': 'meeting_room_1', 'distance': 50, 'accessible': true},
          {'from': 'office_102', 'to': 'meeting_room_2', 'distance': 50, 'accessible': true},
          {'from': 'office_103', 'to': 'break_room', 'distance': 50, 'accessible': true},
          {'from': 'elevator_a', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'elevator_a', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
        ]
      }
    }
  },
  'airport_terminal': {
    'name': 'International Airport Terminal',
    'floors': {
      'ground': {
        'name': 'Ground Floor',
        'rooms': {
          'main_entrance': {'x': 50, 'y': 100, 'name': 'Main Entrance', 'type': 'entrance'},
          'check_in_desk': {'x': 100, 'y': 80, 'name': 'Check-in Desk', 'type': 'service'},
          'elevator_a': {'x': 150, 'y': 50, 'name': 'Elevator A', 'type': 'elevator'},
          'elevator_b': {'x': 200, 'y': 50, 'name': 'Elevator B', 'type': 'elevator'},
          'escalator_a': {'x': 250, 'y': 50, 'name': 'Escalator A', 'type': 'escalator'},
          'escalator_b': {'x': 300, 'y': 50, 'name': 'Escalator B', 'type': 'escalator'},
          'baggage_claim': {'x': 200, 'y': 150, 'name': 'Baggage Claim', 'type': 'service'},
          'customs': {'x': 250, 'y': 150, 'name': 'Customs', 'type': 'service'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
          'atm': {'x': 180, 'y': 80, 'name': 'ATM', 'type': 'service'},
          'information_desk': {'x': 150, 'y': 100, 'name': 'Information Desk', 'type': 'service'},
        },
        'connections': [
          {'from': 'main_entrance', 'to': 'check_in_desk', 'distance': 50, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'elevator_a', 'distance': 50, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'elevator_b', 'distance': 100, 'accessible': true},
          {'from': 'elevator_a', 'to': 'escalator_a', 'distance': 100, 'accessible': true},
          {'from': 'elevator_b', 'to': 'escalator_b', 'distance': 100, 'accessible': true},
          {'from': 'escalator_a', 'to': 'baggage_claim', 'distance': 50, 'accessible': true},
          {'from': 'baggage_claim', 'to': 'customs', 'distance': 50, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'atm', 'distance': 80, 'accessible': true},
          {'from': 'check_in_desk', 'to': 'information_desk', 'distance': 50, 'accessible': true},
        ]
      },
      'first': {
        'name': 'First Floor',
        'rooms': {
          'elevator_a': {'x': 150, 'y': 50, 'name': 'Elevator A', 'type': 'elevator'},
          'elevator_b': {'x': 200, 'y': 50, 'name': 'Elevator B', 'type': 'elevator'},
          'escalator_a': {'x': 250, 'y': 50, 'name': 'Escalator A', 'type': 'escalator'},
          'escalator_b': {'x': 300, 'y': 50, 'name': 'Escalator B', 'type': 'escalator'},
          'gate_a1': {'x': 100, 'y': 100, 'name': 'Gate A1', 'type': 'entrance'},
          'gate_a2': {'x': 150, 'y': 100, 'name': 'Gate A2', 'type': 'entrance'},
          'gate_b1': {'x': 200, 'y': 100, 'name': 'Gate B1', 'type': 'entrance'},
          'gate_b2': {'x': 250, 'y': 100, 'name': 'Gate B2', 'type': 'entrance'},
          'duty_free_shop': {'x': 100, 'y': 150, 'name': 'Duty Free Shop', 'type': 'retail'},
          'restaurant': {'x': 150, 'y': 150, 'name': 'Restaurant', 'type': 'dining'},
          'coffee_shop': {'x': 200, 'y': 150, 'name': 'Coffee Shop', 'type': 'dining'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
        },
        'connections': [
          {'from': 'elevator_a', 'to': 'gate_a1', 'distance': 50, 'accessible': true},
          {'from': 'elevator_a', 'to': 'gate_a2', 'distance': 0, 'accessible': true},
          {'from': 'elevator_b', 'to': 'gate_b1', 'distance': 0, 'accessible': true},
          {'from': 'elevator_b', 'to': 'gate_b2', 'distance': 50, 'accessible': true},
          {'from': 'gate_a1', 'to': 'duty_free_shop', 'distance': 50, 'accessible': true},
          {'from': 'gate_a2', 'to': 'restaurant', 'distance': 50, 'accessible': true},
          {'from': 'gate_b1', 'to': 'coffee_shop', 'distance': 50, 'accessible': true},
          {'from': 'elevator_a', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'elevator_a', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
        ]
      }
    }
  },
  'library': {
    'name': 'Central Public Library',
    'floors': {
      'ground': {
        'name': 'Ground Floor',
        'rooms': {
          'main_entrance': {'x': 50, 'y': 100, 'name': 'Main Entrance', 'type': 'entrance'},
          'circulation_desk': {'x': 100, 'y': 80, 'name': 'Circulation Desk', 'type': 'service'},
          'elevator': {'x': 150, 'y': 50, 'name': 'Elevator', 'type': 'elevator'},
          'staircase': {'x': 200, 'y': 50, 'name': 'Main Staircase', 'type': 'escalator'},
          'children_section': {'x': 100, 'y': 150, 'name': 'Children\'s Section', 'type': 'study'},
          'reference_desk': {'x': 150, 'y': 150, 'name': 'Reference Desk', 'type': 'service'},
          'computer_lab': {'x': 200, 'y': 150, 'name': 'Computer Lab', 'type': 'lab'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
          'cafeteria': {'x': 250, 'y': 100, 'name': 'Library Cafeteria', 'type': 'dining'},
        },
        'connections': [
          {'from': 'main_entrance', 'to': 'circulation_desk', 'distance': 50, 'accessible': true},
          {'from': 'circulation_desk', 'to': 'elevator', 'distance': 50, 'accessible': true},
          {'from': 'circulation_desk', 'to': 'staircase', 'distance': 100, 'accessible': true},
          {'from': 'circulation_desk', 'to': 'children_section', 'distance': 50, 'accessible': true},
          {'from': 'elevator', 'to': 'reference_desk', 'distance': 50, 'accessible': true},
          {'from': 'reference_desk', 'to': 'computer_lab', 'distance': 50, 'accessible': true},
          {'from': 'circulation_desk', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'circulation_desk', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
          {'from': 'staircase', 'to': 'cafeteria', 'distance': 50, 'accessible': true},
        ]
      },
      'first': {
        'name': 'First Floor',
        'rooms': {
          'elevator': {'x': 150, 'y': 50, 'name': 'Elevator', 'type': 'elevator'},
          'staircase': {'x': 200, 'y': 50, 'name': 'Main Staircase', 'type': 'escalator'},
          'fiction_section': {'x': 100, 'y': 100, 'name': 'Fiction Section', 'type': 'study'},
          'non_fiction_section': {'x': 150, 'y': 100, 'name': 'Non-Fiction Section', 'type': 'study'},
          'periodicals': {'x': 200, 'y': 100, 'name': 'Periodicals Section', 'type': 'study'},
          'study_room_1': {'x': 100, 'y': 150, 'name': 'Study Room 1', 'type': 'meeting'},
          'study_room_2': {'x': 150, 'y': 150, 'name': 'Study Room 2', 'type': 'meeting'},
          'study_room_3': {'x': 200, 'y': 150, 'name': 'Study Room 3', 'type': 'meeting'},
          'restroom_male': {'x': 80, 'y': 120, 'name': 'Men\'s Restroom', 'type': 'restroom'},
          'restroom_female': {'x': 120, 'y': 120, 'name': 'Women\'s Restroom', 'type': 'restroom'},
        },
        'connections': [
          {'from': 'elevator', 'to': 'fiction_section', 'distance': 50, 'accessible': true},
          {'from': 'elevator', 'to': 'non_fiction_section', 'distance': 0, 'accessible': true},
          {'from': 'staircase', 'to': 'periodicals', 'distance': 0, 'accessible': true},
          {'from': 'fiction_section', 'to': 'study_room_1', 'distance': 50, 'accessible': true},
          {'from': 'non_fiction_section', 'to': 'study_room_2', 'distance': 50, 'accessible': true},
          {'from': 'periodicals', 'to': 'study_room_3', 'distance': 50, 'accessible': true},
          {'from': 'elevator', 'to': 'restroom_male', 'distance': 30, 'accessible': true},
          {'from': 'elevator', 'to': 'restroom_female', 'distance': 20, 'accessible': true},
        ]
      }
    }
  }
};

// Helper function to get building names
List<String> getSampleBuildingNames() {
  return sampleBuildings.keys.toList();
}

// Helper function to get building details
Map<String, dynamic>? getSampleBuildingDetails(String buildingId) {
  return sampleBuildings[buildingId];
}
