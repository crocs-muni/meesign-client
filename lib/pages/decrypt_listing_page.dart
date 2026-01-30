import 'package:flutter/material.dart';
import 'package:meesign_client/enums/fab_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/encrypt_data.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/controlled_lottie_animation.dart';
import 'package:meesign_client/widget/fab_configurator.dart';
import 'package:meesign_client/widget/task_list_view.dart';
import 'package:meesign_client/widget/task_tiles/decrypt_task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

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
      },
    );
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (!model.joinedGroupForTaskTypeExists(KeyType.decrypt)) {
      return const SizedBox();
    }

    return FabConfigurator(fabType: FabType.decryptFab, buildContext: context);
  }

  Widget _buildEmptyDecryptTasks(BuildContext context) {
    final groupForTaskExists = context
        .read<AppViewModel>()
        .joinedGroupForTaskTypeExists(KeyType.decrypt);

    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: MEDIUM_PADDING),
                child: ControlledLottieAnimation(
                  startAtTabIndex: 2,
                  assetName: Theme.of(context).brightness == Brightness.light
                      ? 'assets/lottie/decrypt_light_mode.json'
                      : 'assets/lottie/decrypt_dark_mode.json',
                  width: 400,
                  height: 310,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                AppLocalizations.of(context).tryEncryptingData,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SMALL_GAP),
              Text(
                groupForTaskExists
                    ? AppLocalizations.of(context).startWithNewDecryption
                    : AppLocalizations.of(context).startWithDecryptionGroup,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LARGE_GAP),
              if (!groupForTaskExists) ...[
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TabsViewModel>(context, listen: false).setIndex(
                      3,
                      postNavigationAction: 'createDecryptGroup',
                    );
                  },
                  child:
                      Text(AppLocalizations.of(context).createDecryptionGroup),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    encryptData(context: context, buildContext: context);
                  },
                  child: Text(AppLocalizations.of(context).createDecryption),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
