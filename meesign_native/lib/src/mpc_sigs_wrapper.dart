import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'dl_util.dart';
import 'generated/mpc_sigs_lib.dart';
import 'worker.dart';

// TODO: profile the functions in this file
// many chunks of data are copied, can it be avoided?
// keygen() and sign() do perform some serialization, is it quick enough?

// TODO: consider newer alternative solutions
// e.g. flutter rust bridge, membrane

extension IntIterConversion on Iterable<int> {
  Pointer<Uint8> dupToNative(Allocator alloc) {
    final buf = alloc<Uint8>(length);
    buf.asTypedList(length).setAll(0, this);
    return buf;
  }
}

extension BufferConversion on Buffer {
  Uint8List asTypedList() => ptr.asTypedList(len);

  Uint8List dupToDart() => Uint8List.fromList(asTypedList());
}

class ProtocolException implements Exception {
  final String message;
  ProtocolException(this.message);
}

class ProtocolData {
  final Uint8List context, data;
  ProtocolData(this.context, this.data);
}

class _TransProtocolData {
  final TransferableTypedData _context, _data;

  _TransProtocolData(Uint8List context, Uint8List data)
      : _context = TransferableTypedData.fromList([context]),
        _data = TransferableTypedData.fromList([data]);

  ProtocolData materialize() => ProtocolData(
        _context.materialize().asUint8List(),
        _data.materialize().asUint8List(),
      );
}

final MpcSigsLib _lib = MpcSigsLib(dlOpen('mpc_sigs'));

class Error {
  Pointer<Pointer<Char>> ptr;

  bool get occured => ptr.value != nullptr;

  String get message => ptr.value.cast<Utf8>().toDartString();

  Error() : ptr = calloc();

  static void free(Error error) {
    _lib.error_free(error.ptr.value);
    calloc.free(error.ptr);
    error.ptr = nullptr;
  }
}

class ProtocolWrapper {
  static Uint8List keygen(int protoId) {
    return using((Arena alloc) {
      final res = alloc.using(
        _lib.protocol_keygen(protoId),
        _lib.protocol_result_free,
      );

      return res.context.dupToDart();
    });
  }

  static Uint8List sign(int protoId, Uint8List group) {
    return using((Arena alloc) {
      final groupBuf = group.dupToNative(alloc);

      final res = alloc.using(
        _lib.protocol_sign(protoId, groupBuf, group.length),
        _lib.protocol_result_free,
      );

      return res.context.dupToDart();
    });
  }

  static _TransProtocolData _advanceWorker(_TransProtocolData payload) {
    return using((Arena alloc) {
      final protoData = payload.materialize();

      final ctxBuf = protoData.context.dupToNative(alloc);
      final dataBuf = protoData.data.dupToNative(alloc);
      final error = alloc.using(Error(), Error.free);

      final res = alloc.using(
        _lib.protocol_advance(
          ctxBuf,
          protoData.context.length,
          dataBuf,
          protoData.data.length,
          error.ptr,
        ),
        _lib.protocol_result_free,
      );

      if (error.occured) throw ProtocolException(error.message);
      return _TransProtocolData(
        res.context.asTypedList(),
        res.data.asTypedList(),
      );
    });
  }

  static Future<ProtocolData> advance(Uint8List context, Uint8List data) async {
    final res = await inBackground(
      _advanceWorker,
      _TransProtocolData(context, data),
    );
    return res.materialize();
  }

  static Uint8List finish(Uint8List context) {
    return using((Arena alloc) {
      final ctxBuf = context.dupToNative(alloc);
      final error = alloc.using(Error(), Error.free);

      final res = alloc.using(
        _lib.protocol_finish(ctxBuf, context.length, error.ptr),
        _lib.protocol_result_free,
      );

      if (error.occured) throw ProtocolException(error.message);
      return res.data.dupToDart();
    });
  }
}
