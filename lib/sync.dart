import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

class Sync {
  late final List<TaskRepository> _repositories;
  late final Uuid _did;

  final ValueNotifier<bool> subscribed = ValueNotifier(false);

  Timer? _retryTimer;

  Future<void> init(
    Uuid did,
    List<TaskRepository> toSync,
  ) async {
    _did = did;
    _repositories = toSync;

    _subscribe();
  }

  Future<void> _subscribe() async {
    _retryTimer = null;

    Future<void> setUp(TaskRepository r) async {
      await r.subscribe(_did, onDone: _subscriptionDone);
      await r.sync(_did);
    }

    try {
      await Future.wait(
        [for (var r in _repositories) setUp(r)],
      );
      subscribed.value = true;
    } on Exception {
      _retry();
    }
  }

  void _subscriptionDone() {
    subscribed.value = false;
    _retry();
  }

  void _retry() {
    _retryTimer ??= Timer(const Duration(seconds: 2), _subscribe);
  }
}
