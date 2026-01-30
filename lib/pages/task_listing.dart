import 'package:flutter/material.dart';
import 'package:meesign_client/enums/fab_type.dart';
import 'package:meesign_client/enums/task_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/challenge_creator.dart';
import 'package:meesign_client/util/actions/document_signer.dart';
import 'package:meesign_client/util/actions/encrypt_data.dart';
import 'package:meesign_client/util/actions/task_type_selector.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/controlled_lottie_animation.dart';
import 'package:meesign_client/widget/fab_configurator.dart';
import 'package:meesign_client/widget/task_list_view.dart';
import 'package:meesign_client/widget/task_tiles/challenge_task_tile.dart';
import 'package:meesign_client/widget/task_tiles/decrypt_task_tile.dart';
import 'package:meesign_client/widget/task_tiles/signing_task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

class TaskListing extends StatefulWidget {
  const TaskListing({
    super.key,
    this.showOnlyPending = false,
    this.hidePending = false,
    this.showHeading = true,
    this.customSearchBarHint,
  });
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
      context,
    ); // Important: Must call super.build for AutomaticKeepAliveClientMixin
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
      stream: model.combinedTaskStream,
      builder: (context, snapshot) {
        return DefaultPageTemplate(
          floatingActionButton: _buildFab(context, model),
          body: TaskListView(
            key: const ValueKey('general_task_list'),
            customSearchBarHint: widget.customSearchBarHint,
            showAllTypes: true,
            showHeading: widget.showHeading,
            tasks: model.allTasks,
            emptyView: _buildEmptyTasks(
              context,
              model,
              AppLocalizations.of(context).noTasksAvailable,
              AppLocalizations.of(context).noTasksAvailableDescription,
              0,
            ),
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
      },
    );
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (widget.showOnlyPending) {
      if (model.allTasks
          .where(
            (task) =>
                task.state != TaskState.finished &&
                task.state != TaskState.failed &&
                (model.showArchived || !task.archived),
          )
          .isEmpty) {
        return const SizedBox();
      }
    } else {
      if (model.allTasks
          .where((task) => model.showArchived || !task.archived)
          .isEmpty) {
        return const SizedBox();
      }
    }

    if (model.allTasks.isEmpty) {
      return const SizedBox();
    }

    return FabConfigurator(
      fabType: FabType.newTaskFab,
      buildContext: context,
      viewModel: model,
    );
  }

  Widget _buildEmptyTasks(
    BuildContext context,
    AppViewModel viewModel,
    String heading,
    String subheading,
    int animationStartIndex,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
                child: ControlledLottieAnimation(
                  startAtTabIndex: 0,
                  assetName: 'assets/lottie/sign.json',
                  stopAtPercentage: 0.2,
                  height: 350,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                heading,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                subheading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TabsViewModel>(context, listen: false)
                      .setIndex(3, postNavigationAction: 'createGroup');
                },
                child: const Text('Create group'),
              ),
              if (context
                  .read<AppViewModel>()
                  .joinedGroupForTaskTypeExists(KeyType.signPdf)) ...[
                const SizedBox(height: MEDIUM_GAP),
                FilledButton.icon(
                  onPressed: () async {
                    final result = await showTaskTypeDialog(context);

                    if (context.mounted) {
                      if (result == TaskType.sign) {
                        signDocument(context: context, buildContext: context);
                      } else if (result == TaskType.decrypt) {
                        encryptData(context: context, buildContext: context);
                      } else if (result == TaskType.challenge) {
                        createChallenge(
                          context: context,
                          buildContext: context,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).createNewTask),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
