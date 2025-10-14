# Nayati Flutter App

A Flutter replica of the Nayati accessibility app, providing visual, hearing, and mobility assistance features.

## Features

### 🏠 Home Screen
- Clean, accessible interface with three main assistance modes
- Quick access to history and settings
- Material Design 3 with custom theming

### 👁️ Visual Assist
- Real-time camera feed with object detection
- Continuous scanning mode with customizable intervals
- Bounding box visualization for detected objects
- Camera switching (front/back)
- Detection confidence scores and processing time display

### 👂 Hearing Assist
- Audio recording with start/pause/stop controls
- Real-time transcription using speech-to-text API
- Live transcript display with confidence scores
- Recording duration timer
- Network connectivity testing
- Transcription history

### 🚶 Mobility Assist
- Indoor navigation with step-by-step directions
- Quick destination selection
- Accessibility features (voice guidance, haptic feedback)
- Accessible route planning
- Real-time navigation status

### ⚙️ Settings
- Notification preferences
- Accessibility options (haptic feedback, voice guidance)
- Language selection
- Font size adjustment
- App information and legal pages

## Technical Stack

- **Framework**: Flutter 3.4.4+
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Audio Recording**: record package
- **Camera**: camera package
- **Permissions**: permission_handler

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── theme/
│   └── app_theme.dart       # Material Design 3 theming
├── providers/
│   ├── audio_recording_provider.dart
│   ├── object_detection_provider.dart
│   └── navigation_provider.dart
├── services/
│   └── api_service.dart     # Backend API integration
└── screens/
    ├── home_screen.dart
    ├── hearing_assist_screen.dart
    ├── visual_assist_screen.dart
    ├── mobility_assist_screen.dart
    ├── history_screen.dart
    ├── map_screen.dart
    └── settings_screen.dart
```

## API Integration

The app connects to the same Django backend as the React Native version:

- **Base URL**: `http://10.30.8.17:8000/api`
- **Object Detection**: `/visual-assist/detect/`
- **Speech-to-Text**: `/hearing-assist/transcribe/`
- **Health Check**: `/health/`
- **History**: `/hearing-assist/history/`

## Getting Started

### Prerequisites

- Flutter SDK 3.4.4 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator for testing

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd nayati_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Configuration

1. **Backend Configuration** (Flexible Setup):
   - **Easy Setup**: Use the app's Settings → Backend Configuration
   - **Environment Variables**: Use `--dart-define=BACKEND_URL=http://YOUR_IP:8000/api`
   - **Auto-detect**: App automatically tries to find the best backend URL
   - See [BACKEND_CONFIG_GUIDE.md](BACKEND_CONFIG_GUIDE.md) for detailed instructions

2. **Configure Permissions**:
   - The app automatically requests camera and microphone permissions
   - For Android, ensure permissions are declared in `android/app/src/main/AndroidManifest.xml`

## Key Features Implementation

### Audio Recording
- Uses the `record` package for cross-platform audio recording
- Supports WAV format with 16kHz sample rate
- Real-time duration tracking
- Error handling and permission management

### Object Detection
- Camera integration with continuous capture
- Real-time object detection overlay
- Custom painter for bounding box visualization
- Throttled API calls to prevent overload

### Navigation
- GoRouter for declarative routing
- Bottom navigation with state persistence
- Modal screens for assist features
- Back navigation handling

### State Management
- Provider pattern for reactive state updates
- Separate providers for different features
- Clean separation of concerns

## Accessibility Features

- **High Contrast**: Custom color scheme for better visibility
- **Large Text**: Adjustable font sizes
- **Voice Guidance**: Audio instructions for navigation
- **Haptic Feedback**: Vibration alerts for interactions
- **Screen Reader**: Semantic labels and descriptions

## Backend Requirements

The Flutter app requires the same Django backend as the React Native version:

1. **Django Server**: Running on `http://10.30.8.17:8000`
2. **CORS Configuration**: Allow requests from mobile devices
3. **API Endpoints**: Object detection and speech-to-text services
4. **File Upload**: Support for image and audio file uploads

## Development Notes

- **Platform Support**: Android and iOS
- **Minimum SDK**: Android API 21, iOS 11.0
- **Architecture**: Clean architecture with separation of concerns
- **Testing**: Unit tests for providers and services
- **Performance**: Optimized for smooth 60fps UI

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**:
   - Check device settings
   - Restart the app after granting permissions

2. **API Connection Failed**:
   - Verify backend server is running
   - Check network connectivity
   - Update API base URL if needed

3. **Audio Recording Issues**:
   - Ensure microphone permissions are granted
   - Check device audio settings
   - Verify audio format compatibility

### Debug Mode

Enable debug logging by setting:
```dart
// In main.dart
debugShowCheckedModeBanner: true;
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is part of the Nayati accessibility suite and follows the same licensing terms as the main project.