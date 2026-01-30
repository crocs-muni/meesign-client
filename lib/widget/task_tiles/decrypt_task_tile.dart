import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/task_detail_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/encrypt_data.dart';
import 'package:meesign_client/util/status_message.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/widget/entity_chip.dart';
import 'package:meesign_client/widget/large_square_button.dart';
import 'package:meesign_client/widget/task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

class DecryptTaskTile extends StatelessWidget {
  const DecryptTaskTile({
    required this.task,
    super.key,
  });

  final Task<Decrypt> task;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return TaskTile(
      key: ValueKey('decrypt-task-${task.id}'),
      task: task,
      name: task.info.name,
      showDetailRow: false,
      desc: StatusMessage.getStatusMessage(task, context),
      actionChip: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupChip(group: task.info.group),
          const SizedBox(
            width: SMALL_GAP,
          ),
          if (task.state == TaskState.finished) ...[
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                side: const BorderSide(
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => TaskDetailPage(
                    title: task.info.name,
                    group: task.info.group,
                    timedAutoClose: true,
                    autoCloseDurationInSeconds: 5,
                    isArchived: task.archived,
                    keyType: KeyType.decrypt,
                    task: task,
                    imageDecrypt: task.info.dataType.isImage ? task.info : null,
                    textValue: task.info.dataType.isText
                        ? utf8.decode(task.info.data, allowMalformed: true)
                        : null,
                    hexValue: task.info.dataType.isText
                        ? hex.encode(task.info.data)
                        : null,
                  ),
                ),
              ),
              child: Text(AppLocalizations.of(context).view),
            ),
          ],
          const SizedBox(
            width: SMALL_GAP,
          ),
          if (task.state == TaskState.finished ||
              task.state == TaskState.failed) ...[
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                side: const BorderSide(
                  color: Colors.grey,
                ),
              ),
              onPressed: () => encryptData(
                context: context,
                buildContext: context,
                templateDecryptTask: task,
              ),
              child: Text(AppLocalizations.of(context).copy),
            ),
          ],
        ],
      ),
      approveActions: [
        LargeSquareButton(
          text: AppLocalizations.of(context).decrypt,
          icon: Icons.check,
          onPressed: () {
            model.joinDecrypt(task, agree: true);
          },
          color: const Color(0xFF298E29),
        ),
        LargeSquareButton(
          text: AppLocalizations.of(context).decline,
          icon: Icons.close,
          onPressed: () {
            model.joinDecrypt(task, agree: false);
          },
          color: const Color(0xFFAA3026),
        ),
      ],
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }
}
