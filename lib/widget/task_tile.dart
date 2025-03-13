import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../theme.dart';
import '../ui/home_state.dart';
import '../util/list_intersperse.dart';
import '../util/status_message.dart';
import 'dismissible.dart';
import 'task_state_indicator.dart';

class TaskTile<T> extends StatelessWidget {
  final Task<T> task;
  final String name;
  final String? desc;
  final Widget? leading, trailing;
  final Widget? actionChip;
  final List<Widget> approveActions, cardActions, actions;
  final List<Widget> children;
  final void Function(bool)? onArchiveChange;

  const TaskTile({
    super.key,
    required this.task,
    required this.name,
    this.desc,
    this.leading,
    this.trailing,
    this.actionChip,
    this.approveActions = const [],
    this.cardActions = const [],
    this.actions = const [],
    this.children = const [],
    this.onArchiveChange,
  });

  @override
  Widget build(BuildContext context) {
    final desc = this.desc ?? StatusMessage.getStatusMessage(task);
    final trailing = this.trailing ?? TaskStateIndicator(task);
    final allActions = actions +
        (task.approvable ? approveActions : []) +
        (task.state == TaskState.needsCard ? cardActions : []);

    final actionRow = allActions.isNotEmpty || actionChip != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (actionChip != null) actionChip!,
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: allActions,
                ),
              ),
            ].intersperse(
              const SizedBox(width: 8),
            ),
          )
        : null;

    return Deletable(
      dismissibleKey: ObjectKey(task),
      icon: task.archived ? Symbols.unarchive : Symbols.archive,
      color: task.archived
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).extension<CustomColors>()!.successContainer!,
      onDeleted: (_) {
        if (onArchiveChange != null) onArchiveChange!(!task.archived);
      },
      child: ExpansionTile(
        title: Text(name),
        subtitle: desc != null ? Text(desc) : null,
        initiallyExpanded: !task.archived &&
            task.state != TaskState.finished &&
            task.state != TaskState.failed,
        leading: leading,
        trailing: trailing,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          ...children,
          if (actionRow != null) actionRow,
        ].intersperse(
          const SizedBox(height: 8),
        ),
      ),
    );
  }
}
