import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import '../widget/empty_list.dart';
import '../widget/entity_chip.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return DefaultPageTemplate(
        floatingActionButton:
            FabConfigurator(fabType: FabType.signFab, buildContext: context),
        body: buildTaskListView<File>(
          model.signTasks,
          emptyView: EmptyList(
            hint: model.hasGroup(KeyType.signPdf)
                ? 'Try signing a PDF file.'
                : 'Start by creating a group for signing.',
          ),
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
    });
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
}
