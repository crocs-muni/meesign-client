import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../ui_constants.dart';
import '../util/date_formatter.dart';
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
  final bool showDetailRow;
  final bool showTaskTypeInfo;
  final bool showDate;

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
    this.showDetailRow = true,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final desc = this.desc ?? StatusMessage.getStatusMessage(task);
    final trailing = TaskStateIndicator(task);
    final allActions =
        actions + (task.state == TaskState.needsCard ? cardActions : []);
    final actionRow = _buildActionRow(allActions);

    return _buildArchiveContainer(
      context,
      Padding(
        padding: const EdgeInsets.all(SMALL_PADDING),
        child: Column(
          children: [
            _buildHeader(context, desc,
                actionRow: actionRow, trailing: trailing),
            // ...children,
          ].intersperse(
            const SizedBox(width: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? desc,
      {Widget? actionRow, Widget? trailing}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: SMALL_GAP),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SMALL_GAP),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    if (showTaskTypeInfo) ...[
                      SizedBox(height: SMALL_GAP),
                      _buildTaskTypeInfo(task, context),
                    ],
                    if (desc != null) ...[
                      SizedBox(height: SMALL_GAP),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(
                            width: SMALL_GAP,
                          ),
                          Expanded(
                            child: Text(desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                          ),
                        ],
                      )
                    ],
                    if (actionRow != null) actionRow,
                    SizedBox(height: SMALL_GAP)
                  ]),
            ),
            if (task.approvable) ...[
              LayoutBuilder(builder: (context, constraints) {
                return Row(
                  children: [
                    if (MediaQuery.sizeOf(context).width >=
                        minTabletLayoutWidth) ...[
                      Row(
                        children: [
                          SizedBox(height: XLARGE_GAP),
                          ...approveActions
                        ],
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(right: LARGE_GAP),
                        child: _buildNotificationCircle(context),
                      )
                    ]
                  ],
                );
              })
            ] else ...[
              if (trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: LARGE_GAP),
                  child: trailing,
                )
              ],
            ],
          ],
        ),
        if (task.approvable) ...[
          LayoutBuilder(builder: (context, constraints) {
            return Container(
              padding: EdgeInsets.only(top: SMALL_GAP, left: SMALL_GAP),
              child: Row(
                children: [
                  if (MediaQuery.sizeOf(context).width <
                      minTabletLayoutWidth) ...[
                    Row(
                      children: [
                        SizedBox(height: XLARGE_GAP),
                        ...approveActions
                      ],
                    ),
                  ],
                ],
              ),
            );
          })
        ]
      ],
    );
  }

  Widget _buildNotificationCircle(BuildContext context) {
    return Row(
      children: [
        Text("Waiting",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
        SizedBox(width: SMALL_GAP),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }

  Widget _buildArchiveContainer(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.only(bottom: SMALL_PADDING),
      child: Deletable.builder(
        dismissibleKey: ObjectKey(task),
        icon: task.archived ? Symbols.unarchive : Symbols.archive,
        color: Colors.transparent,
        onDeleted: (_) {
          if (onArchiveChange != null) onArchiveChange!(!task.archived);
        },
        childBuilder: (isDragging) => Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }

  Widget? _buildActionRow(List<Widget> allActions) {
    final actionRow = allActions.isNotEmpty || actionChip != null
        ? Container(
            padding: EdgeInsets.only(top: SMALL_GAP),
            child: Wrap(
              spacing: SMALL_GAP,
              runSpacing: SMALL_GAP,
              children: [
                if (actionChip != null) actionChip!,
                ...allActions,
              ],
            ),
          )
        : null;

    return actionRow;
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

    if (task is Task<Group>) {
      text = switch (task.info.keyType) {
        KeyType.signPdf => 'Sign PDF',
        KeyType.signChallenge => 'Challenge',
        KeyType.decrypt => 'Decrypt',
      };
      taskGroup = task.info;
    }

    return Row(
      children: [
        _buildGroupMetaDataRow(Symbols.flag, text, context),
        if (showDetailRow) ...[
          LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                if (MediaQuery.sizeOf(context).width >
                    minTabletLayoutWidth + 100) ...[
                  SizedBox(width: LARGE_GAP),
                  _buildGroupMetaDataRow(Symbols.code,
                      taskGroup?.protocol.name.toUpperCase() ?? "", context),
                  SizedBox(width: LARGE_GAP),
                  _buildGroupMetaDataRow(
                      Symbols.donut_large,
                      '${taskGroup?.threshold} / ${taskGroup?.shares}',
                      context),
                ],
              ],
            );
          })
        ],
        if (showDate) ...[
          LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                if (MediaQuery.sizeOf(context).width >
                    minLaptopLayoutWidth) ...[
                  SizedBox(width: LARGE_GAP),
                  _buildGroupMetaDataRow(Icons.calendar_month,
                      formatDate(task.createdAt), context),
                ],
              ],
            );
          })
        ],
        if (task.archived) ...[
          SizedBox(width: LARGE_GAP),
          _buildGroupMetaDataRow(Symbols.archive, 'Archived', context),
        ]
      ],
    );
  }
}
