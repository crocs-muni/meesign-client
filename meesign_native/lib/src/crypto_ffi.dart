import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'package:meesign_native/src/crypto_interface.dart';
import 'package:meesign_native/src/dl_util.dart';
import 'package:meesign_native/src/generated/meesign_crypto_lib.dart'
    as ffi_lib;

export 'package:meesign_native/src/crypto_interface.dart';

extension _IntIterConversion on Iterable<int> {
  Pointer<Uint8> dupToNative(Allocator alloc) {
    final buf = alloc<Uint8>(length);
    buf.asTypedList(length).setAll(0, this);
    return buf;
  }
}

extension _BufferConversion on ffi_lib.Buffer {
  Uint8List asTypedList() => ptr.asTypedList(len);
  Uint8List dupToDart() => Uint8List.fromList(asTypedList());
}

final ffi_lib.MeeSignCryptoLib _lib =
    ffi_lib.MeeSignCryptoLib(dlOpen('meesign_crypto'));

class _Error {
  _Error() : ptr = calloc();
  Pointer<Pointer<Char>> ptr;

  bool get occured => ptr.value != nullptr;

  String get message => ptr.value.cast<Utf8>().toDartString();

  static void free(_Error error) {
    _lib.error_free(error.ptr.value);
    calloc.free(error.ptr);
    error.ptr = nullptr;
  }
}

Future<CryptoInterface> createCryptoInstance() async {
  final instance = CryptoFfi();
  initCrypto(instance);
  return instance;
}

class CryptoFfi implements CryptoInterface {
  @override
  Uint8List protocolKeygen(
    int protoId,
    Uint8List certs,
    Uint8List pkcs12, {
    bool withCard = false,
    int shares = 1,
  }) {
    return using((Arena alloc) {
      final certsBuf = certs.dupToNative(alloc);
      final pkcs12Buf = pkcs12.dupToNative(alloc);

      final proto = _lib.protocol_keygen(
        protoId,
        certsBuf,
        certs.length,
        pkcs12Buf,
        pkcs12.length,
        withCard,
        shares,
      );
      final context = alloc.using(
        _lib.protocol_serialize(proto),
        _lib.buffer_free,
      );

      return context.dupToDart();
    });
  }

  @override
  Uint8List protocolInit(
    int protoId,
    Uint8List group,
    Uint8List certs,
    Uint8List pkcs12, {
    int shares = 1,
  }) {
    return using((Arena alloc) {
      final groupBuf = group.dupToNative(alloc);
      final certsBuf = certs.dupToNative(alloc);
      final pkcs12Buf = pkcs12.dupToNative(alloc);

      final proto = _lib.protocol_init(
        protoId,
        groupBuf,
        group.length,
        certsBuf,
        certs.length,
        pkcs12Buf,
        pkcs12.length,
        shares,
      );
      final context = alloc.using(
        _lib.protocol_serialize(proto),
        _lib.buffer_free,
      );

      return context.dupToDart();
    });
  }

  static ProtocolData _advanceWorker(
    Uint8List context,
    List<List<int>> data,
  ) {
    return using((Arena alloc) {
      final ctxBuf = context.dupToNative(alloc);
      final error = alloc.using(_Error(), _Error.free);

      final proto = _lib.protocol_deserialize(ctxBuf, context.length);

      final dartDataOut = <Uint8List>[];
      var recipient = ffi_lib.Recipient.Unknown;

      for (final (i, chunk) in data.indexed) {
        final dataBuf = chunk.dupToNative(alloc);
        final dataOut = alloc.using(
          _lib.protocol_advance(proto, i, dataBuf, chunk.length, error.ptr),
          _lib.buffer_free,
        );
        if (error.occured) throw ProtocolException(error.message);
        dartDataOut.add(dataOut.dupToDart());
        recipient = dataOut.rec;
      }

      final contextOut = alloc.using(
        _lib.protocol_serialize(proto),
        _lib.buffer_free,
      );

      return ProtocolData(contextOut.dupToDart(), dartDataOut, recipient);
    });
  }

  @override
  Future<ProtocolData> protocolAdvance(
    Uint8List context,
    List<List<int>> data,
  ) {
    return Isolate.run(() => _advanceWorker(context, data));
  }

  @override
  Uint8List protocolFinish(Uint8List context) {
    return using((Arena alloc) {
      final ctxBuf = context.dupToNative(alloc);
      final error = alloc.using(_Error(), _Error.free);

      final proto = _lib.protocol_deserialize(ctxBuf, context.length);
      final data = alloc.using(
        _lib.protocol_finish(proto, error.ptr),
        _lib.buffer_free,
      );

      if (error.occured) throw ProtocolException(error.message);
      return data.dupToDart();
    });
  }

  @override
  AuthKey authKeygen(String name) {
    return using((Arena alloc) {
      final namePtr = name.toNativeUtf8(allocator: alloc);
      final error = alloc.using(_Error(), _Error.free);

      final res = alloc.using(
        _lib.auth_keygen(namePtr.cast(), error.ptr),
        _lib.auth_key_free,
      );

      if (error.occured) throw Exception(error.message);

      return AuthKey(res.key.dupToDart(), res.csr.dupToDart());
    });
  }

  @override
  List<int> authCertKeyToPkcs12(List<int> key, List<int> cert) {
    return using((Arena alloc) {
      final keyPtr = key.dupToNative(alloc);
      final certPtr = cert.dupToNative(alloc);
      final error = alloc.using(_Error(), _Error.free);

      final res = alloc.using(
        _lib.auth_cert_key_to_pkcs12(
          keyPtr,
          key.length,
          certPtr,
          cert.length,
          error.ptr,
        ),
        _lib.buffer_free,
      );

      if (error.occured) throw Exception(error.message);

      return res.dupToDart();
    });
  }

  @override
  List<int> elgamalEncrypt(List<int> message, List<int> publicKey) {
    return using((Arena alloc) {
      final messagePtr = message.dupToNative(alloc);
      final publicKeyPtr = publicKey.dupToNative(alloc);
      final error = alloc.using(_Error(), _Error.free);

      final res = alloc.using(
        _lib.encrypt(
          messagePtr.cast(),
          message.length,
          publicKeyPtr,
          publicKey.length,
          error.ptr,
        ),
        _lib.buffer_free,
      );

      if (error.occured) throw Exception(error.message);

      return res.dupToDart();
    });
  }
}
