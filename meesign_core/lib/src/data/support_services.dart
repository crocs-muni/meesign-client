import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meesign_network/meesign_network.dart';

import '../util/uuid.dart';
import 'network_dispatcher.dart';

class SupportServices {
  final NetworkDispatcher _dispatcher;

  SupportServices(this._dispatcher);

  Future<String> getVersion() async {
    final info = await _dispatcher.unauth.getServerInfo(ServerInfoRequest());
    return info.version;
  }

  Future<void> log(Uuid? did, String message) =>
      (did != null ? _dispatcher[did] : _dispatcher.unauth)
          .log(rpc.LogRequest()..message = message);
}
