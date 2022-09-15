import 'package:meesign_network/meesign_network.dart';

import 'data/file_repository.dart';
import 'data/file_store.dart';
import 'data/device_repository.dart';
import 'data/group_repository.dart';
import 'data/pref_repository.dart';
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
    groupRepository = GroupRepository(client, deviceRepository);
    fileRepository = FileRepository(client, fileStore, groupRepository);
  }
}
