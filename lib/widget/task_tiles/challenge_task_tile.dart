import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/task_detail_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/challenge_creator.dart';
import 'package:meesign_client/util/card_reader_launcher.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/widget/entity_chip.dart';
import 'package:meesign_client/widget/large_square_button.dart';
import 'package:meesign_client/widget/task_tile.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

class ChallengeTaskTile extends StatelessWidget {
  const ChallengeTaskTile({
    required this.task,
    super.key,
  });

  final Task<Challenge> task;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return TaskTile(
      key: ValueKey('challenge-task-${task.id}'),
      task: task,
      name: task.info.name,
      showDetailRow: false,
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
                    textValue: _decodeHexToString(task.info.data),
                    hexValue: hex.encode(task.info.data),
                    isArchived: task.archived,
                    keyType: KeyType.signChallenge,
                    task: task,
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
              onPressed: () => createChallenge(
                context: context,
                buildContext: context,
                templateChallenge: task,
              ),
              child: Text(AppLocalizations.of(context).copy),
            ),
          ],
        ],
      ),
      approveActions: [
        LargeSquareButton(
          text: AppLocalizations.of(context).sign,
          icon: Icons.check,
          onPressed: () {
            model.joinChallenge(task, agree: true);
          },
          color: const Color(0xFF298E29),
        ),
        LargeSquareButton(
          text: AppLocalizations.of(context).decline,
          icon: Icons.close,
          onPressed: () {
            model.joinChallenge(task, agree: false);
          },
          color: const Color(0xFFAA3026),
        ),
      ],
      cardActions: [
        FilledButton.tonal(
          onPressed: () => launchCardReader(
            context,
            (card) => model.advanceChallengeWithCard(task, card),
          ),
          child: Text(AppLocalizations.of(context).readCard),
        ),
      ],
      onArchiveChange: (archive) => model.archiveTask(task, archive: archive),
    );
  }

  String _decodeHexToString(List<int> data) {
    try {
      return utf8.decode(data, allowMalformed: false);
    } on FormatException {
      return hex.encode(data);
    }
  }
}
