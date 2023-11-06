import 'package:meesign_core/src/model/protocol.dart';
import 'package:meesign_network/grpc.dart' as rpc;

enum KeyType {
  signPdf([Protocol.gg18, Protocol.ptsrsap1]),
  signChallenge([Protocol.gg18, Protocol.frost, Protocol.ptsrsap1]),
  decrypt([Protocol.elgamal]);

  final List<Protocol> supportedProtocols;
  const KeyType(this.supportedProtocols);
}

extension KeyTypeConversion on KeyType {
  rpc.KeyType toNetwork() {
    switch (this) {
      case KeyType.signPdf:
        return rpc.KeyType.SignPDF;
      case KeyType.signChallenge:
        return rpc.KeyType.SignChallenge;
      case KeyType.decrypt:
        return rpc.KeyType.Decrypt;
    }
  }

  static KeyType fromNetwork(rpc.KeyType keyType) {
    switch (keyType) {
      case rpc.KeyType.SignPDF:
        return KeyType.signPdf;
      case rpc.KeyType.SignChallenge:
        return KeyType.signChallenge;
      case rpc.KeyType.Decrypt:
        return KeyType.decrypt;
      default:
        throw ArgumentError('Unknown key type');
    }
  }
}
