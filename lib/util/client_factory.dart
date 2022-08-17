import 'package:grpc/grpc.dart';

import '../grpc/generated/mpc.pbgrpc.dart' as rpc;

class ClientFactory {
  static rpc.MPCClient create(String host) => rpc.MPCClient(
        ClientChannel(
          host,
          port: 1337,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
          ),
        ),
      );
}
