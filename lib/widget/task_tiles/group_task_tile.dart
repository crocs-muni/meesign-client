import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../../l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../card/card.dart';
import '../../pages/group_page.dart';
import '../../ui_constants.dart';
import '../../util/actions/group_creator.dart';
import '../../util/card_reader_launcher.dart';
import '../../util/chars.dart';
import '../../view_model/app_view_model.dart';
import '../entity_chip.dart';
import '../large_square_button.dart';
import '../task_tile.dart';

class GroupTaskTile extends StatelessWidget {
  const GroupTaskTile({super.key, required this.task, required this.group});

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
          color: Color(0xFF298E29),
        ),
        LargeSquareButton(
            text: AppLocalizations.of(context).decline,
            icon: Icons.close,
            onPressed: () {
              model.joinGroup(task, agree: false);
            },
            color: Color(0xFFAA3026)),
        if (CardManager.platformSupported &&
            group.protocol.cardSupport &&
            thisMember.shares == 1) ...[
          _buildJoinWithCardButton(context: context, model: model),
        ]
      ],
      actions: const [],
      cardActions: [
        FilledButton.tonal(
          onPressed: () => launchCardReader(
              context, (card) => model.advanceGroupWithCard(task, card)),
          child: Text(AppLocalizations.of(context).readCard),
        ),
      ],
      actionChip: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [for (var m in members) DeviceChip(device: m.device)],
            ),
          ),
          SizedBox(
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
                          width: 1.0,
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
                  SizedBox(
                    width: SMALL_GAP,
                  ),
                  if (task.state == TaskState.finished ||
                      task.state == TaskState.failed) ...[
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      onPressed: () =>
                          createGroup(context, context, groupTemplate: group),
                      child: Text(AppLocalizations.of(context).copy),
                    ),
                  ],
                ],
              ),
            )
          ]
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
            backgroundColor: Color(0xFF555555),
            padding: EdgeInsets.all(MEDIUM_PADDING),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadiusGeometry.circular(SMALL_BORDER_RADIUS))),
        icon: Icon(Icons.credit_card, color: Colors.white),
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).joinWithCard,
              style: TextStyle(fontSize: 14, color: Colors.white),
            )
          ],
        ));
  }
}
