import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_data.dart';

import 'data/tmp_dir_provider.dart';

class AppContainer {
  late final NetworkDispatcher dispatcher;

  late final KeyStore keyStore = KeyStore();
  late final FileStore fileStore = FileStore(TmpDirProvider());

  late final PrefRepository prefRepository = PrefRepository();
  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;
  late final ChallengeRepository challengeRepository;

  final bool allowBadCerts = const bool.fromEnvironment('ALLOW_BAD_CERTS');

  Future<List<int>?> get caCerts async {
    final data = await rootBundle.load('assets/ca-cert.pem');
    return data.lengthInBytes == 0 ? null : data.buffer.asUint8List();
  }

  Future<void> init(String host) async {
    dispatcher = NetworkDispatcher(host, keyStore,
        serverCerts: await caCerts, allowBadCerts: allowBadCerts);

    deviceRepository = DeviceRepository(dispatcher, keyStore);
    final taskSource = TaskSource(dispatcher);
    groupRepository = GroupRepository(dispatcher, taskSource, deviceRepository);
    fileRepository =
        FileRepository(dispatcher, taskSource, fileStore, groupRepository);
    challengeRepository = ChallengeRepository(taskSource, groupRepository);
  }
}
