import 'package:grpc/grpc_web.dart';

import 'package:meesign_network/src/generated/meesign.pbgrpc.dart';

class ClientFactory {
  static MeeSignClient create(
    String host, {
    List<int>? key,
    String? password,
    List<int>? clientCerts,
    List<int>? serverCerts,
    bool allowBadCerts = false,
    int port = 1337,
    Duration? connectTimeout,
    String? authToken,
  }) {
    // On web, use gRPC-Web channel (HTTP/1.1 compatible)
    // mTLS parameters (key, clientCerts, serverCerts) are ignored on web
    // since browsers don't support programmatic TLS client certificates.
    final channel = GrpcWebClientChannel.xhr(
      Uri.parse('https://$host:$port'),
    );

    final options = authToken != null
        ? CallOptions(metadata: {'authorization': 'Bearer $authToken'})
        : null;

    return MeeSignClient(channel, options: options);
  }
}
