import 'package:grpc/grpc.dart';

import 'generated/mpc.pbgrpc.dart';

class ClientFactory {
  static MPCClient create(
    String host, {
    List<int>? certs,
    bool allowBadCerts = false,
    int port = 1337,
  }) =>
      MPCClient(
        ClientChannel(
          host,
          port: port,
          options: ChannelOptions(
            credentials: ChannelCredentials.secure(
              certificates: certs,
              onBadCertificate: allowBadCerts ? allowBadCertificates : null,
            ),
          ),
        ),
      );
}
