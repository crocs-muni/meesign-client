import 'package:meesign_core/src/data/network_dispatcher.dart';
import 'package:meesign_core/src/util/uuid.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meesign_network/meesign_network.dart'
    show CallOptions, GrpcError, ServerInfoRequest;
import 'package:pub_semver/pub_semver.dart';

class UnknownDeviceException implements Exception {}

class SupportServices {
  SupportServices(this._dispatcher);
  final NetworkDispatcher _dispatcher;

  static final serverVersionConstraint =
      VersionConstraint.compatibleWith(Version(0, 5, 1));

  Future<Version> getVersion([Uuid? did]) async {
    final client = did != null ? _dispatcher[did] : _dispatcher.unauth;
    final info = await client.getServerInfo(
      ServerInfoRequest(),
      options: CallOptions(timeout: const Duration(seconds: 10)),
    );
    return Version.parse(info.version);
  }

  Future<bool> checkCompatibility([Uuid? did]) async {
    try {
      return serverVersionConstraint.allows(await getVersion(did));
    } on GrpcError catch (e) {
      // FIXME: any better solution?
      if (e.message == 'Unknown device certificate') {
        throw UnknownDeviceException();
      }
      rethrow;
    }
  }

  Future<void> log(Uuid? did, String message) =>
      (did != null ? _dispatcher[did] : _dispatcher.unauth)
          .log(rpc.LogRequest()..message = message);
}
