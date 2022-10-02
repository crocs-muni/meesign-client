import 'package:meesign_core/meesign_data.dart';

import 'data/tmp_dir_provider.dart';

class AppContainer {
  late final MPCClient client;

  late final FileStore fileStore = FileStore(TmpDirProvider());

  late final PrefRepository prefRepository = PrefRepository();
  late final DeviceRepository deviceRepository;
  late final GroupRepository groupRepository;
  late final FileRepository fileRepository;

  void init(String host) {
    client = ClientFactory.create(host);
    deviceRepository = DeviceRepository(client);
    final taskSource = TaskSource(client);
    groupRepository = GroupRepository(client, taskSource, deviceRepository);
    fileRepository =
        FileRepository(client, taskSource, fileStore, groupRepository);
  }
}
