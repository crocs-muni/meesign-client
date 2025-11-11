import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../pages/task_detail_page.dart';
import '../../ui_constants.dart';
import '../../util/actions/document_signer.dart';
import '../../view_model/app_view_model.dart';
import '../entity_chip.dart';
import '../large_square_button.dart';
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
      key: ValueKey('signing-task-${task.id}'),
      task: task,
      name: task.info.basename,
      showDetailRow: false,
      actionChip: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupChip(group: task.info.group),
          SizedBox(
            width: SMALL_GAP,
          ),
          if (task.state == TaskState.finished) ...[
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => TaskDetailPage(
                    group: task.info.group,
                    title: task.info.basename,
                    filePath: task.info.path,
                    isArchived: task.archived,
                    keyType: KeyType.signPdf,
                    task: task,
                  ),
                ),
              ),
              child: Text(AppLocalizations.of(context).view),
            )
          ],
          SizedBox(
            width: SMALL_GAP,
          ),
          if (task.state == TaskState.finished ||
              task.state == TaskState.failed) ...[
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              onPressed: () => signDocument(
                  context: context,
                  buildContext: context,
                  templateSignTask: task),
              child: Text(AppLocalizations.of(context).copy),
            ),
          ],
          if (task.state == TaskState.failed) ...[
            SizedBox(
              width: SMALL_GAP,
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              onPressed: () => _openFile(),
              child: Text(AppLocalizations.of(context).view),
            ),
          ],
        ],
      ),
      actions: const [],
      approveActions: [
        LargeSquareButton(
          text: AppLocalizations.of(context).sign,
          icon: Icons.check,
          onPressed: () {
            model.joinSign(task, agree: true);
          },
          color: Color(0xFF298E29),
        ),
        LargeSquareButton(
            text: AppLocalizations.of(context).decline,
            icon: Icons.close,
            onPressed: () {
              model.joinSign(task, agree: false);
            },
            color: Color(0xFFAA3026)),
        Container(
          margin: EdgeInsets.only(bottom: SMALL_GAP),
          child: SizedBox(
              height: 50,
              child: _buildPreviewButton(context: context, model: model)),
        ),
      ],
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }

  Widget _buildPreviewButton({
    required BuildContext context,
    required AppViewModel model,
  }) {
    return ElevatedButton.icon(
        onPressed: () {
          _openFile();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF555555),
            padding: EdgeInsets.all(MEDIUM_PADDING),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadiusGeometry.circular(SMALL_BORDER_RADIUS))),
        icon: Icon(Icons.list_alt, color: Colors.white),
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).previewDocument,
              style: TextStyle(fontSize: 14, color: Colors.white),
            )
          ],
        ));
  }

  void _openFile() {
    if (Platform.isLinux) {
      launchUrl(Uri.file(task.info.path));
    } else {
      OpenFilex.open(task.info.path);
    }
  }
}
