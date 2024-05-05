import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meesign_network/meesign_network.dart';
import 'package:pub_semver/pub_semver.dart';

import '../util/uuid.dart';
import 'network_dispatcher.dart';

class SupportServices {
  final NetworkDispatcher _dispatcher;

  SupportServices(this._dispatcher);

  Future<Version> getVersion([Uuid? did]) async {
    final info = await (did != null ? _dispatcher[did] : _dispatcher.unauth)
        .getServerInfo(ServerInfoRequest());
    return Version.parse(info.version);
  }

  Future<void> log(Uuid? did, String message) =>
      (did != null ? _dispatcher[did] : _dispatcher.unauth)
          .log(rpc.LogRequest()..message = message);
}
