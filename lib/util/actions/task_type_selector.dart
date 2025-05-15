import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../enums/task_type.dart';
import '../../view_model/app_view_model.dart';

Future<TaskType?> showTaskTypeDialog(BuildContext context) async {
  final model = Provider.of<AppViewModel>(context, listen: false);

  return showDialog<TaskType>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Symbols.quiz),
        title: const Text("Select task type"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (model.joinedGroupForTaskTypeExists(KeyType.signPdf)) ...[
                ListTile(
                  leading: const Icon(Symbols.emoji_symbols),
                  title: const Text('Signing'),
                  onTap: () {
                    Navigator.of(context).pop(TaskType.sign);
                  },
                ),
              ],
              if (model.joinedGroupForTaskTypeExists(KeyType.decrypt)) ...[
                ListTile(
                  leading: const Icon(Symbols.lock),
                  title: const Text('Decrypt'),
                  onTap: () {
                    Navigator.of(context).pop(TaskType.decrypt);
                  },
                ),
              ],
              if (model
                  .joinedGroupForTaskTypeExists(KeyType.signChallenge)) ...[
                ListTile(
                  leading: const Icon(Symbols.quiz),
                  title: const Text('Challenge'),
                  onTap: () {
                    Navigator.of(context).pop(TaskType.challenge);
                  },
                ),
              ]
            ],
          ),
        ),
      );
    },
  );
}
