# Navina - Accessibility Assistant App


Navina is a comprehensive accessibility assistant application that provides visual, hearing, and mobility assistance features. The project consists of a React Native Expo frontend (Nayati) and a Django REST API backend (a11ypal_backend).

## Project Structure

```
Navina/
├── Nayati/                    # React Native Expo frontend
│   ├── app/                   # App screens and navigation
│   ├── components/            # Reusable UI components
│   ├── services/              # API communication
│   ├── hooks/                 # Custom React hooks
│   └── types/                 # TypeScript type definitions
└── a11ypal_backend/           # Django REST API backend
    ├── visual_assist/         # Visual assistance features
    ├── hearing_assist/        # Hearing assistance features
    ├── mobility_assist/       # Mobility assistance features
    ├── users/                 # User management
    ├── history/               # Activity history tracking
    └── services/              # ML/AI services
```

## Features

### Visual Assist
- **Object Detection**: Real-time object recognition using YOLOv5
- **Text Recognition**: OCR for reading text from images
- **Scene Description**: AI-powered scene analysis
- **Color Analysis**: Color identification and description

### Hearing Assist
- **Live Speech-to-Text**: Real-time audio recording and transcription using Python STT libraries
- **Audio Recording**: High-quality audio capture with pause/resume functionality
- **Transcription History**: View and manage previous transcriptions with confidence scores
- **Sound Alerts**: Visual notifications for important sounds
- **Audio Processing**: Sound analysis and categorization

### Mobility Assist
- **Navigation Guidance**: Voice-guided navigation assistance
- **Obstacle Detection**: Real-time obstacle identification
- **Route Planning**: Accessible route recommendations

## Prerequisites

### For Nayati (React Native Expo)

1. **Node.js** (v18 or higher)
   ```bash
   # Download from https://nodejs.org/
   ```

2. **Expo CLI**
   ```bash
   npm install -g @expo/cli
   ```

3. **Expo Go App** (for mobile testing)
   - iOS: Download from App Store
   - Android: Download from Google Play Store

4. **Development Tools** (for building native apps)
   - **Android**: Android Studio with Android SDK
   - **iOS**: Xcode (macOS only)

### For a11ypal_backend (Django)

1. **Python** (v3.8 or higher)
   ```bash
   # Download from https://python.org/
   ```

2. **pip** (Python package manager)
   ```bash
   # Usually comes with Python
   ```

3. **Virtual Environment** (recommended)
   ```bash
   pip install virtualenv
   ```

## Installation & Setup

### Backend Setup (Django)

1. **Navigate to backend directory**
   ```bash
   cd a11ypal_backend
   ```

2. **Create and activate virtual environment**
   ```bash
   # Create virtual environment
   python -m venv venv

   # Activate virtual environment
   # Windows:
   venv\Scripts\activate
   # macOS/Linux:
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

   **Note**: For speech-to-text functionality, you may need to install additional system dependencies:
   
   **Ubuntu/Debian:**
   ```bash
   sudo apt-get install portaudio19-dev python3-pyaudio
   ```
   
   **macOS:**
   ```bash
   brew install portaudio
   ```
   
   **Windows:**
   ```bash
   # PyAudio is usually installed automatically, but if you encounter issues:
   pip install pipwin
   pipwin install pyaudio
   ```

4. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

5. **Create superuser** (optional)
   ```bash
   python manage.py createsuperuser
   ```

6. **Start the development server**
   ```bash
   python manage.py runserver
   ```
   
   The backend will be available at `http://localhost:8000`

### Frontend Setup (React Native Expo)

1. **Navigate to frontend directory**
   ```bash
   cd Nayati
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Update API configuration**
   - Open `services/api.ts`
   - Update `API_BASE_URL` with your computer's IP address
   - Find your IP with: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

4. **Start the development server**
   ```bash
   npm start
   # or
   expo start
   ```

## Running the Application

### Development Mode

1. **Start the backend server**
   ```bash
   cd a11ypal_backend
   python manage.py runserver
   ```

2. **Start the frontend development server**
   ```bash
   cd Nayati
   npm start
   ```

3. **Run on device/simulator**
   - **Mobile**: Scan QR code with Expo Go app
   - **Android Emulator**: Press `a` in terminal
   - **iOS Simulator**: Press `i` in terminal (macOS only)
   - **Web**: Press `w` in terminal

### Production Build

1. **Build for Android**
   ```bash
   cd Nayati
   expo build:android
   ```

2. **Build for iOS**
   ```bash
   cd Nayati
   expo build:ios
   ```

## Code Structure Overview

### Frontend (Nayati)

- **`app/`**: Contains all screens and navigation structure
  - `(tabs)/`: Tab-based navigation screens
  - `_layout.tsx`: Root layout configuration
- **`components/`**: Reusable UI components
  - `HomeScreen.tsx`: Main dashboard with feature selection
  - `VisualAssistScreen.tsx`: Object detection and text recognition
  - `HearingAssistScreen.tsx`: Audio processing and transcription
  - `MobilityAssistScreen.tsx`: Navigation and obstacle detection
  - `ui/`: Custom UI components (Button, Card, Input, etc.)
- **`services/`**: API communication layer
  - `api.ts`: Main API client configuration
  - `debugApi.ts`: Debug API utilities
- **`hooks/`**: Custom React hooks
  - `useObjectDetection.ts`: Object detection logic
- **`types/`**: TypeScript type definitions

### Backend (a11ypal_backend)

- **`visual_assist/`**: Visual assistance API endpoints
  - Object detection, text recognition, scene analysis
- **`hearing_assist/`**: Audio processing endpoints
  - Speech-to-text, sound analysis
- **`mobility_assist/`**: Navigation and mobility features
  - Route planning, obstacle detection
- **`users/`**: User authentication and management
- **`history/`**: Activity tracking and history
- **`services/`**: ML/AI service implementations
  - `object_detection_service.py`: YOLOv5 integration
  - `yolov5_detection_service.py`: Object detection logic

## API Endpoints

### Visual Assist
- `POST /api/visual-assist/analyze/` - Analyze image for objects and text
- `GET /api/visual-assist/history/` - Get analysis history

### Hearing Assist
- `POST /api/hearing-assist/transcribe/` - Transcribe audio file to text
- `GET /api/hearing-assist/speech-to-text/` - Get transcription history
- `GET /api/hearing-assist/speech-to-text/{id}/` - Get specific transcription
- `DELETE /api/hearing-assist/speech-to-text/{id}/` - Delete transcription
- `GET /api/hearing-assist/stats/` - Get hearing assist statistics

### Mobility Assist
- `POST /api/mobility-assist/navigate/` - Get navigation guidance
- `GET /api/mobility-assist/history/` - Get navigation history

## Troubleshooting

### Common Issues

1. **API Connection Issues**
   - Ensure backend is running on correct port (8000)
   - Update IP address in `services/api.ts`
   - Check firewall settings

2. **Expo Development Issues**
   - Clear Expo cache: `expo start -c`
   - Restart Metro bundler: `npx react-native start --reset-cache`

3. **Python/Django Issues**
   - Ensure virtual environment is activated
   - Check Python version compatibility
   - Run `pip install --upgrade pip`

4. **Camera Permissions**
   - Ensure camera permissions are granted on device
   - Check app.json for proper permission configuration

5. **Expo/React Native Issues**
   - **Worklets Error**: Run `npx expo install react-native-reanimated@3.16.1`
   - **Navigation Error**: Ensure NavigationProvider is properly set up in _layout.tsx
   - **Deprecation Warnings**: Update to latest compatible versions
   - **Clear Cache**: Run `npx expo start --clear` to clear Metro cache
   - **Package Not Found**: If you get "No matching version found", try removing the package from package.json and reinstalling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository or contact the development team.
