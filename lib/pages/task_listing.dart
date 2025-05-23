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
import '../widget/task_list_view.dart';
import '../widget/task_tiles/challenge_task_tile.dart';
import '../widget/task_tiles/decrypt_task_tile.dart';
import '../widget/task_tiles/signing_task_tile.dart';
import 'new_task_page.dart';
import 'tabbed_task_page.dart';

class TaskListing extends StatefulWidget {
  const TaskListing(
      {super.key,
      this.showOnlyPending = false,
      this.hidePending = false,
      this.showHeading = true,
      this.customSearchBarHint});
  final bool showOnlyPending;
  final bool hidePending;
  final bool showHeading;
  final String? customSearchBarHint;

  @override
  State<TaskListing> createState() => _TaskListingState();
}

class _TaskListingState extends State<TaskListing>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Important: Must call super.build for AutomaticKeepAliveClientMixin
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView(
              key: ValueKey('general_task_list'),
              customSearchBarHint: widget.customSearchBarHint,
              showAllTypes: true,
              showHeading: widget.showHeading,
              tasks: model.allTasks,
              emptyView: _buildEmptyTasks(context, model, 'No tasks available',
                  'Join a group and create a new task to get started.', 0),
              showArchived: model.showArchived,
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

    if (widget.showOnlyPending) {
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
                  assetName: Theme.of(context).brightness == Brightness.light
                      ? 'assets/lottie/sign_light_mode.json'
                      : 'assets/lottie/sign_dark_mode.json',
                  stopAtPercentage: 0.2,
                  height: 350,
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
                    TabbedTasksPage.switchToTab(context, 1);
                    createGroup(context, context);
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
