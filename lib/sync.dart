import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

class Sync {
  late final GroupRepository _groupRepository;
  late final FileRepository _fileRepository;

  late final Device _device;

  final ValueNotifier<int> lastUpdate = ValueNotifier(0);

  Future<void> init(
    PrefRepository prefRepository,
    GroupRepository groupRepository,
    FileRepository fileRepository,
  ) async {
    final current = await prefRepository.getDevice();
    if (current == null) return;
    _device = current;

    _groupRepository = groupRepository;
    _fileRepository = fileRepository;

    _sync();
  }

  Timer _scheduleSync() => Timer(const Duration(seconds: 1), _sync);

  Future<void> _sync() async {
    Object? err;
    for (TaskRepository repository in [_groupRepository, _fileRepository]) {
      try {
        await repository.sync(_device.id);
      } catch (e) {
        err = e;
      }
    }

    _scheduleSync();
    if (err == null) {
      lastUpdate.value = 0;
    } else {
      --lastUpdate.value;
      throw err;
    }
  }
}
