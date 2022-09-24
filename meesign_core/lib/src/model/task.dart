import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../util/uuid.dart';

enum TaskState { created, running, finished, failed }

// TODO: use freezed package?
@immutable
class Task<T> {
  final Uuid id;
  final TaskState state;
  final bool approved;
  final int round;
  final int nRounds;
  final T info;
  // FIXME: create separate class hiding context
  final Uint8List context;

  const Task({
    required this.id,
    required this.state,
    required this.approved,
    required this.round,
    required this.nRounds,
    required this.context,
    required this.info,
  });

  Task<T> copyWith({
    Uuid? id,
    TaskState? state,
    bool? approved,
    int? round,
    int? nRounds,
    T? info,
    Uint8List? context,
  }) {
    return Task(
      id: id ?? this.id,
      state: state ?? this.state,
      approved: approved ?? this.approved,
      round: round ?? this.round,
      nRounds: nRounds ?? this.nRounds,
      info: info ?? this.info,
      context: context ?? this.context,
    );
  }

  // TODO: implement comparison, hash
}
