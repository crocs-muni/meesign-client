import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_data.dart';

import 'data/tmp_dir_provider.dart';

class AppContainer {
  late final MPCClient client;

  late final FileStore fileStore = FileStore(TmpDirProvider());

  late final PrefRepository prefRepository = PrefRepository();
  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;

  Future<List<int>?> get certs async {
    final data = await rootBundle.load('assets/ca-cert.pem');
    return data.lengthInBytes == 0 ? null : data.buffer.asUint8List();
  }

  Future<void> init(String host) async {
    client = ClientFactory.create(host, certs: await certs);
    deviceRepository = DeviceRepository(client);
    final taskSource = TaskSource(client);
    groupRepository = GroupRepository(client, taskSource, deviceRepository);
    fileRepository =
        FileRepository(client, taskSource, fileStore, groupRepository);
  }
}
