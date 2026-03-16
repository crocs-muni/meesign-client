import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:meesign_client/reporter.dart';
import 'package:meesign_client/services/settings_controller.dart';
import 'package:meesign_client/sessions/anonymous_session.dart';
import 'package:meesign_client/sessions/user_session.dart';
import 'package:meesign_core/meesign_data.dart';

class AppContainer {
  AppContainer._({required this.dataPath});
  final String dataPath;

  static Future<AppContainer> create({required String appDirectory}) async {
    final container = AppContainer._(dataPath: '$appDirectory/data/');
    await container._init();
    return container;
  }

  late KeyStore keyStore;
  late FileStore fileStore;

  late Database database;
  late UserRepository userRepository;

  late SettingsController settingsController;

  UserSession? session;

  final Reporter reporter = Reporter(Logger.root);

  final bool allowBadCerts = const bool.fromEnvironment('ALLOW_BAD_CERTS');
  Future<List<int>?> get caCerts async {
    final data = await rootBundle.load('assets/ca-cert.pem');
    return data.lengthInBytes == 0 ? null : data.buffer.asUint8List();
  }

  Future<void> _init() async {
    keyStore = KeyStore(dataPath);
    fileStore = FileStore(dataPath);
    await keyStore.init();
    await fileStore.init();
    database = Database(openDatabaseConnection(dataPath));
    userRepository = UserRepository(database.userDao);
    settingsController = SettingsController();
  }

  Future<void> recreate({bool deleteData = false}) async {
    settingsController.updateCurrentUserId('logged out');

    try {
      if (deleteData) {
        final userDid = session?.user.did ?? Uuid(const []);
        await deleteDevice(userDid);
      }

      await endUserSession();
      await database.close();
    } on Exception catch (e) {
      Logger.root.severe(e.toString(), e);
    }
    await _init();
  }

  Future<void> deleteDevice(Uuid userDid) async {
    final userDataPath = '$dataPath${userDid.encode()}/';

    // 1. Delete user from local DB
    await userRepository.deleteUser(userDid.bytes);

    // 2. Delete device from local db
    await session?.deviceRepository.deleteLocalDevice(userDid.bytes);

    // 3. Delete user data
    await fileStore.deleteDirectory(userDataPath);
  }

  Future<AnonymousSession> createAnonymousSession(String host) async {
    return AnonymousSession(
      host,
      await caCerts,
      keyStore,
      fileStore,
      database,
      allowBadCerts: allowBadCerts,
    );
  }

  Future<UserSession> startUserSession(User user) async {
    // End any existing session before starting a new one
    await endUserSession();

    session = UserSession(
      user,
      await caCerts,
      keyStore,
      fileStore,
      database,
      allowBadCerts: allowBadCerts,
    );
    reporter.start(session!.supportServices);
    return session!;
  }

  Future<void> endUserSession() async {
    reporter.stop();
    if (session != null) {
      await session!.dispose();
      session = null;
    }
  }

  Future<void> dispose() async {
    await endUserSession();
    await database.close();
  }
}
