import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Show timestamp
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

// Category-specific loggers for different parts of the app
class SpeechLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('🎤 SPEECH: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('🎤 SPEECH: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('🎤 SPEECH: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('🎤 SPEECH: $message', error, stackTrace);
  }
}

class TTSLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('🔊 TTS: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('🔊 TTS: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('🔊 TTS: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('🔊 TTS: $message', error, stackTrace);
  }
}

class CameraLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('📷 CAMERA: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('📷 CAMERA: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('📷 CAMERA: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('📷 CAMERA: $message', error, stackTrace);
  }
}

class ObjectDetectionLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('🔍 DETECTION: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('🔍 DETECTION: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('🔍 DETECTION: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('🔍 DETECTION: $message', error, stackTrace);
  }
}

class NavigationLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('🧭 NAVIGATION: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('🧭 NAVIGATION: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('🧭 NAVIGATION: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('🧭 NAVIGATION: $message', error, stackTrace);
  }
}

class HistoryLogger {
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.debug('📚 HISTORY: $message', error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.info('📚 HISTORY: $message', error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.warning('📚 HISTORY: $message', error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    AppLogger.error('📚 HISTORY: $message', error, stackTrace);
  }
}
