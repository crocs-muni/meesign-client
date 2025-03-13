import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../util/chars.dart';

enum TaskListSection { requests, finished, rejected, failed, archived }

Widget buildTaskListView<T>(
  List<Task<T>> tasks, {
  required Widget emptyView,
  required Widget Function(BuildContext, Task<T>) taskBuilder,
  bool showArchived = false,
}) {
  // TODO: possibly filter in database

  final taskGroups = tasks.groupListsBy((task) {
    if (task.archived) return TaskListSection.archived;
    return switch (task.state) {
      TaskState.finished => TaskListSection.finished,
      TaskState.failed => switch (task.error) {
          TaskError.rejected => TaskListSection.rejected,
          _ => TaskListSection.failed,
        },
      _ => TaskListSection.requests,
    };
  });

  final sections = [
    TaskListSection.requests,
    TaskListSection.finished,
    TaskListSection.rejected,
    if (taskGroups[TaskListSection.failed] != null) TaskListSection.failed,
    if (showArchived) TaskListSection.archived,
  ];

  final taskCount = sections.map((s) => (taskGroups[s] ?? []).length).sum;

  if (taskCount == 0) return emptyView;

  return ListView.builder(
    itemCount: taskCount + sections.length,
    itemBuilder: (context, i) {
      for (final section in sections) {
        final sectionTasks = taskGroups[section] ?? [];

        if (i == 0) {
          return ListTile(
            title: Text(
              section.name.capitalize(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          );
        }
        i -= 1;

        if (i < sectionTasks.length) {
          return taskBuilder(context, sectionTasks[i]);
        }

        i -= sectionTasks.length;
      }

      return null;
    },
  );
}
