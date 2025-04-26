import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart';

enum Protocol {
  gg18(6, 10),
  elgamal(4, 2),
  frost(3, 3, aid: '6a6366726f7374617070'),
  musig2(2, 3, aid: '01ffff04050607081101');

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
