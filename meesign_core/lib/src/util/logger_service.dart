import 'dart:io';

import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

/// Dart singleton pattern implemented with a factory constructor
/// For more see: https://stackoverflow.com/questions/12649573/how-do-you-build-a-singleton-in-dart

class LoggerService {
  // Factory constructor prevents creation of brand new instances on each call
  // of the constructor. Instead, it returns the same instance every time.
  factory LoggerService() {
    return _instance;
  }

  // Private constructor used to create _instance
  LoggerService._internal();
  // This gets created only once and is the single instance of   the class
  static final LoggerService _instance = LoggerService._internal();

  /// When true, all logging is suppressed. Use in tests to prevent
  /// log output and avoid triggering external log providers.
  /// Automatically enabled when running under `flutter test`.
  @visibleForTesting
  static bool isTestMode = Platform.environment['FLUTTER_TEST'] == 'true';

  // TODO(dev): Add Crashlytics or Sentry integration for error reporting
  static final _logger = Logger(
    // iOS colors don't work for iOS builds
    // https://github.com/flutter/flutter/issues/64491
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 3,
        colors: false,
      ),
    ),
    // level property acts as a filter: only messages at or above that level are printed.
    // Levels from lowest to highest are: trace < debug < info < warning < error < wtf.
    level: Level.trace,
  );
  static Logger get logger => _logger;

  /// For critical issues that need immediate attention
  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (isTestMode) return;
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// For important information that should be noted even in production
  static void logWarning(String message, [StackTrace? stackTrace]) {
    if (isTestMode) return;
    logger.w(message, stackTrace: stackTrace);
  }

  /// For development purposes
  static void logDebug(String message, [StackTrace? stackTrace]) {
    if (isTestMode) return;
    logger.d(message, stackTrace: stackTrace);
  }
}
