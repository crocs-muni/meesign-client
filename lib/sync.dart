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
    try {
      await _groupRepository.sync(_device.id);
      await _fileRepository.sync(_device.id);
      lastUpdate.value = 0;
    } catch (e) {
      --lastUpdate.value;
      rethrow;
    } finally {
      _scheduleSync();
    }
  }
}
