import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart';

enum ThresholdType {
  tOfN,
  nOfN,
}

enum Protocol {
  gg18(10, 10, ThresholdType.tOfN),
  elgamal(6, 2, ThresholdType.tOfN),
  frost(4, 3, ThresholdType.tOfN, aid: '6a6366726f7374617070'),
  musig2(2, 3, ThresholdType.nOfN, aid: '01ffff04050607081101');

  final int keygenRounds;
  final int signRounds;
  final ThresholdType thresholdType;
  final String? aid;

  const Protocol(
    this.keygenRounds,
    this.signRounds,
    this.thresholdType, {
    this.aid,
  });

  bool get cardSupport => aid != null;
}

extension ProtocolConversion on Protocol {
  int toNative() => switch (this) {
        Protocol.gg18 => ProtocolId.Gg18,
        Protocol.elgamal => ProtocolId.Elgamal,
        Protocol.frost => ProtocolId.Frost,
        Protocol.musig2 => ProtocolId.Musig2,
      };

  ProtocolType toNetwork() => switch (this) {
        Protocol.gg18 => ProtocolType.GG18,
        Protocol.elgamal => ProtocolType.ELGAMAL,
        Protocol.frost => ProtocolType.FROST,
        Protocol.musig2 => ProtocolType.MUSIG2,
      };

  static Protocol fromNetwork(ProtocolType protocolType) =>
      switch (protocolType) {
        ProtocolType.GG18 => Protocol.gg18,
        ProtocolType.ELGAMAL => Protocol.elgamal,
        ProtocolType.FROST => Protocol.frost,
        ProtocolType.MUSIG2 => Protocol.musig2,
        _ => throw ArgumentError('Unknown protocol'),
      };
}
