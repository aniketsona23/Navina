# Indoor Navigation Feature

This document describes the indoor navigation feature implemented in the Nayati Flutter app for the mobility-assist module.

## Overview

The indoor navigation feature provides voice-guided navigation within pre-fed building maps, helping users with mobility challenges navigate indoor spaces easily and safely.

## Features

### 1. Pre-fed Building Maps
- **University Main Building**: 3 floors with classrooms, offices, labs, and common areas
- **City Shopping Mall**: 2 floors with retail stores, food court, and services
- **City General Hospital**: 2 floors with wards, offices, and medical facilities

### 2. Voice Guidance
- Text-to-speech instructions for each navigation step
- Voice command recognition for hands-free control
- Repeat instructions on demand
- Help commands for guidance

### 3. Accessibility Features
- Wheelchair-accessible route planning
- Clear audio instructions
- Visual progress indicators
- Haptic feedback support

### 4. Navigation Controls
- Step-by-step navigation with visual indicators
- Previous/Next step controls
- Voice command support
- Emergency stop functionality

## Architecture

### Core Components

1. **IndoorNavigationService** (`lib/services/indoor_navigation_service.dart`)
   - Manages pre-fed building maps
   - Handles pathfinding algorithms
   - Provides voice guidance functionality
   - Manages speech recognition and TTS

2. **IndoorNavigationProvider** (`lib/providers/indoor_navigation_provider.dart`)
   - State management for navigation
   - Handles user interactions
   - Manages navigation flow
   - Provides error handling

3. **IndoorNavigationScreen** (`lib/screens/indoor_navigation_screen.dart`)
   - Main UI for indoor navigation
   - Building and floor selection
   - Room selection interface
   - Active navigation display

## Usage

### Starting Indoor Navigation

1. Open the Mobility Assist screen
2. Tap "Indoor Nav" button
3. Select a building from the available options
4. Choose the desired floor
5. Select start and destination rooms
6. Tap "Start Navigation"

### Voice Commands

During navigation, users can use the following voice commands:
- "Next" or "Continue" - Move to next step
- "Previous" or "Back" - Go to previous step
- "Stop" or "End" - Stop navigation
- "Repeat" or "Again" - Repeat current instruction
- "Help" - Get help with available commands

### Navigation Interface

The navigation interface shows:
- Current destination and progress
- Step-by-step instructions with icons
- Distance information for each step
- Accessibility indicators
- Voice control buttons

## Building Maps Structure

Each building map contains:
- **Floors**: Multiple levels with room layouts
- **Rooms**: Individual locations with coordinates and types
- **Connections**: Paths between rooms with distance and accessibility info
- **Room Types**: Different categories (entrance, elevator, classroom, etc.)

### Room Types
- `entrance` - Building entrances
- `elevator` - Elevator access points
- `escalator` - Escalator access points
- `restroom` - Restroom facilities
- `service` - Information desks, help centers
- `dining` - Cafeterias, food courts
- `classroom` - Educational rooms
- `office` - Administrative offices
- `lab` - Laboratory spaces
- `ward` - Hospital wards
- `retail` - Shopping stores
- `meeting` - Conference rooms
- `study` - Study areas

## Dependencies

The indoor navigation feature requires:
- `speech_to_text: ^7.0.0` - Voice command recognition
- `tts: ^3.8.5` - Text-to-speech functionality
- `provider: ^6.1.2` - State management

## Adding New Buildings

To add a new building to the indoor navigation system:

1. Open `lib/services/indoor_navigation_service.dart`
2. Add a new entry to the `_indoorMaps` constant
3. Define the building structure with floors, rooms, and connections
4. Ensure proper room types and accessibility information

Example:
```dart
'new_building': {
  'name': 'New Building Name',
  'floors': {
    'ground': {
      'name': 'Ground Floor',
      'rooms': {
        'room_id': {
          'x': 50, 'y': 100, 
          'name': 'Room Name', 
          'type': 'room_type'
        }
      },
      'connections': [
        {
          'from': 'room1', 
          'to': 'room2', 
          'distance': 50, 
          'accessible': true
        }
      ]
    }
  }
}
```

## Error Handling

The system handles various error scenarios:
- No path found to destination
- Speech recognition failures
- TTS initialization errors
- Invalid room selections
- Network connectivity issues

## Future Enhancements

Potential improvements for the indoor navigation feature:
- Real-time location tracking using beacons
- Dynamic map updates
- Crowd-sourced accessibility information
- Integration with building management systems
- Multi-language support
- Offline map storage
- AR-based navigation overlays

## Testing

To test the indoor navigation feature:
1. Run the app on a device or emulator
2. Navigate to Mobility Assist screen
3. Test building selection and room navigation
4. Verify voice commands work correctly
5. Test accessibility features
6. Validate error handling scenarios

## Troubleshooting

Common issues and solutions:
- **Voice not working**: Check microphone permissions
- **TTS not speaking**: Verify TTS initialization
- **No buildings showing**: Check service initialization
- **Navigation not starting**: Verify room selections
- **Path not found**: Check room connections in map data
