import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/task_status.dart';
import '../enums/task_type.dart';
import '../ui_constants.dart';
import '../view_model/app_view_model.dart';

class TaskListView<T> extends StatefulWidget {
  final List<Task<T>> tasks;
  final Widget emptyView;
  final Widget Function(BuildContext, Task<T>) taskBuilder;
  final bool showArchived;
  final bool showOnlyPending;
  final bool showAllTypes;
  final bool mergeCompletedFailed;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.emptyView,
    required this.taskBuilder,
    this.showArchived = false,
    this.showOnlyPending = false,
    this.showAllTypes = false,
    this.mergeCompletedFailed = false,
  });

  @override
  State<TaskListView<T>> createState() => _TaskListViewState<T>();
}

class _TaskListViewState<T> extends State<TaskListView<T>> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TaskType get taskType {
    if (T == Group) {
      return TaskType.group;
    } else if (T == Challenge) {
      return TaskType.challenge;
    } else if (T == Decrypt) {
      return TaskType.decrypt;
    } else if (T == File) {
      return TaskType.sign;
    } else {
      throw Exception('Unsupported task type');
    }
  }

  bool isReloading = false;

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

    if (isReloading) {
      return Column(
        children: [
          _buildTaskListHeader(),
          const SizedBox(height: SMALL_GAP),
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      );
    }

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

    final requestsTasks = taskGroups[TaskListSection.requests] ?? <Task<T>>[];
    final remainingTasks = <Task<T>>[];

    taskGroups.forEach((section, tasks) {
      if (section != TaskListSection.requests &&
          (widget.showArchived || section != TaskListSection.archived)) {
        remainingTasks.addAll(tasks);
      }
    });

    remainingTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskListHeader(),
        Expanded(
            child: _buildTaskList(
          requestsTasks,
          remainingTasks,
        ))
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
    }).map((key, value) {
      value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return MapEntry(key, value);
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

  Widget _buildTaskList(
    List<Task<T>> requestsTasks,
    List<Task<T>> remainingTasks,
  ) {
    var categories = ["requests", "remaining"];
    Map<String, List<Task<T>>> orderedCategorizedTasks = {
      categories[0]: requestsTasks,
      categories[1]: remainingTasks,
    };

    return RefreshIndicator(
        child: ListView(
          children: categories.map((taskCategory) {
            final sectionTasks =
                orderedCategorizedTasks[taskCategory] ?? <Task<T>>[];
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
        onRefresh: () {
          _triggerReloadAnimation();
          return _refreshTasks();
        });
  }

  Future<void> _refreshTasks() async {
    var model = Provider.of<AppViewModel>(context, listen: false);
    return model.refetchTasks(taskType);
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
      Row(
        children: [
          Text(
            _getGeneralHeading(),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          _buildReloadButton()
        ],
      ),
      const SizedBox(height: SMALL_GAP),
      _buildTaskSearchBar(),
      const SizedBox(height: SMALL_GAP),
      Divider(),
      const SizedBox(height: SMALL_GAP),
    ]);
  }

  void _triggerReloadAnimation() {
    if (isReloading) return;

    setState(() {
      isReloading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isReloading = false;
      });
    });
  }

  Widget _buildReloadButton() {
    // Small screen uses pull to refresh, not reload button
    if (MediaQuery.sizeOf(context).width < minTabletLayoutWidth) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
        onPressed: () {
          _triggerReloadAnimation();

          _refreshTasks();
        },
        icon: Icon(Icons.refresh),
        label: Text("Reload"));
  }
}
