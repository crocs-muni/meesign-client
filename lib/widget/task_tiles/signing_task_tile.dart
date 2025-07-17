import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../pages/task_detail_page.dart';
import '../../ui_constants.dart';
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
                  ),
                ),
              ),
              child: const Text('View'),
            )
          ]
        ],
      ),
      actions: const [],
      approveActions: [
        LargeSquareButton(
          text: "Sign",
          icon: Icons.check,
          onPressed: () {
            model.joinSign(task, agree: true);
          },
          color: Color(0xFF298E29),
        ),
        LargeSquareButton(
            text: "Decline",
            icon: Icons.close,
            onPressed: () {
              model.joinSign(task, agree: false);
            },
            color: Color(0xFFAA3026)),
      ],
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }
}
