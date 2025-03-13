import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../util/card_reader_launcher.dart';
import '../util/chars.dart';
import '../view_model/app_view_model.dart';
import '../widget/empty_list.dart';
import '../widget/entity_chip.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

enum DataView { hex, text }

class ChallengeSubPage extends StatelessWidget {
  const ChallengeSubPage({super.key});

  Future<void> showChallengeDialog(
    BuildContext context,
    Challenge challenge,
  ) async {
    final dataHex = hex.encode(challenge.data);
    String? dataStr;
    try {
      dataStr = utf8.decode(
        challenge.data,
        allowMalformed: false,
      );
    } on FormatException {
      dataStr = null;
    }

    await showDialog(
      context: context,
      builder: (context) {
        final supportedViews = {
          if (dataStr != null) DataView.text,
          DataView.hex,
        };
        DataView view = supportedViews.first;

        return AlertDialog(
          icon: const Icon(Symbols.quiz),
          title: Text(challenge.name),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (supportedViews.length > 1) ...[
                      SegmentedButton<DataView>(
                        segments: [
                          for (final view in supportedViews)
                            ButtonSegment(
                              value: view,
                              label: Text(view.name.capitalize()),
                            ),
                        ],
                        selected: {view},
                        onSelectionChanged: (newView) {
                          setState(() => view = newView.first);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Center(
                      child: switch (view) {
                        DataView.hex => Text(
                            dataHex,
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        DataView.text => Text(
                            dataStr!,
                          ),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hide'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return buildTaskListView<Challenge>(
        model.challengeTasks,
        emptyView: EmptyList(
          hint: model.hasGroup(KeyType.signChallenge)
              ? 'Try creating a new challenge.'
              : 'Start by creating a group for challenges.',
        ),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          return TaskTile(
            task: task,
            name: task.info.name,
            actionChip: GroupChip(group: task.info.group),
            approveActions: [
              FilledButton.tonal(
                child: const Text('Sign'),
                onPressed: () => model.joinChallenge(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinChallenge(task, agree: false),
              )
            ],
            cardActions: [
              FilledButton.tonal(
                onPressed: () => launchCardReader(context,
                    (card) => model.advanceChallengeWithCard(task, card)),
                child: const Text('Read card'),
              ),
            ],
            actions: [
              FilledButton.tonal(
                onPressed: () => showChallengeDialog(context, task.info),
                child: const Text('View'),
              )
            ],
            onArchiveChange: (archive) =>
                model.archiveTask(task, archive: archive),
          );
        },
      );
    });
  }
}
