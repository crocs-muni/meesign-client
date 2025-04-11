import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/document_signer.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/entity_chip.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({super.key});

  static final _pageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _pageKey,
      child: Consumer<AppViewModel>(builder: (context, model, child) {
        return DefaultPageTemplate(
          floatingActionButton: _buildFab(context, model),
          body: TaskListView<File>(
            tasks: model.signTasks,
            emptyView: _buildEmptySignTasks(context),
            showArchived: model.showArchived,
            taskBuilder: (context, task) {
              return TaskTile(
                task: task,
                name: task.info.basename,
                actionChip: GroupChip(group: task.info.group),
                actions: <Widget>[
                  FilledButton.tonal(
                    child: const Text('View'),
                    onPressed: () => _openFile(task.info.path),
                  ),
                ],
                approveActions: [
                  FilledButton.tonal(
                    child: const Text('Sign'),
                    onPressed: () => model.joinSign(task, agree: true),
                  ),
                  OutlinedButton(
                    child: const Text('Decline'),
                    onPressed: () => model.joinSign(task, agree: false),
                  ),
                ],
                onArchiveChange: (archive) =>
                    model.archiveTask(task, archive: archive),
              );
            },
          ),
        );
      }),
    );
  }

  void _openFile(String path) {
    if (Platform.isLinux) {
      launchUrl(Uri.file(path));
    } else {
      // FIXME: try to avoid open_file package,
      // it seems to be of low quality
      OpenFilex.open(path);
    }
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.signTasks.isEmpty) {
      return SizedBox();
    }
    return FabConfigurator(fabType: FabType.signFab, buildContext: context);
  }

  Widget _buildEmptySignTasks(BuildContext context) {
    return Center(
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
            'Try signing a PDF file.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SMALL_GAP),
          const Text(
            'Start by creating a group for signing.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LARGE_GAP),
          ElevatedButton(
            onPressed: () {
              final tabViewModel =
                  Provider.of<TabsViewModel>(context, listen: false);

              tabViewModel.setIndex(3);
            },
            child: const Text('Create a signing group'),
          ),
          const SizedBox(height: MEDIUM_GAP),
          ElevatedButton(
            onPressed: () {
              signDocument(context, context);
            },
            child: const Text('Sign a document'),
          )
        ],
      ),
    );
  }
}
