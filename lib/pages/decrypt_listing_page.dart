import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/encrypt_data.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tiles/decrypt_task_tile.dart';

class DecryptListingPage extends StatelessWidget {
  const DecryptListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
            floatingActionButton: _buildFab(context, model),
            body: TaskListView<Decrypt>(
              tasks: model.decryptTasks,
              emptyView: _buildEmptyDecryptTasks(context),
              showArchived: model.showArchived,
              taskBuilder: (context, task) {
                return DecryptTaskTile(task: task);
              },
            ),
          );
        });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.decryptTasks.where((task) => !task.archived).isEmpty ||
        !model.joinedGroupForTaskTypeExists(KeyType.decrypt)) {
      return SizedBox();
    }

    return FabConfigurator(fabType: FabType.decryptFab, buildContext: context);
  }

  Widget _buildEmptyDecryptTasks(BuildContext context) {
    bool groupForTaskExists = context
        .read<AppViewModel>()
        .joinedGroupForTaskTypeExists(KeyType.decrypt);

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
                  startAtTabIndex: 2,
                  assetName: Theme.of(context).brightness == Brightness.light
                      ? 'assets/lottie/decrypt_light_mode.json'
                      : 'assets/lottie/decrypt_dark_mode.json',
                  width: 400,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                'Try encrypting some data.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                groupForTaskExists
                    ? 'Start by creating a new encryption task.'
                    : 'Start by creating a group for encryption.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              if (!groupForTaskExists) ...[
                ElevatedButton(
                  onPressed: () {
                    final tabViewModel =
                        Provider.of<TabsViewModel>(context, listen: false);

                    tabViewModel.setIndex(3,
                        postNavigationAction: 'createGroup');
                  },
                  child: const Text('Create an encryption group'),
                )
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    encryptData(context, context);
                  },
                  child: const Text('Encrypt message'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
