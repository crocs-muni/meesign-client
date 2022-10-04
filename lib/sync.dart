import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

class Sync {
  late final GroupRepository _groupRepository;
  late final FileRepository _fileRepository;

  late final Device _device;

  final ValueNotifier<bool> subscribed = ValueNotifier(false);

  Timer? _retryTimer;

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

    _subscribe();
  }

  Future<void> _subscribe() async {
    _retryTimer = null;
    await Future.wait([
      for (TaskRepository r in [_groupRepository, _fileRepository])
        r.subscribe(_device.id, onDone: _subscriptionDone)
    ]);
    subscribed.value = true;
  }

  void _subscriptionDone() {
    subscribed.value = false;
    _retryTimer ??= Timer(const Duration(seconds: 2), _subscribe);
  }
}
