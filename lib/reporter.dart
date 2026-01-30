import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

class Reporter {
  Reporter(Logger logger) {
    logger.onRecord.listen(_buffer.add);
  }
  SupportServices? _services;
  final _buffer = ReplaySubject<LogRecord>(maxSize: 16);
  StreamSubscription<LogRecord>? _bufferSub;

  void start(SupportServices services) {
    _services = services;
    _bufferSub = _buffer.listen(_report);
  }

  void stop() {
    _services = null;
    _bufferSub?.cancel();
    _bufferSub = null;
    // TODO(dev): clean buffer to avoid
    // spilling errors over to new user session?
  }

  Future<void> _report(LogRecord record) async {
    final message = '${record.message}\n\n'
        '****Error****\n${record.error}\n\n'
        '****Stack****\n${record.stackTrace}';

    try {
      _services?.log(null, message);
    } on Exception {
      // do not generate more error events
    }
  }
}
