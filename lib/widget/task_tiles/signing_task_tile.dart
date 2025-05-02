import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view_model/app_view_model.dart';
import '../entity_chip.dart';
import '../task_tile.dart';

class SigningTaskTile extends StatelessWidget {
  const SigningTaskTile({
    super.key,
    required this.task,
  });

  final Task<File> task;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return TaskTile(
      task: task,
      name: task.info.basename,
      showDetailRow: false,
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
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
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
}
