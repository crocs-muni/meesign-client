import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../theme.dart';

class TaskStateIndicator extends StatelessWidget {
  final Task task;

  const TaskStateIndicator(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (task.state) {
      TaskState.created => const Icon(Symbols.arrow_drop_down),
      TaskState.running => SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            value: task.round / task.nRounds,
            strokeWidth: 2.0,
          ),
        ),
      TaskState.needsCard => const Icon(Symbols.payment),
      TaskState.finished => Icon(
          Symbols.check,
          color: Theme.of(context).extension<CustomColors>()!.success,
        ),
      TaskState.failed => Icon(
          switch (task.error) {
            TaskError.rejected => Symbols.block,
            _ => Symbols.error_outline,
          },
          color: Theme.of(context).colorScheme.error,
        ),
    };
  }
}
