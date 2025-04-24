import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../card/card.dart';
import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/group_creator.dart';
import '../view_model/app_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import 'group_page.dart';
import '../util/card_reader_launcher.dart';
import '../widget/entity_chip.dart';
import '../util/chars.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

class GroupsListingPage extends StatelessWidget {
  const GroupsListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder<TaskStream>(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
              floatingActionButton: _buildFab(context, model),
              body: TaskListView<Group>(
                key: ValueKey('group_task_list'),
                tasks: model.groupTasks,
                emptyView: _buildEmptyGroups(context),
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
                          onPressed: () => model.joinGroup(task,
                              agree: true, withCard: true),
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

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.groupTasks.where((task) => !task.archived).isEmpty) {
      return SizedBox();
    }

    return FabConfigurator(fabType: FabType.groupFab, buildContext: context);
  }

  Widget _buildEmptyGroups(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
              child: ControlledLottieAnimation(
                startAtTabIndex: 1,
                assetName: Theme.of(context).brightness == Brightness.light
                    ? 'assets/lottie/groups_light_mode.json'
                    : 'assets/lottie/groups_dark_mode.json',
                stopAtPercentage: 0.5,
                width: 400,
                fit: BoxFit.fitWidth,
              ),
            ),
            const Text(
              'No groups yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SMALL_GAP),
            const Text(
              'Create a group to get started.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LARGE_GAP),
            ElevatedButton(
              onPressed: () {
                createGroup(context, context);
              },
              child: const Text('Create group'),
            )
          ],
        ),
      ),
    );
  }
}
