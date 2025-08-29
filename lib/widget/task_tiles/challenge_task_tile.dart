import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../../l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../pages/task_detail_page.dart';
import '../../ui_constants.dart';
import '../../util/actions/challenge_creator.dart';
import '../../util/card_reader_launcher.dart';
import '../../view_model/app_view_model.dart';
import '../entity_chip.dart';
import '../large_square_button.dart';
import '../task_tile.dart';

class ChallengeTaskTile extends StatelessWidget {
  const ChallengeTaskTile({
    super.key,
    required this.task,
  });

  final Task<Challenge> task;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return TaskTile(
      task: task,
      name: task.info.name,
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
              onPressed: () => createChallenge(
                  context: context,
                  buildContext: context,
                  templateChallenge: task),
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
          color: Color(0xFF298E29),
        ),
        LargeSquareButton(
            text: AppLocalizations.of(context).decline,
            icon: Icons.close,
            onPressed: () {
              model.joinChallenge(task, agree: false);
            },
            color: Color(0xFFAA3026))
      ],
      cardActions: [
        FilledButton.tonal(
          onPressed: () => launchCardReader(
              context, (card) => model.advanceChallengeWithCard(task, card)),
          child: Text(AppLocalizations.of(context).readCard),
        ),
      ],
      actions: const [],
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
