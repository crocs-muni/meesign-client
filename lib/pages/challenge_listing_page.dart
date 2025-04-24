import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/challenge_creator.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tiles/challenge_task_tile.dart';

enum DataView { hex, text }

class ChallengeListingPage extends StatelessWidget {
  const ChallengeListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView<Challenge>(
              tasks: model.challengeTasks,
              emptyView: _buildEmptyChallengeTasks(context),
              showArchived: context.read<AppViewModel>().showArchived,
              taskBuilder: (context, task) {
                return ChallengeTaskTile(task: task);
              },
            ),
          );
        });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.challengeTasks.where((task) => !task.archived).isEmpty ||
        !model.joinedGroupForTaskTypeExists(KeyType.signChallenge)) {
      return SizedBox();
    }

    return FabConfigurator(
        fabType: FabType.challengeFab, buildContext: context);
  }

  Widget _buildEmptyChallengeTasks(BuildContext context) {
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
                  startAtTabIndex: 1,
                  assetName: 'assets/lottie/challenge.json',
                  stopAtPercentage: 0.5,
                  width: 400,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                'Try creating a new challenge.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              const Text(
                'Start by creating a group for challenges.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              ElevatedButton(
                onPressed: () {
                  final tabViewModel =
                      Provider.of<TabsViewModel>(context, listen: false);

                  tabViewModel.setIndex(3);
                },
                child: const Text('Create a challenge group'),
              ),
              if (context
                  .read<AppViewModel>()
                  .joinedGroupForTaskTypeExists(KeyType.signChallenge)) ...[
                const SizedBox(height: MEDIUM_GAP),
                ElevatedButton(
                  onPressed: () {
                    createChallenge(context, context);
                  },
                  child: const Text('Create a challenge'),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
