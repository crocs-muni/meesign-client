import 'package:flutter/material.dart';
import 'package:meesign_client/card/card.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/group_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/group_creator.dart';
import 'package:meesign_client/util/card_reader_launcher.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/widget/entity_chip.dart';
import 'package:meesign_client/widget/large_square_button.dart';
import 'package:meesign_client/widget/task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

class GroupTaskTile extends StatelessWidget {
  const GroupTaskTile({required this.task, required this.group, super.key});

  final Task<Group> task;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);
    final members = group.members;
    final thisMember = members.firstWhere(
      (m) => m.device.id == model.device?.id,
    );

    return TaskTile(
      key: ValueKey('group-task-${task.id}'),
      task: task,
      name: group.name,
      isGroupTask: true,
      leading: CircleAvatar(
        child: Text(group.name.initials),
      ),
      showDate: false,
      approveActions: [
        LargeSquareButton(
          text: AppLocalizations.of(context).join,
          icon: Icons.check,
          onPressed: () {
            model.joinGroup(task, agree: true);
          },
          color: const Color(0xFF298E29),
        ),
        LargeSquareButton(
          text: AppLocalizations.of(context).decline,
          icon: Icons.close,
          onPressed: () {
            model.joinGroup(task, agree: false);
          },
          color: const Color(0xFFAA3026),
        ),
        if (CardManager.platformSupported &&
            group.protocol.cardSupport &&
            thisMember.shares == 1) ...[
          _buildJoinWithCardButton(context: context, model: model),
        ],
      ],
      cardActions: [
        FilledButton.tonal(
          onPressed: () => launchCardReader(
            context,
            (card) => model.advanceGroupWithCard(task, card),
          ),
          child: Text(AppLocalizations.of(context).readCard),
        ),
      ],
      actionChip: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [for (final m in members) DeviceChip(device: m.device)],
            ),
          ),
          const SizedBox(
            width: SMALL_GAP,
          ),
          if (task.state == TaskState.finished ||
              task.state == TaskState.failed) ...[
            Flexible(
              child: Wrap(
                runSpacing: 4,
                children: [
                  if (task.state == TaskState.finished) ...[
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => GroupPage(
                              group: group,
                            ),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context).view),
                    ),
                  ],
                  const SizedBox(
                    width: SMALL_GAP,
                  ),
                  if (task.state == TaskState.finished ||
                      task.state == TaskState.failed) ...[
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () =>
                          createGroup(context, context, groupTemplate: group),
                      child: Text(AppLocalizations.of(context).copy),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }

  Widget _buildJoinWithCardButton({
    required BuildContext context,
    required AppViewModel model,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        model.joinGroup(task, agree: true, withCard: true);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF555555),
        padding: const EdgeInsets.all(MEDIUM_PADDING),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(SMALL_BORDER_RADIUS),
        ),
      ),
      icon: const Icon(Icons.credit_card, color: Colors.white),
      label: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).joinWithCard,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
