# Nayati Flutter - Installation Guide

## Quick Setup

### Prerequisites
- **Flutter SDK 3.4.4+** (see detailed installation below)
- **Dart SDK 3.0.0+** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Physical device** or **emulator** for testing

## Flutter Installation

### Windows

1. **Download Flutter SDK**:
   - Go to [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
   - Download the latest stable release (3.4.4+)
   - Extract to `C:\flutter` (avoid spaces in path)

2. **Add Flutter to PATH**:
   - Open System Properties → Environment Variables
   - Add `C:\flutter\bin` to your PATH
   - Restart command prompt

3. **Install Git** (if not installed):
   - Download from [git-scm.com](https://git-scm.com/download/win)
   - Use default settings during installation

4. **Install Android Studio**:
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install with default settings
   - Open Android Studio and complete setup wizard
   - Install Android SDK (API 21+)

5. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### macOS

1. **Download Flutter SDK**:
   ```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.4.4-stable.zip
   unzip flutter_macos_3.4.4-stable.zip
   ```

2. **Add Flutter to PATH**:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Install Xcode** (for iOS development):
   - Install from Mac App Store
   - Open Xcode and accept license agreements
   - Install Xcode command line tools: `sudo xcode-select --install`

4. **Install Android Studio**:
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK (API 21+)

5. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### Linux (Ubuntu/Debian)

1. **Download Flutter SDK**:
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.4.4-stable.tar.xz
   tar xf flutter_linux_3.4.4-stable.tar.xz
   ```

2. **Add Flutter to PATH**:
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Install Dependencies**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
   ```

4. **Install Android Studio**:
   - Download from [developer.android.com](https://developer.android.com/studio)
   - Install Android SDK (API 21+)

5. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### IDE Setup

#### VS Code (Recommended)
1. Install VS Code from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install Flutter extension:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Flutter" and install
   - This will also install the Dart extension

#### Android Studio
1. Open Android Studio
2. Go to File → Settings → Plugins
3. Search for "Flutter" and install
4. Restart Android Studio

### Device Setup

#### Android Device
1. Enable Developer Options:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
3. Connect device via USB
4. Verify: `flutter devices`

#### Android Emulator
1. Open Android Studio
2. Go to Tools → AVD Manager
3. Create Virtual Device
4. Choose a device (e.g., Pixel 4)
5. Download and select system image (API 21+)
6. Start emulator

#### iOS Device (macOS only)
1. Connect iPhone/iPad via USB
2. Trust the computer on device
3. Open Xcode and sign in with Apple ID
4. Verify: `flutter devices`

### Troubleshooting Flutter Installation

**Common Issues**:

1. **"flutter: command not found"**:
   - Verify Flutter is in PATH
   - Restart terminal/command prompt

2. **Android SDK not found**:
   - Install Android Studio
   - Set ANDROID_HOME environment variable
   - Run `flutter doctor --android-licenses`

3. **Xcode not found (macOS)**:
   - Install Xcode from App Store
   - Run `sudo xcode-select --install`

4. **Flutter doctor issues**:
   ```bash
   flutter doctor -v  # Verbose output
   flutter doctor --fix  # Auto-fix issues
   ```

**Verify Everything Works**:
```bash
flutter doctor
flutter devices
flutter --version
```

### Installation Steps

1. **Clone and navigate to the project**:
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

### Platform Setup

#### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: Latest
- **Permissions**: Camera and microphone permissions are automatically requested

#### iOS
- **Minimum iOS**: 11.0
- **Permissions**: Camera and microphone permissions required

### Backend Configuration

The app connects to a Django backend. Update the API URL if needed:

1. Open `lib/services/api_service.dart`
2. Change the `baseUrl` to match your backend server:
   ```dart
   static const String baseUrl = 'http://YOUR_SERVER_IP:8000/api';
   ```

### Troubleshooting

**Camera/Microphone Issues**:
- Grant permissions in device settings
- Restart the app after granting permissions

**API Connection Failed**:
- Ensure backend server is running
- Check network connectivity
- Verify the API base URL is correct

**Build Issues**:
- Run `flutter clean` and `flutter pub get`
- Ensure Flutter SDK is properly installed
- Check device/emulator is connected

### Development

**Debug Mode**:
```bash
flutter run --debug
```

**Release Build**:
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

**Note**: This app requires the Django backend to be running for full functionality. See the main project README for backend setup instructions.
