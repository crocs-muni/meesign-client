import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

class ErrorLogger {
  void initLogger() {
    Logger.root.level = Level.WARNING;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Logger.root.severe(details.toString(), details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.root.severe(error.toString(), error, stack);
      return false;
    };
  }
}
