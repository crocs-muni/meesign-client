import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

String dlPlatformName(String name) {
  if (Platform.isAndroid || Platform.isLinux) return 'lib$name.so';
  if (Platform.isWindows) return '$name.dll';
  if (Platform.isMacOS) return '$name.dylib';
  throw Exception('Platform unsupported');
}

DynamicLibrary dlOpen(String name) {
  if (Platform.isLinux) return DynamicLibrary.process();
  return DynamicLibrary.open(dlPlatformName(name));
}

// FIXME: this is playing perhaps too fast and loose with types

abstract class WorkerThread {
  final ReceivePort _receivePort;
  final SendPort _sendPort;

  WorkerThread(this._sendPort) : _receivePort = ReceivePort() {
    // establish 2-way communication
    _receivePort.listen(_onMessage);
    _sendPort.send(_receivePort.sendPort);
  }

  void _onMessage(dynamic message) {
    final result = handleMessage(message);
    _sendPort.send(result);
  }

  dynamic handleMessage(message);
}

class Worker {
  final String debugName;
  final void Function(SendPort) entryPoint;

  late final Isolate _isolate;
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;
  final _startupCompleter = Completer<void>();

  // FIXME: this is ok as long as we don't use async
  // functions in the worker isolate, use ids?
  final Queue<Completer> _requests = ListQueue();

  Worker(this.entryPoint, {this.debugName = 'worker'});

  Future<void> start() async {
    _receivePort = ReceivePort();
    _receivePort.listen(_onResponse, onDone: _onDone);

    _isolate = await Isolate.spawn(
      entryPoint,
      _receivePort.sendPort,
      debugName: debugName,
    );

    await _startupCompleter.future;
  }

  void stop() {
    _receivePort.close();
    if (!_startupCompleter.isCompleted) {
      _startupCompleter.completeError(
        Exception('worker stopped'),
      );
    }
    _isolate.kill();
  }

  void _onDone() {
    while (_requests.isNotEmpty) {
      // TODO: replace with cancellable operation or
      // subclass exception
      _requests.removeFirst().completeError(Exception('worker stopped'));
    }
  }

  void _onResponse(dynamic response) {
    if (response is SendPort) {
      _sendPort = response;
      _startupCompleter.complete();
      return;
    }

    final completer = _requests.removeFirst();

    if (response is Exception) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }
  }

  Future<T> enqueueRequest<T>(request) {
    final completer = Completer<T>();
    _requests.addLast(completer);
    _sendPort.send(request);
    return completer.future;
  }
}

typedef WorkerFunc<Q, R> = FutureOr<R> Function(Q);

class _WorkerConfig<Q, R> {
  final WorkerFunc<Q, R> worker;
  final Q message;
  final SendPort sendPort;

  const _WorkerConfig(this.worker, this.message, this.sendPort);
}

class _WorkerResult<R> {
  final R result;

  const _WorkerResult(this.result);
}

class _WorkerError {
  final Object error;
  final StackTrace? stackTrace;

  const _WorkerError(this.error, this.stackTrace);
}

Future<void> _workerEntryPoint<Q, R>(_WorkerConfig<Q, R> config) async {
  late final dynamic result;
  try {
    result = _WorkerResult(await config.worker(config.message));
  } catch (e, s) {
    result = _WorkerError(e, s);
  }
  Isolate.exit(config.sendPort, result);
}

// based on Flutter's compute function
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/foundation/_isolates_io.dart

Future<R> inBackground<Q, R>(
  WorkerFunc<Q, R> worker,
  Q message, {
  String? debugName,
}) async {
  final recvPort = ReceivePort();

  try {
    await Isolate.spawn<_WorkerConfig<Q, R>>(
      _workerEntryPoint,
      _WorkerConfig(
        worker,
        message,
        recvPort.sendPort,
      ),
      onError: recvPort.sendPort,
      onExit: recvPort.sendPort,
      debugName: debugName,
    );
  } on Object {
    recvPort.close();
    rethrow;
  }

  final resp = await recvPort.first;

  if (resp == null) throw RemoteError('Isolate exited', '');
  // Isolate.addErrorListener
  if (resp is List<String?>) throw RemoteError(resp[0] ?? '', resp[1] ?? '');
  if (resp is _WorkerError) await Future.error(resp.error, resp.stackTrace);
  assert(resp is _WorkerResult<R>);
  return resp.result;
}
