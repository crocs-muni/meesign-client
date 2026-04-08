import 'package:flutter/material.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

Future<Group?> selectGroup(KeyType keyType, BuildContext buildContext) async {
  final state = buildContext.read<AppViewModel>();
  final myGroups = state.groupTasks
      .where(
        (task) =>
            task.state == TaskState.finished &&
            task.info.keyType == keyType &&
            (state.showArchived || !task.archived),
      )
      .map((task) => task.info);

  // For decrypt, also include external groups
  final otherGroups = keyType == KeyType.decrypt
      ? state.externalGroups.where((g) => g.keyType == KeyType.decrypt).toList()
      : <Group>[];

  final allGroups = [...myGroups, ...otherGroups];

  return showDialog<Group?>(
    context: buildContext,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Select group'),
        children: allGroups
            .map(
              (group) => SimpleDialogOption(
                child: Text(group.name),
                onPressed: () {
                  Navigator.pop(context, group);
                },
              ),
            )
            .toList(),
      );
    },
  );
}
