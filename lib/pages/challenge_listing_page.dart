import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/challenge_creator.dart';
import '../util/card_reader_launcher.dart';
import '../util/chars.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/entity_chip.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

enum DataView { hex, text }

class ChallengeListingPage extends StatelessWidget {
  const ChallengeListingPage({super.key});

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

  static final _pageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _pageKey,
      child: Consumer<AppViewModel>(builder: (context, model, child) {
        return DefaultPageTemplate(
          floatingActionButton: _buildFab(context, model),
          body: TaskListView<Challenge>(
            tasks: model.challengeTasks,
            emptyView: _buildEmptyChallengeTasks(context),
            showArchived: context.read<AppViewModel>().showArchived,
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
          ),
        );
      }),
    );
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.challengeTasks.isEmpty) {
      return SizedBox();
    }
    return FabConfigurator(
        fabType: FabType.challengeFab, buildContext: context);
  }

  Widget _buildEmptyChallengeTasks(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
            child: ControlledLottieAnimation(
              startAtTabIndex: 1,
              assetName: 'assets/lottie/challenge.json',
              stopAtPercentage: 0.5,
              width: 400,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Text(
            'Try creating a new challenge.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SMALL_GAP),
          const Text(
            'Start by creating a group for challenges.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LARGE_GAP),
          ElevatedButton(
            onPressed: () {
              final tabViewModel =
                  Provider.of<TabsViewModel>(context, listen: false);

              tabViewModel.setIndex(3);
            },
            child: const Text('Create a challenge group'),
          ),
          const SizedBox(height: MEDIUM_GAP),
          ElevatedButton(
            onPressed: () {
              createChallenge(context, context);
            },
            child: const Text('Create a challenge'),
          )
        ],
      ),
    );
  }
}
