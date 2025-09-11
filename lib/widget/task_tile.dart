import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../l10n/arb/app_localizations.dart';
import '../ui_constants.dart';
import '../util/date_formatter.dart';
import '../util/extensions/list_intersperse.dart';
import '../util/status_message.dart';
import '../util/extensions/task_approvable.dart';
import '../view_model/app_view_model.dart';
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
  final bool showDetailRow;
  final bool showDate;
  final bool isGroupTask;

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
    this.isGroupTask = false,
  });

  @override
  Widget build(BuildContext context) {
    final desc = this.desc ?? StatusMessage.getStatusMessage(task, context);
    final trailing = TaskStateIndicator(task);
    final allActions = actions +
        (task.approvable ? _buildConditionalApproveActions(context) : []) +
        (task.state == TaskState.needsCard ? cardActions : []);
    final appViewModel = Provider.of<AppViewModel>(context);

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

    return Container(
      padding: EdgeInsets.only(bottom: SMALL_PADDING),
      child: Deletable.builder(
        dismissibleKey: ObjectKey(task),
        icon: task.archived ? Symbols.unarchive : Symbols.archive,
        color: Colors.transparent,
        confirmDismiss: (_) async {
          if (onArchiveChange != null) {
            onArchiveChange!(!task.archived);
            return !appViewModel.showArchived;
          }
          return false;
        },
        childBuilder: (isDragging) => Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: ValueKey('expansion_tile_${task.id}'),
            title: Row(
              children: [
                Flexible(
                  child: Text(name,
                      maxLines: 1,
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

  List<Widget> _buildConditionalApproveActions(BuildContext context) {
    if (isGroupTask) {
      if (Provider.of<AppContainer>(context, listen: false)
              .settingsController
              .currentSettings
              .autoJoinGroups ==
          false) {
        return approveActions;
      } else {
        // If auto-join is enabled, we don't show the approve actions
        return [];
      }
    } else {
      return approveActions;
    }
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
      text = AppLocalizations.of(context).challenge;
      taskGroup = task.info.group;
    }

    if (task is Task<File>) {
      text = AppLocalizations.of(context).signPdf;
      taskGroup = task.info.group;
    }

    if (task is Task<Decrypt>) {
      text = AppLocalizations.of(context).decrypt;
      taskGroup = task.info.group;
    }

    if (task is Task<Group>) {
      text = switch (task.info.keyType) {
        KeyType.signPdf => AppLocalizations.of(context).signPdf,
        KeyType.signChallenge => AppLocalizations.of(context).challenge,
        KeyType.decrypt => AppLocalizations.of(context).decrypt,
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
                    minLaptopLayoutWidth) ...[
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
          _buildGroupMetaDataRow(
              Symbols.archive, AppLocalizations.of(context).archived, context),
        ]
      ],
    );
  }
}
