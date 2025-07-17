import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../card/card.dart';
import '../../pages/group_page.dart';
import '../../ui_constants.dart';
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
      task: task,
      name: group.name,
      isGroupTask: true,
      leading: CircleAvatar(
        child: Text(group.name.initials),
      ),
      showDate: false,
      approveActions: [
        LargeSquareButton(
          text: "Join",
          icon: Icons.check,
          onPressed: () {
            model.joinGroup(task, agree: true);
          },
          color: Color(0xFF298E29),
        ),
        LargeSquareButton(
            text: "Decline",
            icon: Icons.close,
            onPressed: () {
              model.joinGroup(task, agree: false);
            },
            color: Color(0xFFAA3026)),
        if (CardManager.platformSupported &&
            group.protocol.cardSupport &&
            thisMember.shares == 1)
          FilledButton.tonal(
            onPressed: () => model.joinGroup(task, agree: true, withCard: true),
            child: const Text('Join with card'),
          ),
      ],
      actions: const [],
      cardActions: [
        FilledButton.tonal(
          onPressed: () => launchCardReader(
              context, (card) => model.advanceGroupWithCard(task, card)),
          child: const Text('Read card'),
        ),
      ],
      actionChip: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [for (var m in members) DeviceChip(device: m.device)],
            ),
          ),
          SizedBox(
            width: SMALL_GAP,
          ),
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
              child: const Text('View'),
            ),
          ]
        ],
      ),
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }
}
