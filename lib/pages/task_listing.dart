import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tiles/challenge_task_tile.dart';
import '../widget/task_tiles/decrypt_task_tile.dart';
import '../widget/task_tiles/signing_task_tile.dart';
import 'new_task_page.dart';

class TaskListing extends StatelessWidget {
  const TaskListing(
      {super.key, this.showOnlyPending = false, this.hidePending = false});
  final bool showOnlyPending;
  final bool hidePending;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView(
              showAllTypes: !hidePending,
              tasks: model.allTasks,
              emptyView: showOnlyPending
                  ? _buildEmptyTasks(
                      context,
                      model,
                      'All tasks are completed',
                      'Once there is something to sign, we will let you know.',
                      1)
                  : _buildEmptyTasks(
                      context,
                      model,
                      'No tasks available',
                      'Start by creating a challenge, decrypt or signing group.',
                      0),
              showArchived: model.showArchived,
              showOnlyPending: showOnlyPending,
              taskBuilder: (context, task) {
                // Signing tasks
                if (task is Task<File>) {
                  return SigningTaskTile(task: task);
                }

                // Decrypt tasks
                if (task is Task<Decrypt>) {
                  return DecryptTaskTile(task: task);
                }

                // Challenge tasks
                if (task is Task<Challenge>) {
                  return ChallengeTaskTile(task: task);
                }

                // Unknown task type
                return Container();
              },
            ),
          );
        });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead

    if (showOnlyPending) {
      if (model.allTasks
          .where((task) =>
              task.state != TaskState.finished &&
              task.state != TaskState.failed &&
              (model.showArchived ? true : task.archived == false))
          .isEmpty) {
        return SizedBox();
      }
    } else {
      if (model.allTasks
          .where((task) =>
              (task.state == TaskState.finished ||
                  task.state == TaskState.failed) &&
              (model.showArchived ? true : task.archived == false))
          .isEmpty) {
        return SizedBox();
      }
    }

    if (!model.anyGroupJoined()) {
      return SizedBox();
    }

    return FabConfigurator(
        fabType: FabType.newTaskFab, buildContext: context, viewModel: model);
  }

  Widget _buildEmptyTasks(BuildContext context, AppViewModel viewModel,
      String heading, String subheading, int animationStartIndex) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
                child: ControlledLottieAnimation(
                  startAtTabIndex: animationStartIndex,
                  assetName: 'assets/lottie/sign.json',
                  stopAtPercentage: 0.2,
                  width: 400,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                heading,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                subheading,
                textAlign: TextAlign.center,
              ),
              if (!context.read<AppViewModel>().anyGroupJoined()) ...[
                const SizedBox(height: LARGE_GAP),
                ElevatedButton(
                  onPressed: () {
                    final tabViewModel =
                        Provider.of<TabsViewModel>(context, listen: false);

                    tabViewModel.setIndex(2,
                        postNavigationAction: 'createGroup');
                  },
                  child: const Text('Create group'),
                ),
              ],
              if (context.read<AppViewModel>().anyGroupJoined()) ...[
                const SizedBox(height: MEDIUM_GAP),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => NewTaskPage(
                          showTaskTypeSelector: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Create new task'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
