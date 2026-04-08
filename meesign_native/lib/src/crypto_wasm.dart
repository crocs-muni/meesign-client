import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:meesign_native/src/crypto_interface.dart';

export 'package:meesign_native/src/crypto_interface.dart';

/// JS bindings to the wasm-bindgen generated glue code.
/// These correspond to the functions in wasm_api.rs.
@JS('wasm_bindgen.wasm_protocol_keygen')
external JSUint8Array _jsProtocolKeygen(
  JSNumber protoId,
  JSUint8Array certs,
  JSUint8Array pkcs12,
  JSBoolean withCard,
  JSNumber shares,
);

@JS('wasm_bindgen.wasm_protocol_init')
external JSUint8Array _jsProtocolInit(
  JSNumber protoId,
  JSUint8Array group,
  JSUint8Array certs,
  JSUint8Array pkcs12,
  JSNumber shares,
);

@JS('wasm_bindgen.wasm_protocol_advance')
external JSObject _jsProtocolAdvance(
  JSUint8Array context,
  JSNumber index,
  JSUint8Array data,
);

@JS('wasm_bindgen.wasm_protocol_finish')
external JSUint8Array _jsProtocolFinish(JSUint8Array context);

@JS('wasm_bindgen.wasm_auth_keygen')
external JSObject _jsAuthKeygen(JSString name);

@JS('wasm_bindgen.wasm_auth_cert_key_to_pkcs12')
external JSUint8Array _jsAuthCertKeyToPkcs12(
  JSUint8Array key,
  JSUint8Array cert,
);

@JS('wasm_bindgen.wasm_encrypt')
external JSUint8Array _jsEncrypt(
  JSUint8Array message,
  JSUint8Array publicKey,
);

Future<CryptoInterface> createCryptoInstance() async {
  // Initialize the WASM module by calling wasm_bindgen('meesign_crypto_bg.wasm')
  // which fetches, compiles, and instantiates the WASM binary.
  final wbInit = globalContext['wasm_bindgen']! as JSFunction;
  final promise =
      wbInit.callAsFunction(null, 'meesign_crypto_bg.wasm'.toJS)! as JSPromise;
  await promise.toDart;

  final instance = CryptoWasm();
  initCrypto(instance);
  return instance;
}

class CryptoWasm implements CryptoInterface {
  @override
  Uint8List protocolKeygen(
    int protoId,
    Uint8List certs,
    Uint8List pkcs12, {
    bool withCard = false,
    int shares = 1,
  }) {
    final result = _jsProtocolKeygen(
      protoId.toJS,
      certs.toJS,
      pkcs12.toJS,
      withCard.toJS,
      shares.toJS,
    );
    return result.toDart;
  }

  @override
  Uint8List protocolInit(
    int protoId,
    Uint8List group,
    Uint8List certs,
    Uint8List pkcs12, {
    int shares = 1,
  }) {
    final result = _jsProtocolInit(
      protoId.toJS,
      group.toJS,
      certs.toJS,
      pkcs12.toJS,
      shares.toJS,
    );
    return result.toDart;
  }

  @override
  Future<ProtocolData> protocolAdvance(
    Uint8List context,
    List<List<int>> data,
  ) async {
    // No isolates on web — run on the main thread
    var currentContext = context;
    final dartDataOut = <Uint8List>[];
    var recipient = Recipient.Unknown;

    for (var i = 0; i < data.length; i++) {
      final chunk = Uint8List.fromList(data[i]);
      final result = _jsProtocolAdvance(
        currentContext.toJS,
        i.toJS,
        chunk.toJS,
      );

      currentContext = (result['context']! as JSUint8Array).toDart;
      dartDataOut.add((result['data']! as JSUint8Array).toDart);
      recipient = (result['recipient']! as JSNumber).toDartInt;
    }

    return ProtocolData(currentContext, dartDataOut, recipient);
  }

  @override
  Uint8List protocolFinish(Uint8List context) {
    return _jsProtocolFinish(context.toJS).toDart;
  }

  @override
  AuthKey authKeygen(String name) {
    final result = _jsAuthKeygen(name.toJS);
    final key = (result['key']! as JSUint8Array).toDart;
    final csr = (result['csr']! as JSUint8Array).toDart;
    return AuthKey(key, csr);
  }

  @override
  List<int> authCertKeyToPkcs12(List<int> key, List<int> cert) {
    return _jsAuthCertKeyToPkcs12(
      Uint8List.fromList(key).toJS,
      Uint8List.fromList(cert).toJS,
    ).toDart;
  }

  @override
  List<int> elgamalEncrypt(List<int> message, List<int> publicKey) {
    return _jsEncrypt(
      Uint8List.fromList(message).toJS,
      Uint8List.fromList(publicKey).toJS,
    ).toDart;
  }
}
