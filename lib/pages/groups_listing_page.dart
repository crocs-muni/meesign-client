import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/group_creator.dart';
import '../view_model/app_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_tiles/group_task_tile.dart';
import '../widget/task_list_view.dart';

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
                  return GroupTaskTile(task: task, group: group);
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
                startAtTabIndex: 3,
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
