import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart';

enum Protocol {
  gg18(6, 10),
  elgamal(4, 2);

  final int keygenRounds;
  final int signRounds;

  const Protocol(this.keygenRounds, this.signRounds);
}

extension ProtocolConversion on Protocol {
  int toNative() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolId.Gg18;
      case Protocol.elgamal:
        return ProtocolId.Elgamal;
    }
  }

  ProtocolType toNetwork() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolType.GG18;
      case Protocol.elgamal:
        return ProtocolType.ELGAMAL;
    }
  }

  static Protocol fromNetwork(ProtocolType protocolType) {
    switch (protocolType) {
      case ProtocolType.GG18:
        return Protocol.gg18;
      case ProtocolType.ELGAMAL:
        return Protocol.elgamal;
      default:
        throw ArgumentError('Unknown protocol');
    }
  }
}
