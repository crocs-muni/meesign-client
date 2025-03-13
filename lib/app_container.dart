import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:meesign_core/meesign_data.dart';

import 'reporter.dart';
import 'sync.dart';

class AnonymousSession {
  final String host;
  late final NetworkDispatcher dispatcher;
  late final SupportServices supportServices;

  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;
  late final ChallengeRepository challengeRepository;
  late final DecryptRepository decryptRepository;

  AnonymousSession(
    this.host,
    List<int>? serverCerts,
    bool allowBadCerts,
    KeyStore keyStore,
    FileStore fileStore,
    Database database,
  ) {
    dispatcher = NetworkDispatcher(host, keyStore,
        serverCerts: serverCerts, allowBadCerts: allowBadCerts);

    supportServices = SupportServices(dispatcher);

    deviceRepository =
        DeviceRepository(dispatcher, keyStore, database.deviceDao);
    final taskSource = TaskSource(dispatcher);
    final taskDao = database.taskDao;
    groupRepository =
        GroupRepository(dispatcher, taskSource, taskDao, deviceRepository);
    fileRepository = FileRepository(dispatcher, taskSource, taskDao, fileStore);
    challengeRepository = ChallengeRepository(dispatcher, taskSource, taskDao);
    decryptRepository = DecryptRepository(dispatcher, taskSource, taskDao);
  }

  void dispose() {
    // TODO: cleanup (e.g., close dispatcher connections?)
  }
}

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
  void dispose() {
    // TODO: stop sync
    super.dispose();
  }
}

class AppContainer {
  final Directory dataDirectory;
  late KeyStore keyStore;
  late FileStore fileStore;
  late Database database;
  late UserRepository userRepository;

  UserSession? session;

  final Reporter reporter = Reporter(Logger.root);

  final bool allowBadCerts = const bool.fromEnvironment('ALLOW_BAD_CERTS');
  Future<List<int>?> get caCerts async {
    final data = await rootBundle.load('assets/ca-cert.pem');
    return data.lengthInBytes == 0 ? null : data.buffer.asUint8List();
  }

  AppContainer({required Directory appDirectory})
      : dataDirectory = Directory('${appDirectory.path}/data/') {
    _init();
  }

  void _init() {
    keyStore = KeyStore(dataDirectory);
    fileStore = FileStore(dataDirectory);
    database = Database(dataDirectory);
    userRepository = UserRepository(database.userDao);
  }

  Future<void> recreate({bool deleteData = false}) async {
    endUserSession();
    try {
      await database.close();
      if (deleteData) await dataDirectory.delete(recursive: true);
    } catch (e) {
      Logger.root.severe(e.toString(), e);
    }
    _init();
  }

  Future<AnonymousSession> createAnonymousSession(String host) async {
    return AnonymousSession(
        host, await caCerts, allowBadCerts, keyStore, fileStore, database);
  }

  Future<UserSession> startUserSession(User user) async {
    session = UserSession(
        user, await caCerts, allowBadCerts, keyStore, fileStore, database);
    reporter.start(session!.supportServices);
    return session!;
  }

  void endUserSession() {
    reporter.stop();
    session?.dispose();
    session = null;
  }

  void dispose() {
    database.close();
  }
}
