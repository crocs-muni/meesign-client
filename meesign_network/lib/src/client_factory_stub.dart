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
    throw UnsupportedError(
      'Cannot create gRPC client: no implementation for this platform.',
    );
  }
}
