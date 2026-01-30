import 'package:meesign_client/sessions/anonymous_session.dart';
import 'package:meesign_client/sync.dart';
import 'package:meesign_core/meesign_core.dart';

class UserSession extends AnonymousSession {
  UserSession(
    this.user,
    List<int>? serverCerts,
    KeyStore keyStore,
    FileStore fileStore,
    Database database, {
    required bool allowBadCerts,
  }) : super(
          user.host,
          serverCerts,
          keyStore,
          fileStore,
          database,
          allowBadCerts: allowBadCerts,
        );
  final User user;

  final Sync sync = Sync();

  void startSync() {
    sync.init(user.did, [
      groupRepository,
      fileRepository,
      challengeRepository,
      decryptRepository,
    ]);
  }

  @override
  Future<void> dispose() async {
    await sync.dispose();
    super.dispose();
  }
}
