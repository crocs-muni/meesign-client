import 'package:grpc/grpc.dart';

import 'generated/mpc.pbgrpc.dart';

class ClientFactory {
  static MPCClient create(String host, {int port = 1337}) => MPCClient(
        ClientChannel(
          host,
          port: port,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
          ),
        ),
      );
}
