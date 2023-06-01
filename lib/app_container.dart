import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_data.dart';

class AppContainer {
  final Directory appDirectory;

  final Database database;

  late final NetworkDispatcher dispatcher;

  late final KeyStore keyStore = KeyStore(appDirectory);
  late final FileStore fileStore = FileStore(appDirectory);

  late final UserRepository userRepository = UserRepository(database.userDao);
  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;
  late final ChallengeRepository challengeRepository;
  late final DecryptRepository decryptRepository;

  final bool allowBadCerts = const bool.fromEnvironment('ALLOW_BAD_CERTS');

  AppContainer({required this.appDirectory})
      : database = Database(appDirectory);

  Future<List<int>?> get caCerts async {
    final data = await rootBundle.load('assets/ca-cert.pem');
    return data.lengthInBytes == 0 ? null : data.buffer.asUint8List();
  }

  Future<void> init(String host) async {
    dispatcher = NetworkDispatcher(host, keyStore,
        serverCerts: await caCerts, allowBadCerts: allowBadCerts);

    deviceRepository =
        DeviceRepository(dispatcher, keyStore, database.deviceDao);
    final taskSource = TaskSource(dispatcher);
    final taskDao = database.taskDao;
    groupRepository =
        GroupRepository(dispatcher, taskSource, taskDao, deviceRepository);
    fileRepository = FileRepository(dispatcher, taskSource, taskDao, fileStore);
    challengeRepository = ChallengeRepository(taskSource, taskDao);
    decryptRepository = DecryptRepository(dispatcher, taskSource, taskDao);
  }

  void dispose() {
    database.close();
  }
}
