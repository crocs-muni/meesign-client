import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../enums/task_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/challenge_creator.dart';
import '../util/actions/document_signer.dart';
import '../util/actions/encrypt_data.dart';
import '../util/actions/task_type_selector.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tiles/challenge_task_tile.dart';
import '../widget/task_tiles/decrypt_task_tile.dart';
import '../widget/task_tiles/signing_task_tile.dart';

class TaskListing extends StatelessWidget {
  const TaskListing({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView(
              tasks: model.allTasks,
              emptyView: _buildEmptySignTasks(context, model),
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
    if (model.allTasks.where((task) => !task.archived).isEmpty) {
      return SizedBox();
    }
    return FabConfigurator(
        fabType: FabType.newTaskFab, buildContext: context, viewModel: model);
  }

  Widget _buildEmptySignTasks(BuildContext context, AppViewModel viewModel) {
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
                  startAtTabIndex: 0,
                  assetName: 'assets/lottie/sign.json',
                  stopAtPercentage: 0.2,
                  width: 400,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              const Text(
                'Start by creating a challenge, decrypt or signing group.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              ElevatedButton(
                onPressed: () {
                  final tabViewModel =
                      Provider.of<TabsViewModel>(context, listen: false);

                  tabViewModel.setIndex(1);
                },
                child: const Text('Create group'),
              ),
              if (context
                  .read<AppViewModel>()
                  .joinedGroupForTaskTypeExists(KeyType.signPdf)) ...[
                const SizedBox(height: MEDIUM_GAP),
                ElevatedButton(
                  onPressed: () async {
                    TaskType? result = await showTaskTypeDialog(context);

                    if (context.mounted) {
                      if (result == TaskType.sign) {
                        signDocument(context, context);
                      } else if (result == TaskType.decrypt) {
                        encryptData(context, context);
                      } else if (result == TaskType.challenge) {
                        createChallenge(context, context);
                      }
                    }
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
