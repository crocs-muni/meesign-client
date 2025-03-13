import 'package:meesign_core/meesign_core.dart';

class StatusMessage {
  static String? getStatusMessage(Task task) {
    return switch (task.state) {
      TaskState.created => 'Waiting for confirmation '
          '${task.approved ? 'by others' : ''}',
      TaskState.running => 'Working on task',
      TaskState.needsCard => 'Needs card to continue',
      _ => null,
    };
  }
}
