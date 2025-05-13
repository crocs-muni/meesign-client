import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/document_signer.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tiles/signing_task_tile.dart';

class SigningListingPage extends StatelessWidget {
  const SigningListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView<File>(
              tasks: model.signTasks,
              emptyView: _buildEmptySignTasks(context),
              showArchived: model.showArchived,
              taskBuilder: (context, task) {
                return SigningTaskTile(task: task);
              },
            ),
          );
        });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (!model.joinedGroupForTaskTypeExists(KeyType.signPdf)) {
      return SizedBox();
    }
    return FabConfigurator(fabType: FabType.signFab, buildContext: context);
  }

  Widget _buildEmptySignTasks(BuildContext context) {
    bool groupForTaskExists = context
        .read<AppViewModel>()
        .joinedGroupForTaskTypeExists(KeyType.signPdf);

    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
                child: ControlledLottieAnimation(
                  startAtTabIndex: 0,
                  assetName: Theme.of(context).brightness == Brightness.light
                      ? 'assets/lottie/sign_light_mode.json'
                      : 'assets/lottie/sign_dark_mode.json',
                  stopAtPercentage: 0.2,
                  width: 400,
                  height: 300,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                'Try signing a PDF file.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                groupForTaskExists
                    ? 'Start by creating a new signing task.'
                    : 'Start by creating a group for signing',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              if (!groupForTaskExists) ...[
                ElevatedButton(
                  onPressed: () {
                    final tabViewModel =
                        Provider.of<TabsViewModel>(context, listen: false);

                    tabViewModel.setIndex(3,
                        postNavigationAction: 'createSignGroup');
                  },
                  child: const Text('Create a signing group'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    signDocument(context, context);
                  },
                  child: const Text('Sign a document'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
