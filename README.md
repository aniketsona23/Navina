# Navina - Accessibility Assistant App

Navina is a comprehensive accessibility assistant that provides visual, hearing, and mobility assistance features. The project now uses a Flutter frontend (nayati_flutter) with a Django REST API backend (a11ypal_backend).

## Project Structure

```
Navina/
├── nayati_flutter/             # Flutter mobile app (Android/iOS/Web)
│   ├── lib/                    # Dart source (screens, providers, services)
│   ├── android/                # Android project
│   ├── ios/                    # iOS project
│   └── pubspec.yaml            # Flutter dependencies
└── a11ypal_backend/            # Django REST API backend
    ├── a11ypal_backend/        # Project config (settings, urls, health)
    ├── visual_assist/          # Visual assistance features
    ├── hearing_assist/         # Hearing assistance features
    ├── mobility_assist/        # Mobility assistance features
+    ├── history/               # Activity history tracking
    ├── users/                  # User management
    ├── services/               # ML/AI services (YOLOv5, STT)
    ├── requirements.txt        # Python dependencies
    └── manage.py               # Django entry point
```

## Features

### Visual Assist
- Object detection (YOLOv5)
- Text recognition (OCR)
- Scene description
- Color analysis

### Hearing Assist
- Live speech-to-text transcription
- Audio recording with pause/resume
- Transcription history with confidence scores
- Sound analysis and categorization

### Mobility Assist
- Indoor/outdoor navigation guidance
- Obstacle reporting
- Accessible route planning

## Prerequisites

### Flutter (nayati_flutter)
- Flutter SDK 3.4.4 or higher (includes Dart SDK)
- Android Studio and Android SDK (for Android builds)
- Xcode (for iOS builds on macOS)

### Backend (a11ypal_backend)
- Python 3.8+
- pip
- Recommended: virtual environment

## Installation & Setup

### Backend Setup (Django)

1) Navigate to backend directory
```bat
cd a11ypal_backend
```

2) Create and activate a virtual environment (Windows cmd)
```bat
python -m venv .venv
.venv\Scripts\activate
```

3) Install dependencies
```bat
pip install -r requirements.txt
```

Notes for audio/STT on Windows: if PyAudio fails to install
```bat
pip install pipwin
pipwin install pyaudio
```

4) Apply migrations and run
```bat
python manage.py migrate
python manage.py runserver
```

The backend will be available at http://localhost:8000/ (health check at /api/health/).

### Frontend Setup (Flutter)

1) Navigate to app folder
```bat
cd nayati_flutter
```

2) Install Flutter packages
```bat
flutter pub get
```

3) Configure backend URL (pick one)
- In-app: Settings → Backend Configuration
- Via flag at run time:
```bat
flutter run --dart-define=BACKEND_URL=http://YOUR_IP:8000/api
```
Tip: On Android emulator you can use 10.0.2.2 as the host (http://10.0.2.2:8000/api). For a physical device, use your machine's LAN IP and ensure both are on the same network.

4) Run the app
```bat
flutter run
```

More Flutter setup details and platform-specific guides are in `nayati_flutter/README.md` and the docs in that folder (e.g., INSTALLATION.md, GOOGLE_MAPS_SETUP_GUIDE.md, OUTDOOR_NAVIGATION_GUIDE.md, DIRECTIONS_GUIDE.md).

## Running the Application (Dev)

1) Start backend
```bat
cd a11ypal_backend
python manage.py runserver
```

2) Start Flutter app
```bat
cd nayati_flutter
flutter run
```

Optional (Android physical device) to reach localhost backend:
```bat
adb reverse tcp:8000 tcp:8000
```

## API Overview

Base URL: http://HOST:8000/api

Health
- GET /api/health/

Visual Assist
- POST /api/visual-assist/analyze/
- POST /api/visual-assist/extract-text/
- POST /api/visual-assist/detect-objects/ (see also detect-objects-realtime/test/simple)
- GET  /api/visual-assist/analyses/
- GET  /api/visual-assist/stats/

Hearing Assist
- POST /api/hearing-assist/transcribe/
- GET  /api/hearing-assist/speech-to-text/
- GET  /api/hearing-assist/stats/

Mobility Assist
- POST /api/mobility-assist/update-location/
- GET  /api/mobility-assist/nearby-accessible/
- POST /api/mobility-assist/create-route/
- POST /api/mobility-assist/report-obstacle/
- GET  /api/mobility-assist/emergency-contacts/
- POST /api/mobility-assist/create-emergency-alert/
- GET  /api/mobility-assist/stats/

History & Analytics
- POST /api/history/log-activity/
- GET  /api/history/dashboard/
- GET  /api/history/feature-analytics/
- GET  /api/history/error-analytics/

For a complete list and details, see the app-level READMEs inside `a11ypal_backend/`.

## Troubleshooting

Backend
- Ensure the virtual environment is activated
- If torch/ultralytics install slowly, consider using a Python environment manager or a prebuilt wheel
- If PyAudio fails on Windows, use pipwin as shown above

Flutter
- Run `flutter doctor` and resolve any issues reported
- If build issues occur, try `flutter clean` then `flutter pub get`
- Camera/mic permissions: ensure AndroidManifest.xml and iOS Info.plist contain required permissions
- On an emulator, use 10.0.2.2 to access the host machine (not localhost)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly (backend and Flutter)
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository or contact the development team.
