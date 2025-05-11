import 'package:meesign_core/meesign_core.dart';

import '../sync.dart';
import 'anonymous_session.dart';

class UserSession extends AnonymousSession {
  final User user;

  final Sync sync = Sync();

  UserSession(
    this.user,
    List<int>? serverCerts,
    bool allowBadCerts,
    KeyStore keyStore,
    FileStore fileStore,
    Database database,
  ) : super(
          user.host,
          serverCerts,
          allowBadCerts,
          keyStore,
          fileStore,
          database,
        );

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
