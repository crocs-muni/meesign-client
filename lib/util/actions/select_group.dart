import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../view_model/app_view_model.dart';

Future<Group?> selectGroup(keyType, BuildContext buildContext) async {
  final state = buildContext.read<AppViewModel>();
  final groups = state.groupTasks
      .where((task) =>
          task.state == TaskState.finished &&
          task.info.keyType == keyType &&
          (state.showArchived || !task.archived))
      .map((task) => task.info);

  return showDialog<Group?>(
    context: buildContext,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Select group'),
        children: groups
            .map((group) => SimpleDialogOption(
                  child: Text(group.name),
                  onPressed: () {
                    Navigator.pop(context, group);
                  },
                ))
            .toList(),
      );
    },
  );
}
