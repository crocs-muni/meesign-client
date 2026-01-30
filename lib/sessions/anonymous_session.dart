import 'package:meesign_core/meesign_core.dart';

class AnonymousSession {
  AnonymousSession(
    this.host,
    List<int>? serverCerts,
    KeyStore keyStore,
    FileStore fileStore,
    Database database, {
    required bool allowBadCerts,
  }) {
    dispatcher = NetworkDispatcher(
      host,
      keyStore,
      serverCerts: serverCerts,
      allowBadCerts: allowBadCerts,
    );

    supportServices = SupportServices(dispatcher);

    deviceRepository =
        DeviceRepository(dispatcher, keyStore, database.deviceDao);
    final taskSource = TaskSource(dispatcher);
    final taskDao = database.taskDao;
    groupRepository = GroupRepository(
      dispatcher,
      keyStore,
      taskSource,
      taskDao,
      deviceRepository,
    );
    fileRepository =
        FileRepository(dispatcher, keyStore, taskSource, taskDao, fileStore);
    challengeRepository =
        ChallengeRepository(dispatcher, keyStore, taskSource, taskDao);
    decryptRepository =
        DecryptRepository(dispatcher, keyStore, taskSource, taskDao);
  }
  final String host;
  late final NetworkDispatcher dispatcher;
  late final SupportServices supportServices;

  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;
  late final ChallengeRepository challengeRepository;
  late final DecryptRepository decryptRepository;

  Future<void> dispose() async {
    final devices = await deviceRepository.getAllLocalDevices();
    if (devices.isNotEmpty) {
      for (final device in devices) {
        await groupRepository.unsubscribe(device.id);
        await fileRepository.unsubscribe(device.id);
        await challengeRepository.unsubscribe(device.id);
        await decryptRepository.unsubscribe(device.id);
      }
    }
  }
}
