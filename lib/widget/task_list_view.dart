import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../enums/task_status.dart';
import '../ui_constants.dart';

class TaskListView<T> extends StatelessWidget {
  final List<Task<T>> tasks;
  final Widget emptyView;
  final Widget Function(BuildContext, Task<T>) taskBuilder;
  final bool showArchived;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.emptyView,
    required this.taskBuilder,
    this.showArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    // Group tasks by section
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

    if (taskCount == 0) {
      return emptyView;
    } else if (!showArchived) {
      // Check if there is any non-archived task
      final nonArchivedTaskCount = taskGroups.entries
          .where((entry) => entry.key != TaskListSection.archived)
          .map((entry) => entry.value.length)
          .sum;

      if (nonArchivedTaskCount == 0) {
        return emptyView;
      }
    }

    return ListView(
      children: sections.map((section) {
        final sectionTasks = taskGroups[section] ?? <Task<T>>[];
        return Column(children: [
          Theme(
              // This is to remove the default divider color of ExpansionTile
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ExpansionTile(
                  maintainState: true,
                  initiallyExpanded: true,
                  childrenPadding: EdgeInsets.only(top: SMALL_GAP),
                  iconColor: Theme.of(context).iconTheme.color,
                  collapsedIconColor: Theme.of(context).iconTheme.color,
                  title:
                      _buildSectionTitle(context, section, sectionTasks.length),
                  children: sectionTasks.isEmpty
                      ? [
                          Padding(
                              padding: EdgeInsets.only(left: MEDIUM_GAP),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("No items in this section"),
                              ))
                        ]
                      : sectionTasks
                          .map((task) => taskBuilder(context, task))
                          .toList(),
                ),
              )),
          SizedBox(height: MEDIUM_GAP),
          if (section != sections.last) const Divider()
        ]);
      }).toList(),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, TaskListSection section, int taskCount) {
    return Row(
      children: [
        _getSectionIcon(section),
        SizedBox(width: MEDIUM_GAP),
        Expanded(
          child: Text(
            _getSectionTitle(section),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize),
          ),
        ),
        SizedBox(width: SMALL_GAP),
        Text(
          '($taskCount)',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              color: Theme.of(context).colorScheme.primary),
        )
      ],
    );
  }

  String _getSectionTitle(TaskListSection section) {
    return switch (section) {
      TaskListSection.requests => _getRequiredSectionHeading(),
      TaskListSection.finished => _getJoinedSectionHeading(),
      TaskListSection.rejected => _getRejectedSectionHeading(),
      TaskListSection.failed => _getFailedSectionHeading(),
      TaskListSection.archived => _getArchivedSectionHeading(),
    };
  }

  Widget _getSectionIcon(TaskListSection section) {
    return switch (section) {
      TaskListSection.requests => const Icon(Icons.group_add),
      TaskListSection.finished => const Icon(Icons.check_circle),
      TaskListSection.rejected => const Icon(Icons.cancel),
      TaskListSection.failed => const Icon(Icons.error),
      TaskListSection.archived => const Icon(Icons.archive),
    };
  }

  String _getRequiredSectionHeading() {
    if (T == Group) {
      return 'Group invitations';
    } else if (T == Challenge) {
      return 'Challenge invitations';
    } else if (T == Decrypt) {
      return 'Decryption invitations';
    } else if (T == File) {
      return 'Signing invitations';
    } else {
      return 'Pending requests';
    }
  }

  String _getJoinedSectionHeading() {
    if (T == Group) {
      return 'Joined groups';
    } else if (T == Challenge) {
      return 'Joined challenges';
    } else if (T == Decrypt) {
      return 'Joined decryptions';
    } else if (T == File) {
      return 'Joined signings';
    } else {
      return 'Signed or decrypted';
    }
  }

  String _getRejectedSectionHeading() {
    if (T == Group) {
      return 'Rejected groups';
    } else if (T == Challenge) {
      return 'Rejected challenges';
    } else if (T == Decrypt) {
      return 'Rejected decryptions';
    } else if (T == File) {
      return 'Rejected signings';
    } else {
      return 'Rejected';
    }
  }

  String _getFailedSectionHeading() {
    if (T == Group) {
      return 'Failed groups';
    } else if (T == Challenge) {
      return 'Failed challenges';
    } else if (T == Decrypt) {
      return 'Failed decryptions';
    } else if (T == File) {
      return 'Failed signings';
    } else {
      return 'Failed';
    }
  }

  String _getArchivedSectionHeading() {
    if (T == Group) {
      return 'Archived groups';
    } else if (T == Challenge) {
      return 'Archived challenges';
    } else if (T == Decrypt) {
      return 'Archived decryptions';
    } else if (T == File) {
      return 'Archived signings';
    } else {
      return 'Archived';
    }
  }
}

Widget buildTaskListView<T>(
  List<Task<T>> tasks, {
  required BuildContext context,
  required Widget emptyView,
  required Widget Function(BuildContext, Task<T>) taskBuilder,
  bool showArchived = false,
}) {
  return TaskListView<T>(
    tasks: tasks,
    emptyView: emptyView,
    taskBuilder: taskBuilder,
    showArchived: showArchived,
  );
}
