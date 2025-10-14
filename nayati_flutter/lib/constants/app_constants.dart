/// Application-wide constants
class AppConstants {
  // Screen titles
  static const String homeTitle = 'Nayati';
  static const String visualAssistTitle = 'Visual Assist';
  static const String hearingAssistTitle = 'Hearing Assist';
  static const String mobilityAssistTitle = 'Mobility Assist';
  static const String historyTitle = 'History';
  static const String settingsTitle = 'Settings';
  static const String mapTitle = 'Map';

  // Common UI text
  static const String chooseModeText = 'Choose your assistance mode';
  static const String quickAccessText = 'Quick Access';
  static const String loadingText = 'Loading...';
  static const String retryText = 'Retry';
  static const String cancelText = 'Cancel';
  static const String confirmText = 'Confirm';
  static const String saveText = 'Save';
  static const String clearText = 'Clear';
  static const String startText = 'Start';
  static const String stopText = 'Stop';
  static const String pauseText = 'Pause';
  static const String resumeText = 'Resume';

  // Error messages
  static const String initializationError = 'Failed to initialize';
  static const String networkError = 'Network connection failed';
  static const String cameraError = 'Camera initialization failed';
  static const String microphoneError = 'Microphone access denied';
  static const String permissionError = 'Permission denied';

  // Success messages
  static const String initializationSuccess = 'Initialized successfully';
  static const String saveSuccess = 'Saved successfully';
  static const String operationSuccess = 'Operation completed successfully';

  // Dimensions
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double largePadding = 32.0;
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pulseAnimation = Duration(milliseconds: 1500);

  // Timeouts
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);

  // Asset paths
  static const String appIconPath = 'assets/images/app_icon.png';
  static const String logoPath = 'assets/images/logo.png';

  // API endpoints
  static const String baseUrl = 'http://10.53.175.29:8000/api';
  static const String healthEndpoint = '/health/';
  static const String visualAssistEndpoint = '/visual-assist/detect-objects/';
  static const String hearingAssistEndpoint = '/hearing-assist/transcribe/';
  static const String historyEndpoint = '/hearing-assist/history/';

  // Languages
  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
  ];

  // Default values
  static const String defaultLanguage = 'English';
  static const double defaultFontSize = 16.0;
  static const double defaultSpeechRate = 0.5;
  static const double defaultVolume = 1.0;
  static const double defaultPitch = 1.0;

  // Validation
  static const int maxTextLength = 1000;
  static const int maxDescriptionLength = 500;
  static const int minPasswordLength = 8;

  // File sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB

  // Camera settings
  static const int cameraTimeout = 30;
  static const double cameraAspectRatio = 16 / 9;
  static const int maxDetections = 10;

  // Speech recognition
  static const int listenDurationMinutes = 10;
  static const int pauseDurationSeconds = 3;
  static const double minConfidence = 0.3;

  // Navigation
  static const int maxNavigationSteps = 20;
  static const double defaultZoomLevel = 15.0;
  static const double maxZoomLevel = 20.0;
  static const double minZoomLevel = 10.0;
}
