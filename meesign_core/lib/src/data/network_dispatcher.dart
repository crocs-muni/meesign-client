import 'dart:collection';

import 'package:meesign_core/src/data/key_store.dart';
import 'package:meesign_core/src/util/uuid.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meesign_network/meesign_network.dart' show ClientFactory;

class NetworkDispatcher {
  NetworkDispatcher(
    this.host,
    this._keyStore, {
    this.serverCerts,
    this.allowBadCerts = false,
    this.port = 1337,
  });
  final String host;
  final int port;
  final KeyStore _keyStore;
  final List<int>? serverCerts;
  final bool allowBadCerts;

  // TODO(dev): shutdown?
  final Map<Uuid, rpc.MeeSignClient> _clients = HashMap();

  late final rpc.MeeSignClient unauth = _createClient();

  rpc.MeeSignClient _createClient({List<int>? certKey}) => ClientFactory.create(
        host,
        key: certKey,
        password: '',
        clientCerts: certKey,
        serverCerts: serverCerts,
        allowBadCerts: allowBadCerts,
        port: port,
        connectTimeout: const Duration(seconds: 8),
      );

  rpc.MeeSignClient operator [](Uuid did) {
    _clients[did] ??= _createClient(certKey: _keyStore.load(did));
    return _clients[did]!;
  }
}
