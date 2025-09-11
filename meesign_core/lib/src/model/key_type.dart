import 'package:meesign_core/src/model/protocol.dart';
import 'package:meesign_network/grpc.dart' as rpc;

enum KeyType {
  signPdf([Protocol.gg18]),
  signChallenge([Protocol.gg18, Protocol.frost, Protocol.musig2]),
  decrypt([Protocol.elgamal]);

  final List<Protocol> supportedProtocols;
  const KeyType(this.supportedProtocols);
}

extension KeyTypeConversion on KeyType {
  rpc.KeyType toNetwork() => switch (this) {
        KeyType.signPdf => rpc.KeyType.SignPDF,
        KeyType.signChallenge => rpc.KeyType.SignChallenge,
        KeyType.decrypt => rpc.KeyType.Decrypt,
      };

  static KeyType fromNetwork(rpc.KeyType keyType) => switch (keyType) {
        rpc.KeyType.SignPDF => KeyType.signPdf,
        rpc.KeyType.SignChallenge => KeyType.signChallenge,
        rpc.KeyType.Decrypt => KeyType.decrypt,
        _ => throw ArgumentError('Unknown key type'),
      };
}
