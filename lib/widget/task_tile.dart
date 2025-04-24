import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../theme.dart';
import '../ui_constants.dart';
import '../util/extensions/list_intersperse.dart';
import '../util/status_message.dart';
import '../util/extensions/task_approvable.dart';
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
  final bool showTaskTypeInfo;

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
    this.showTaskTypeInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final desc = this.desc ?? StatusMessage.getStatusMessage(task);
    final trailing = TaskStateIndicator(task);
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
      child: Container(
        padding: EdgeInsets.only(bottom: SMALL_PADDING),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Row(
              children: [
                Flexible(
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                if (showTaskTypeInfo) ...[
                  SizedBox(width: LARGE_GAP * 1.5),
                  _buildTaskTypeInfo(task, context),
                ],
              ],
            ),
            subtitle: desc != null
                ? Padding(
                    padding: EdgeInsets.only(top: SMALL_PADDING),
                    child: Text(desc),
                  )
                : null,
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
        ),
      ),
    );
  }

  Widget _buildGroupMetaDataRow(
      IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: Theme.of(context).textTheme.bodyLarge?.fontSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: SMALL_GAP),
        Text(text,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
      ],
    );
  }

  Widget _buildTaskTypeInfo(Task task, BuildContext context) {
    String text = "";
    Group? taskGroup;

    if (task is Task<Challenge>) {
      text = "Challenge";
      taskGroup = task.info.group;
    }

    if (task is Task<File>) {
      text = "Sign";
      taskGroup = task.info.group;
    }

    if (task is Task<Decrypt>) {
      text = "Decrypt";
      taskGroup = task.info.group;
    }

    return Row(
      children: [
        _buildGroupMetaDataRow(Symbols.flag, text, context),
        LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              if (MediaQuery.sizeOf(context).width > minLaptopLayoutWidth) ...[
                SizedBox(width: LARGE_GAP),
                _buildGroupMetaDataRow(Symbols.code,
                    taskGroup?.protocol.name.toUpperCase() ?? "", context),
                SizedBox(width: LARGE_GAP),
                _buildGroupMetaDataRow(Symbols.donut_large,
                    '${taskGroup?.threshold} / ${taskGroup?.shares}', context),
              ]
            ],
          );
        }),
      ],
    );
  }
}
