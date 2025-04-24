import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../theme.dart';

class TaskStateIndicator extends StatefulWidget {
  final Task task;

  const TaskStateIndicator(this.task, {super.key});

  @override
  State<TaskStateIndicator> createState() => _TaskStateIndicatorState();
}

class _TaskStateIndicatorState extends State<TaskStateIndicator> {
  @override
  Widget build(BuildContext context) {
    return switch (widget.task.state) {
      TaskState.created => const Icon(Symbols.arrow_drop_down),
      TaskState.running => SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            value: widget.task.round / widget.task.nRounds,
            strokeWidth: 2.0,
          ),
        ),
      TaskState.needsCard => const Icon(Symbols.payment),
      TaskState.finished => Icon(
          Symbols.check,
          color: Theme.of(context).extension<CustomColors>()!.success,
        ),
      TaskState.failed => Icon(
          switch (widget.task.error) {
            TaskError.rejected => Symbols.block,
            _ => Symbols.error_outline,
          },
          color: Theme.of(context).colorScheme.error,
        ),
    };
  }
}
