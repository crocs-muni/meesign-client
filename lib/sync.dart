import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

class Sync {
  late final List<TaskRepository> _repositories;
  late final Device _device;

  final ValueNotifier<bool> subscribed = ValueNotifier(false);

  Timer? _retryTimer;

  Future<void> init(
    Device device,
    List<TaskRepository> toSync,
  ) async {
    _device = device;
    _repositories = toSync;

    _subscribe();
  }

  Future<void> _subscribe() async {
    _retryTimer = null;
    await Future.wait([
      for (var r in _repositories)
        r.subscribe(_device.id, onDone: _subscriptionDone)
    ]);
    subscribed.value = true;
  }

  void _subscriptionDone() {
    subscribed.value = false;
    _retryTimer ??= Timer(const Duration(seconds: 2), _subscribe);
  }
}
