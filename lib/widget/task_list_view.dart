import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../enums/task_status.dart';
import '../ui_constants.dart';

class TaskListView<T> extends StatefulWidget {
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
  State<TaskListView<T>> createState() => _TaskListViewState<T>();
}

class _TaskListViewState<T> extends State<TaskListView<T>> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskGroups = groupTasks();

    final sections = [
      TaskListSection.requests,
      TaskListSection.finished,
      TaskListSection.rejected,
      if (taskGroups[TaskListSection.failed] != null) TaskListSection.failed,
      if (widget.showArchived) TaskListSection.archived,
    ];

    final taskCount = sections.map((s) => (taskGroups[s] ?? []).length).sum;

    if (taskCount == 0 && _searchQuery.isEmpty) {
      return widget.emptyView;
    } else if (taskCount == 0 && _searchQuery.isNotEmpty) {
      return Column(
        children: [
          _buildTaskListHeader(),
          const SizedBox(height: SMALL_GAP),
          Text(
            'No tasks found for "$_searchQuery".',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (!widget.showArchived) {
      // Check if there is any non-archived task
      final nonArchivedTaskCount = taskGroups.entries
          .where((entry) => entry.key != TaskListSection.archived)
          .map((entry) => entry.value.length)
          .sum;

      if (nonArchivedTaskCount == 0 && _searchQuery.isEmpty) {
        return widget.emptyView;
      } else if (nonArchivedTaskCount == 0 && _searchQuery.isNotEmpty) {
        return Column(
          children: [
            _buildTaskListHeader(),
            const SizedBox(height: SMALL_GAP),
            Text(
              'No tasks found for "$_searchQuery".',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskListHeader(),
        Expanded(
          child: ListView(
            children: sections.map((section) {
              final sectionTasks = taskGroups[section] ?? <Task<T>>[];
              if (sectionTasks.isEmpty) return const SizedBox.shrink();

              return Theme(
                  // This is to remove the default divider color of ExpansionTile
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final task in sectionTasks)
                          widget.taskBuilder(context, task),
                      ]));
            }).toList(),
          ),
        )
      ],
    );
  }

  Map<TaskListSection, List<Task<T>>> groupTasks() {
    return filterTasks().groupListsBy((task) {
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
  }

  List<Task<T>> filterTasks() {
    return widget.tasks.where((task) {
      if (_searchQuery.isEmpty) return true;

      String? taskName;
      final info = task.info;
      if (info is Group) {
        taskName = info.name;
      } else if (info is Challenge) {
        taskName = info.name;
      } else if (info is Decrypt) {
        taskName = info.name;
      } else if (info is File) {
        taskName = info.path; // Files are identified by path
      }

      return taskName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }

  String _getGeneralHeading() {
    if (T == Group) {
      return 'Groups';
    } else if (T == Challenge) {
      return 'Challenges';
    } else if (T == Decrypt) {
      return 'Decryptions';
    } else if (T == File) {
      return 'Signings';
    } else {
      return 'Tasks';
    }
  }

  Widget _buildTaskSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tasks by name...',
        prefixIcon: const Icon(Icons.search),
        fillColor: Theme.of(context).colorScheme.onInverseSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
      ),
    );
  }

  Widget _buildTaskListHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _getGeneralHeading(),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: SMALL_GAP),
      _buildTaskSearchBar(),
      const SizedBox(height: SMALL_GAP),
      Divider(),
      const SizedBox(height: SMALL_GAP),
    ]);
  }
}
