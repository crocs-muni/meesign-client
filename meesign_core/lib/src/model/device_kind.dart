import 'package:meesign_network/grpc.dart' as rpc;

enum DeviceKind {
  user,
  bot
}

extension DeviceKindConversion on DeviceKind {
  rpc.DeviceKind toNetwork() {
    switch (this) {
      case DeviceKind.user:
        return rpc.DeviceKind.USER;
      case DeviceKind.bot:
        return rpc.DeviceKind.BOT;
    }
  }

  static DeviceKind fromNetwork(rpc.DeviceKind deviceKind) {
    switch (deviceKind) {
      case rpc.DeviceKind.USER:
        return DeviceKind.user;
      case rpc.DeviceKind.BOT:
        return DeviceKind.bot;
      default:
        throw ArgumentError('Unknown device kind');
    }
  }
}
