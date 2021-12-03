import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'dylib_worker.dart';

class DylibManager {
  late Isolate _isolate;
  final ReceivePort _receivePort;
  late SendPort _sendPort;

  // FIXME: this is ok as long as we don't use async
  // functions in the worker isolate
  final Queue<Completer> _requests = ListQueue();

  DylibManager() : _receivePort = ReceivePort() {
    _receivePort.listen(_handleMessage);
    _initIsolate();
  }

  Future<void> _initIsolate() async {
    // FIXME: do we also need to shut the isolate down?
    _isolate = await Isolate.spawn(DylibWorker.main, _receivePort.sendPort);
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      return;
    }

    assert(message is WorkerResponse);
    final completer = _requests.removeFirst();

    if (message is PdfSignResponse) {
      completer.complete();
    }
  }

  Future<T> _enqueueRequest<T>(WorkerRequest request) {
    // FIXME: wait for sendPort?
    final completer = Completer<T>();
    _requests.addLast(completer);
    _sendPort.send(request);
    return completer.future;
  }

  Future<void> signPdf(
    String inPath,
    String outPath, {
    String message = "Signed using MpcDemo",
  }) {
    return _enqueueRequest(PdfSignRequest(inPath, outPath, message));
  }
}
