import 'package:meesign_core/src/database/database.dart' as db;
import 'package:meesign_core/src/util/uuid.dart';
import 'package:meta/meta.dart';

enum TaskState { created, running, needsCard, finished, failed }

enum TaskError { rejected }

// TODO(dev): use freezed package?
@immutable
class Task<T> {
  const Task({
    required this.id,
    required this.nRounds,
    required this.info,
    required this.createdAt,
    this.state = TaskState.created,
    this.error,
    this.approved = false,
    this.archived = false,
    this.round = 0,
    this.attempt = 0,
  });
  final Uuid id;
  final TaskState state;
  final TaskError? error;
  final bool approved;
  final bool archived;
  final int round;
  final int nRounds;
  final int attempt;
  final T info;
  final int createdAt;

  // TODO(dev): implement comparison, hash
}

class TaskConversion {
  static Task<T> fromEntity<T>(db.Task entity, int nRounds, T info) => Task<T>(
        id: Uuid.take(entity.id),
        state: entity.state,
        error: entity.error,
        approved: entity.approved,
        archived: entity.archived,
        round: entity.round,
        nRounds: nRounds,
        attempt: entity.attempt,
        info: info,
        createdAt: entity.createdAt.millisecondsSinceEpoch,
      );
}
