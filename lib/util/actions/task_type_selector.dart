import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../enums/task_type.dart';

Future<TaskType?> showTaskTypeDialog(BuildContext context) async {
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
              ListTile(
                leading: const Icon(Symbols.emoji_symbols),
                title: const Text('Signing'),
                onTap: () {
                  Navigator.of(context).pop(TaskType.sign);
                },
              ),
              ListTile(
                leading: const Icon(Symbols.lock),
                title: const Text('Decrypt'),
                onTap: () {
                  Navigator.of(context).pop(TaskType.decrypt);
                },
              ),
              ListTile(
                leading: const Icon(Symbols.quiz),
                title: const Text('Challenge'),
                onTap: () {
                  Navigator.of(context).pop(TaskType.challenge);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
