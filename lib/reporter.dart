import 'package:logging/logging.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

class Reporter {
  late final SupportServices _services;
  final _buffer = ReplaySubject<LogRecord>(maxSize: 16);

  Reporter(Logger logger) {
    logger.onRecord.listen(_buffer.add);
  }

  void init(SupportServices services) {
    _services = services;
    _buffer.listen(_report);
  }

  Future<void> _report(LogRecord record) async {
    final message = '${record.message}\n\n'
        '****Error****\n${record.error.toString()}\n\n'
        '****Stack****\n${record.stackTrace?.toString()}';

    try {
      _services.log(null, message);
    } catch (_) {
      // do not generate more error events
    }
  }
}
