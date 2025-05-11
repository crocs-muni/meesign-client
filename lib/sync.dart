import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

class Sync {
  late final List<TaskRepository> _repositories;
  late final Uuid _did;

  final ValueNotifier<bool> subscribed = ValueNotifier(false);

  Timer? _retryTimer;
  bool _disposed = false;

  Future<void> init(
    Uuid did,
    List<TaskRepository> toSync,
  ) async {
    _did = did;
    _repositories = toSync;
    _disposed = false;

    _subscribe();
  }

  Future<void> _subscribe() async {
    if (_disposed) return;

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
    if (_disposed) return;

    subscribed.value = false;
    _retry();
  }

  void _retry() {
    if (_disposed) return;

    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), _subscribe);
  }

  Future<void> dispose() async {
    _disposed = true;

    _retryTimer?.cancel();
    _retryTimer = null;

    await Future.wait([
      for (var r in _repositories) r.unsubscribe(_did),
    ]);

    subscribed.value = false;
  }
}
