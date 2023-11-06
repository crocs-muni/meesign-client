import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart';

enum Protocol {
  gg18(6, 10),
  elgamal(4, 2),
  frost(3, 3, aid: '6a6366726f7374617070'),
  // TODO those numbers are a guess work
  ptsrsap1(2, 2);

  final int keygenRounds;
  final int signRounds;
  final String? aid;

  const Protocol(
    this.keygenRounds,
    this.signRounds, {
    this.aid,
  });

  bool get cardSupport => aid != null;
}

extension ProtocolConversion on Protocol {
  int toNative() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolId.Gg18;
      case Protocol.elgamal:
        return ProtocolId.Elgamal;
      case Protocol.frost:
        return ProtocolId.Frost;
      case Protocol.ptsrsap1:
        return ProtocolId.Ptsrsap1;
    }
  }

  ProtocolType toNetwork() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolType.GG18;
      case Protocol.elgamal:
        return ProtocolType.ELGAMAL;
      case Protocol.frost:
        return ProtocolType.FROST;
      case Protocol.ptsrsap1:
        return ProtocolType.PTSRSAP1;
    }
  }

  static Protocol fromNetwork(ProtocolType protocolType) {
    switch (protocolType) {
      case ProtocolType.GG18:
        return Protocol.gg18;
      case ProtocolType.ELGAMAL:
        return Protocol.elgamal;
      case ProtocolType.FROST:
        return Protocol.frost;
      case ProtocolType.PTSRSAP1:
        return Protocol.ptsrsap1;
      default:
        throw ArgumentError('Unknown protocol');
    }
  }
}
