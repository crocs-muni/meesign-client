import 'package:grpc/grpc_web.dart';

import 'generated/mpc.pbgrpc.dart';

class ClientFactory {
  static MPCClient create(
    String host, {
    List<int>? key,
    String? password,
    List<int>? clientCerts,
    List<int>? serverCerts,
    bool allowBadCerts = false,
    int port = 1337,
    Duration? connectTimeout,
  }) {
    return MPCClient(
      GrpcWebClientChannel.xhr(Uri(
        host: host,
        port: port,
        scheme: 'https',
      )),
    );
  }
}
