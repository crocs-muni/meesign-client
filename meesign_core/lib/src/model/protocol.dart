import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart';

enum Protocol {
  gg18(6, 10);

  final int keygenRounds;
  final int signRounds;

  const Protocol(this.keygenRounds, this.signRounds);
}

extension ProtocolConversion on Protocol {
  int toNative() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolId.Gg18;
    }
  }

  ProtocolType toNetwork() {
    switch (this) {
      case Protocol.gg18:
        return ProtocolType.GG18;
    }
  }

  static Protocol fromNetwork(ProtocolType protocolType) {
    switch (protocolType) {
      case ProtocolType.GG18:
        return Protocol.gg18;
      default:
        throw ArgumentError('Unknown protocol');
    }
  }
}
