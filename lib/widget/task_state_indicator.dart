import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/theme.dart';
import 'package:meesign_core/meesign_core.dart';

class TaskStateIndicator extends StatefulWidget {
  const TaskStateIndicator(this.task, {super.key});
  final Task task;

  @override
  State<TaskStateIndicator> createState() => _TaskStateIndicatorState();
}

class _TaskStateIndicatorState extends State<TaskStateIndicator> {
  @override
  Widget build(BuildContext context) {
    return switch (widget.task.state) {
      TaskState.created => const SizedBox(),
      TaskState.running => _buildProgressIndicator(),
      TaskState.needsCard => const Icon(Symbols.payment, size: 30),
      TaskState.finished => Icon(
          size: 30,
          Symbols.check,
          color: Theme.of(context).extension<CustomColors>()!.success,
        ),
      TaskState.failed => Icon(
          switch (widget.task.error) {
            TaskError.rejected => Symbols.block,
            _ => Symbols.error_outline,
          },
          color: Theme.of(context).colorScheme.error,
          size: 30,
        ),
    };
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      height: 30,
      width: 30,
      // TODO(dev): add animation
      child: CircularProgressIndicator(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        value: widget.task.round / widget.task.nRounds,
        strokeWidth: 3,
      ),
    );
  }
}
