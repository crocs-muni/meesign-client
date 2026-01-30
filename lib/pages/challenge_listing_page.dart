import 'package:flutter/material.dart';
import 'package:meesign_client/enums/fab_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/challenge_creator.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/controlled_lottie_animation.dart';
import 'package:meesign_client/widget/fab_configurator.dart';
import 'package:meesign_client/widget/task_list_view.dart';
import 'package:meesign_client/widget/task_tiles/challenge_task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

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
      },
    );
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (!model.joinedGroupForTaskTypeExists(KeyType.signChallenge)) {
      return const SizedBox();
    }

    return FabConfigurator(
      fabType: FabType.challengeFab,
      buildContext: context,
    );
  }

  Widget _buildEmptyChallengeTasks(BuildContext context) {
    final groupForTaskExists = context
        .read<AppViewModel>()
        .joinedGroupForTaskTypeExists(KeyType.signChallenge);

    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: MEDIUM_PADDING),
                child: ControlledLottieAnimation(
                  startAtTabIndex: 1,
                  assetName: Theme.of(context).brightness == Brightness.light
                      ? 'assets/lottie/challenge_light_mode.json'
                      : 'assets/lottie/challenge_dark_mode.json',
                  stopAtPercentage: 0.5,
                  width: 400,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                AppLocalizations.of(context).tryNewChallenge,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                groupForTaskExists
                    ? AppLocalizations.of(context).startWithNewChallenge
                    : AppLocalizations.of(context).startWithChallengeGroup,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              if (!groupForTaskExists) ...[
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TabsViewModel>(context, listen: false).setIndex(
                      3,
                      postNavigationAction: 'createChallengeGroup',
                    );
                  },
                  child:
                      Text(AppLocalizations.of(context).createChallengeGroup),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    createChallenge(context: context, buildContext: context);
                  },
                  child: Text(AppLocalizations.of(context).createChallenge),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
