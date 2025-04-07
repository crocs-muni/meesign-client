import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../card/card.dart';
import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import 'group_page.dart';
import '../util/card_reader_launcher.dart';
import '../widget/empty_list.dart';
import '../widget/entity_chip.dart';
import '../util/chars.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';
import 'new_group_page.dart';

class GroupsSubPage extends StatelessWidget {
  const GroupsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return DefaultPageTemplate(
          floatingActionButton: _buildGroupFab(context),
          body: buildTaskListView<Group>(
            model.groupTasks,
            emptyView: const EmptyList(
              hint: 'Try creating a new group.',
            ),
            showArchived: model.showArchived,
            taskBuilder: (context, task) {
              final group = task.info;
              final members = group.members;
              final thisMember = members.firstWhere(
                (m) => m.device.id == model.device?.id,
              );

              return TaskTile(
                task: task,
                name: group.name,
                leading: CircleAvatar(
                  child: Text(group.name.initials),
                ),
                approveActions: [
                  FilledButton.tonal(
                    child: const Text('Join'),
                    onPressed: () => model.joinGroup(task, agree: true),
                  ),
                  if (CardManager.platformSupported &&
                      group.protocol.cardSupport &&
                      thisMember.shares == 1)
                    FilledButton.tonal(
                      onPressed: () =>
                          model.joinGroup(task, agree: true, withCard: true),
                      child: const Text('Join with card'),
                    ),
                  OutlinedButton(
                    child: const Text('Decline'),
                    onPressed: () => model.joinGroup(task, agree: false),
                  ),
                ],
                actions: [
                  FilledButton.tonal(
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
                ],
                cardActions: [
                  FilledButton.tonal(
                    onPressed: () => launchCardReader(context,
                        (card) => model.advanceGroupWithCard(task, card)),
                    child: const Text('Read card'),
                  ),
                ],
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (var m in members) DeviceChip(device: m.device)
                      ],
                    ),
                  ),
                ],
                onArchiveChange: (archive) =>
                    model.archiveTask(task, archive: archive),
              );
            },
          ));
    });
  }

  Widget _buildGroupFab(BuildContext context) {
    return FloatingActionButton.extended(
      key: const ValueKey('NewGroupFab'),
      icon: const Icon(Symbols.add),
      label: const Text('New group'),
      onPressed: () {
        Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(builder: (context) => NewGroupPage()),
        );
      },
    );
  }
}
