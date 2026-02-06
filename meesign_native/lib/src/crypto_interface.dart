import 'dart:typed_data';

class ProtocolData {
  ProtocolData(this.context, this.data, this.recipient);
  final Uint8List context;
  final List<Uint8List> data;
  final int recipient;
}

class AuthKey {
  AuthKey(this.key, this.csr);
  final Uint8List key;
  final Uint8List csr;
}

class ProtocolException implements Exception {
  ProtocolException(this.message);
  final String message;

  @override
  String toString() {
    return 'ProtocolException: $message';
  }
}

/// Protocol IDs matching the Rust ProtocolId enum.
/// Names match the original FFI-generated constants for backward compatibility.
class ProtocolId {
  // ignore: constant_identifier_names, matches Rust ProtocolId enum variant
  static const int Gg18 = 0;
  // ignore: constant_identifier_names, matches Rust ProtocolId enum variant
  static const int Elgamal = 1;
  // ignore: constant_identifier_names, matches Rust ProtocolId enum variant
  static const int Frost = 2;
  // ignore: constant_identifier_names, matches Rust ProtocolId enum variant
  static const int Musig2 = 3;
}

/// Recipient types matching the Rust Recipient enum.
class Recipient {
  // ignore: constant_identifier_names, matches Rust Recipient enum variant
  static const int Unknown = 0;
  // ignore: constant_identifier_names, matches Rust Recipient enum variant
  static const int Card = 1;
  // ignore: constant_identifier_names, matches Rust Recipient enum variant
  static const int Server = 2;
}

/// Abstract interface for cryptographic operations.
/// Implemented by CryptoFfi (native) and CryptoWasm (web).
abstract class CryptoInterface {
  Uint8List protocolKeygen(
    int protoId,
    Uint8List certs,
    Uint8List pkcs12, {
    bool withCard = false,
    int shares = 1,
  });

  Uint8List protocolInit(
    int protoId,
    Uint8List group,
    Uint8List certs,
    Uint8List pkcs12, {
    int shares = 1,
  });

  Future<ProtocolData> protocolAdvance(
    Uint8List context,
    List<List<int>> data,
  );

  Uint8List protocolFinish(Uint8List context);

  AuthKey authKeygen(String name);

  List<int> authCertKeyToPkcs12(List<int> key, List<int> cert);

  List<int> elgamalEncrypt(List<int> message, List<int> publicKey);
}

/// Global crypto instance. Initialized lazily via the platform-specific
/// `createCryptoInstance()` function from conditional imports.
CryptoInterface? _cryptoInstance;

/// Get the platform crypto instance. Call `initCrypto()` first or let
/// the static wrapper classes handle it automatically.
CryptoInterface get crypto {
  if (_cryptoInstance == null) {
    throw StateError(
      'Crypto not initialized. Call initCrypto() first.',
    );
  }
  return _cryptoInstance!;
}

/// Initialize the crypto subsystem with a platform-specific implementation.
void initCrypto(CryptoInterface instance) {
  _cryptoInstance = instance;
}

/// Static convenience wrapper matching the existing ProtocolWrapper API.
class ProtocolWrapper {
  static Uint8List keygen(
    int protoId,
    Uint8List certs,
    Uint8List pkcs12, {
    bool withCard = false,
    int shares = 1,
  }) =>
      crypto.protocolKeygen(
        protoId,
        certs,
        pkcs12,
        withCard: withCard,
        shares: shares,
      );

  static Uint8List init(
    int protoId,
    Uint8List group,
    Uint8List certs,
    Uint8List pkcs12, {
    int shares = 1,
  }) =>
      crypto.protocolInit(protoId, group, certs, pkcs12, shares: shares);

  static Future<ProtocolData> advance(
    Uint8List context,
    List<List<int>> data,
  ) =>
      crypto.protocolAdvance(context, data);

  static Uint8List finish(Uint8List context) => crypto.protocolFinish(context);
}

/// Static convenience wrapper matching the existing AuthWrapper API.
class AuthWrapper {
  static AuthKey keygen(String name) => crypto.authKeygen(name);

  static List<int> certKeyToPkcs12(List<int> key, List<int> cert) =>
      crypto.authCertKeyToPkcs12(key, cert);
}

/// Static convenience wrapper matching the existing ElGamalWrapper API.
class ElGamalWrapper {
  static List<int> encrypt(List<int> message, List<int> publicKey) =>
      crypto.elgamalEncrypt(message, publicKey);
}
