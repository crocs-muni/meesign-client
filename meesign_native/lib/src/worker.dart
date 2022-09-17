import 'dart:async';
import 'dart:isolate';

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
