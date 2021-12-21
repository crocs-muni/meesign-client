import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'mpc_sigs_lib.dart';
import 'pdf_sig_lib.dart';

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

class WorkerRequest {}

class WorkerResponse {}

class PdfSignRequest extends WorkerRequest {
  final String inPath;
  final String outPath;
  final String message;
  PdfSignRequest(this.inPath, this.outPath, this.message);
}

class PdfSignResponse extends WorkerResponse {}

class DylibWorker {
  final ReceivePort _receivePort;
  final SendPort _sendPort;

  final MpcSigsLib mpcLib = MpcSigsLib(dlOpen('mpc_sigs'));
  final PdfSigLib pdfLib = PdfSigLib(dlOpen('pdf-sig'));

  DylibWorker(this._receivePort, this._sendPort) {
    _receivePort.listen(_handleMessage);
  }

  void _handleMessage(dynamic message) {
    assert(message is WorkerRequest);

    if (message is PdfSignRequest) {
      _signPdf(message);
      return;
    }

    log('Unhandled worker request', error: message);
  }

  static void main(SendPort sendPort) {
    // establish 2-way communication
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    DylibWorker(receivePort, sendPort);
  }

  void _signPdf(PdfSignRequest request) {
    using((Arena alloc) {
      final certKey = alloc.using(mpcLib.cert_key_new(), mpcLib.cert_key_free);

      final pInPath =
          request.inPath.toNativeUtf8(allocator: alloc).cast<Int8>();
      final pOutPath =
          request.outPath.toNativeUtf8(allocator: alloc).cast<Int8>();
      final pMessage =
          request.message.toNativeUtf8(allocator: alloc).cast<Int8>();

      pdfLib.pdf_sign(
        pInPath,
        pOutPath,
        pMessage,
        mpcLib.cert_key_get_key(certKey),
        mpcLib.cert_key_get_cert(certKey),
      );
    });

    _sendPort.send(PdfSignResponse());
  }
}
