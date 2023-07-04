import 'dart:io';

import 'package:grpc/grpc.dart';

import 'generated/mpc.pbgrpc.dart';

class ClientChannelCredentials extends ChannelCredentials {
  final List<int>? _key;
  final String? _password;
  final List<int>? _clientCerts;
  final List<int>? _serverCerts;

  const ClientChannelCredentials(
    this._key,
    this._password,
    this._clientCerts,
    this._serverCerts,
    BadCertificateHandler? onBadCertificate,
  ) : super.secure(onBadCertificate: onBadCertificate);

  @override
  SecurityContext get securityContext {
    final context = SecurityContext()
      ..setAlpnProtocols(supportedAlpnProtocols, false);

    // TODO: use files insead of bytes?
    if (_key != null) {
      context.usePrivateKeyBytes(_key!, password: _password);
    }
    if (_clientCerts != null) {
      context.useCertificateChainBytes(_clientCerts!, password: _password);
    }
    if (_serverCerts != null) {
      context.setTrustedCertificatesBytes(_serverCerts!);
    }

    return context;
  }
}

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
  }) =>
      MPCClient(
        ClientChannel(
          host,
          port: port,
          options: ChannelOptions(
            connectTimeout: connectTimeout,
            credentials: ClientChannelCredentials(
              key,
              password,
              clientCerts,
              serverCerts,
              allowBadCerts ? allowBadCertificates : null,
            ),
          ),
        ),
      );
}
