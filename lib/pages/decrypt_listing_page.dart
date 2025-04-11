import 'dart:convert';
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../enums/fab_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/encrypt_data.dart';
import '../util/platform.dart';
import '../util/status_message.dart';
import '../view_model/app_view_model.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/entity_chip.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_list_view.dart';
import '../widget/task_tile.dart';

class DecryptListingPage extends StatelessWidget {
  const DecryptListingPage({super.key});

  static Future<void> _shareDecrypt(Decrypt decrypt) async {
    final file = XFile.fromData(
      decrypt.data as Uint8List,
      name: decrypt.name,
      mimeType: decrypt.dataType.value,
    );

    if (PlatformGroup.isDesktop) {
      final ext = extensionFromMime(decrypt.dataType.value);
      final loc = await getSaveLocation(
        suggestedName: '${decrypt.name}.$ext',
      );
      if (loc != null) {
        file.saveTo(loc.path);
      }
    }
    if (PlatformGroup.isMobile) {
      await Share.shareXFiles([file], text: decrypt.name);
    }
  }

  Future<void> showDecryptDialog(BuildContext context, Decrypt decrypt) async {
    const duration = Duration(seconds: 5);
    const refreshInterval = Duration(milliseconds: 20);
    int steps = duration.inMilliseconds ~/ refreshInterval.inMilliseconds;
    final countdown =
        Stream.periodic(refreshInterval, (i) => max(0, steps - i));
    final countdownSubject = BehaviorSubject<int>();
    final sub = countdown.listen((value) {
      countdownSubject.add(value);

      if (value == 0) {
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    });

    final text = decrypt.dataType == MimeType.textUtf8
        ? utf8.decode(decrypt.data, allowMalformed: true)
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: StreamBuilder(
            stream: countdownSubject.stream,
            builder: (context, snapshot) {
              return Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: (snapshot.data ?? steps) / steps,
                  ),
                ),
              );
            },
          ),
          title: Text(decrypt.name),
          content: switch (decrypt.dataType) {
            MimeType.textUtf8 => Text(text!, textAlign: TextAlign.center),
            MimeType.imageSvg => SvgPicture.memory(decrypt.data as Uint8List),
            var t when t.isImage => Image.memory(decrypt.data as Uint8List),
            _ => const Text(
                'Error: Unknown data type',
                textAlign: TextAlign.center,
              ),
          },
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            switch (decrypt.dataType) {
              MimeType.textUtf8 => IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text!));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied!')),
                    );
                  },
                  icon: const Icon(Symbols.content_copy),
                ),
              var t when t.isImage => IconButton(
                  onPressed: () async {
                    sub.pause();
                    await _shareDecrypt(decrypt);
                    sub.resume();
                  },
                  icon: Icon(PlatformGroup.isMobile
                      ? Symbols.share
                      : Symbols.save_alt),
                ),
              _ => const SizedBox(),
            },
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hide'),
            ),
          ],
        );
      },
    );

    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return DefaultPageTemplate(
        floatingActionButton: _buildFab(context, model),
        body: buildTaskListView<Decrypt>(
          model.decryptTasks,
          emptyView: _buildEmptyDecryptTasks(context),
          showArchived: model.showArchived,
          taskBuilder: (context, task) {
            return TaskTile(
              task: task,
              name: task.info.name,
              desc: StatusMessage.getStatusMessage(task),
              actionChip: GroupChip(group: task.info.group),
              approveActions: [
                FilledButton.tonal(
                  child: const Text('Decrypt'),
                  onPressed: () => model.joinDecrypt(task, agree: true),
                ),
                OutlinedButton(
                  child: const Text('Decline'),
                  onPressed: () => model.joinDecrypt(task, agree: false),
                )
              ],
              actions: [
                if (task.state == TaskState.finished)
                  FilledButton.tonal(
                    onPressed: () => showDecryptDialog(context, task.info),
                    child: const Text('View'),
                  )
              ],
              onArchiveChange: (archive) =>
                  model.archiveTask(task, archive: archive),
            );
          },
        ),
      );
    });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.decryptTasks.isEmpty) {
      return SizedBox();
    }
    return FabConfigurator(fabType: FabType.decryptFab, buildContext: context);
  }

  Widget _buildEmptyDecryptTasks(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
            child: ControlledLottieAnimation(
              startAtTabIndex: 2,
              assetName: 'assets/lottie/decrypt.json',
              stopAtPercentage: 0.5,
              width: 400,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Text(
            'Try encrypting some data.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SMALL_GAP),
          const Text(
            'Start by creating a group for decryption.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LARGE_GAP),
          ElevatedButton(
            onPressed: () {
              final tabViewModel =
                  Provider.of<TabsViewModel>(context, listen: false);

              tabViewModel.setIndex(3);
            },
            child: const Text('Create a decrypt group'),
          ),
          const SizedBox(height: MEDIUM_GAP),
          ElevatedButton(
            onPressed: () {
              encryptData(context, context);
            },
            child: const Text('Decrypt message'),
          )
        ],
      ),
    );
  }
}
