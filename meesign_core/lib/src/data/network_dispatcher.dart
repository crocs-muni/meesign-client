import 'dart:collection';

import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meesign_network/meesign_network.dart' show ClientFactory;

import '../util/uuid.dart';
import 'key_store.dart';

class NetworkDispatcher {
  final String host;
  final int port;
  final KeyStore _keyStore;
  final List<int>? serverCerts;
  final bool allowBadCerts;

  // TODO: shutdown?
  final Map<Uuid, rpc.MPCClient> _clients = HashMap();

  late final unauth = _createClient(certKey: null);

  NetworkDispatcher(this.host, this._keyStore,
      {this.serverCerts, this.allowBadCerts = false, this.port = 1337});

  rpc.MPCClient _createClient({List<int>? certKey}) => ClientFactory.create(
        host,
        key: certKey,
        password: '',
        clientCerts: certKey,
        serverCerts: serverCerts,
        allowBadCerts: allowBadCerts,
        port: port,
      );

  rpc.MPCClient operator [](Uuid did) {
    _clients[did] ??= _createClient(certKey: _keyStore.load(did));
    return _clients[did]!;
  }
}
