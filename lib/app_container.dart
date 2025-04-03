import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:meesign_core/meesign_data.dart';

import 'reporter.dart';
import 'services/settings_controller.dart';
import 'sessions/anonymous_session.dart';
import 'sessions/user_session.dart';

class AppContainer {
  final Directory dataDirectory;

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

  AppContainer({required Directory appDirectory})
      : dataDirectory = Directory('${appDirectory.path}/data/') {
    _init();
  }

  void _init() {
    keyStore = KeyStore(dataDirectory);
    fileStore = FileStore(dataDirectory);
    database = Database(dataDirectory);
    userRepository = UserRepository(database.userDao);
    settingsController = SettingsController();
  }

  Future<void> recreate({bool deleteData = false}) async {
    settingsController.updateCurrentUserId('logged out');

    try {
      if (deleteData) {
        Uuid userDid = session?.user.did ?? Uuid(const []);
        deleteDevice(userDid);
      }

      endUserSession();
      await database.close();
    } catch (e) {
      Logger.root.severe(e.toString(), e);
    }
    _init();
  }

  Future<void> deleteDevice(Uuid userDid) async {
    String userDataPath = '${dataDirectory.path}${userDid.encode()}/';

    // 1. Delete user from local DB
    await userRepository.deleteUser(userDid.bytes);

    // 2. Delete device from local db
    await session?.deviceRepository.deleteLocalDevice(userDid.bytes);

    // 3. Delete user data from the user's directory
    Directory usedDataDirectory = Directory(userDataPath);
    await usedDataDirectory.delete(recursive: true);
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
