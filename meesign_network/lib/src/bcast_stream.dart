import 'dart:async';

import 'package:grpc/grpc.dart';

class BcastRespStream<T> extends StreamView<T> {
  final Future<void> headers;
  BcastRespStream(Stream<T> stream, this.headers) : super(stream);
}

extension BcastRespStreamExt<T> on ResponseStream<T> {
  /// Turn gRPC ResponseStream into a broadcast stream while
  /// preserving some of its attributes
  BcastRespStream<T> asBcastRespStream({
    void Function(StreamSubscription<T>)? onListen,
    void Function(StreamSubscription<T>)? onCancel,
  }) {
    return BcastRespStream(
      asBroadcastStream(onListen: onListen, onCancel: onCancel),
      headers,
    );
  }
}
