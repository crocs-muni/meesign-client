import 'package:meesign_network/grpc.dart' as rpc;

enum KeyType {
  signPdf,
  signDigest,
}

extension KeyTypeConversion on KeyType {
  rpc.KeyType toNetwork() {
    switch (this) {
      case KeyType.signPdf:
        return rpc.KeyType.SignPDF;
      case KeyType.signDigest:
        return rpc.KeyType.SignDigest;
    }
  }

  static KeyType fromNetwork(rpc.KeyType keyType) {
    switch (keyType) {
      case rpc.KeyType.SignPDF:
        return KeyType.signPdf;
      case rpc.KeyType.SignDigest:
        return KeyType.signDigest;
      default:
        throw ArgumentError('Unknown key type');
    }
  }
}
