import 'dart:io';

import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/mpc_model.dart';
import '../model/tasks.dart';
import '../routes.dart';
import 'dismissible.dart';

class TaskStatusIndicator extends StatelessWidget {
  final TaskStatus status;
  final double progress;

  const TaskStatusIndicator(this.status, this.progress, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TaskStatus.unapproved:
        return const Icon(Icons.arrow_drop_down);
      case TaskStatus.waiting:
        return const Icon(Icons.timer_outlined);
      case TaskStatus.working:
        return SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.0,
          ),
        );
      case TaskStatus.finished:
        return const Icon(Icons.check, color: Colors.green);
      case TaskStatus.error:
        return Icon(Icons.error_outline, color: Theme.of(context).errorColor);
    }
  }
}

class EmptyList extends StatelessWidget {
  final String hint;

  const EmptyList({Key? key, this.hint = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '0',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 4),
          Text(
            'Nothing here yet.\n$hint',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

extension Intersperse<T> on List<T> {
  List<T> intersperse(T inter) {
    List<T> res = [];
    for (T item in this) {
      res.add(item);
      res.add(inter);
    }
    if (res.isNotEmpty) res.removeLast();
    return res;
  }
}

String? statusMessage(TaskStatus status) {
  switch (status) {
    case TaskStatus.unapproved:
      return 'Waiting for confirmation';
    case TaskStatus.waiting:
      return 'Waiting for approval by others';
    case TaskStatus.working:
      return 'Working on task';
    case TaskStatus.finished:
      return null;
    case TaskStatus.error:
      return 'Task failed';
  }
}

Widget buildTaskListView<T extends MpcTask, U>(
  List<T> tasks,
  List<U> finished, {
  required String finishedTitle,
  required Widget emptyView,
  required Widget Function(BuildContext, T, Widget?) unfinishedBuilder,
  required Widget Function(BuildContext, U) finishedBuilder,
}) {
  final unfinished =
      tasks.where((task) => task.status != TaskStatus.finished).toList();

  int length = finished.length + unfinished.length;

  if (length == 0) return emptyView;

  return ListView.builder(
    itemCount: length + 2,
    itemBuilder: (context, i) {
      if (i == 0) {
        return const ListTile(
          title: Text(
            'Requests',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          dense: true,
        );
      }
      if (i == 1 + unfinished.length) {
        return ListTile(
          title: Text(
            finishedTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          dense: true,
        );
      }
      if (i <= unfinished.length) {
        return ChangeNotifierProvider.value(
          value: unfinished[i - 1],
          child: Consumer<T>(
            builder: unfinishedBuilder,
          ),
        );
      } else {
        return finishedBuilder(context, finished[i - unfinished.length - 2]);
      }
    },
  );
}

void _openFile(String path) {
  if (Platform.isLinux) {
    launchUrl(Uri.file(path));
  } else {
    // FIXME: try to avoid open_file package,
    // it seems to be of low quality
    OpenFile.open(path);
  }
}

// FIXME: this is more or less copy of GroupTile below,
// this probably needs a rewrite
class FileTile extends StatelessWidget {
  final String name;
  final String group;
  final String? desc;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool showActions;
  final List<Widget> actions;

  const FileTile({
    Key? key,
    required this.name,
    required this.group,
    this.desc,
    this.trailing,
    this.initiallyExpanded = false,
    this.showActions = true,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(name),
      subtitle: desc != null ? Text(desc!) : null,
      initiallyExpanded: initiallyExpanded,
      trailing: trailing,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              avatar: const CircleAvatar(
                child: Icon(Icons.group),
              ),
              label: Text(group),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      return buildTaskListView<SignTask, SignedFile>(
        model.signTasks.toList(),
        model.files,
        finishedTitle: 'Signed files',
        emptyView: const EmptyList(hint: 'Add new group first.'),
        unfinishedBuilder: (context, task, _) {
          final approveActions = <Widget>[
            OutlinedButton(
              child: const Text('SIGN'),
              onPressed: () => model.approveTask(task, agree: true),
            ),
            OutlinedButton(
              child: const Text('DECLINE'),
              onPressed: null,
            ),
          ];

          return FileTile(
            name: task.file.basename,
            group: task.file.group.name,
            desc: statusMessage(task.status),
            trailing: TaskStatusIndicator(task.status, task.progress),
            initiallyExpanded: true,
            actions: <Widget>[
                  OutlinedButton(
                    child: const Text('VIEW'),
                    onPressed: () => _openFile(task.file.path),
                  ),
                ] +
                (task.status == TaskStatus.unapproved ? approveActions : []),
          );
        },
        finishedBuilder: (context, file) {
          return Deletable(
            dismissibleKey: ObjectKey(file),
            child: FileTile(
              name: file.basename,
              group: file.group.name,
              trailing: const TaskStatusIndicator(TaskStatus.finished, 1),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('VIEW'),
                  onPressed: () => _openFile(file.path),
                ),
              ],
            ),
            confirmTitle: 'Do you really want to delete ${file.basename}?',
            onDeleted: (_) {
              // FIXME: remove the actual file
              model.files.remove(file);
            },
          );
        },
      );
    });
  }
}

String _nameInitials(String name, {int count = 2}) => name
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(count)
    .map((w) => w.characters.first.toUpperCase())
    .join();

class GroupTile extends StatelessWidget {
  final String name;
  final String? desc;
  final List<String> members;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool showActions;
  final List<Widget> actions;

  const GroupTile({
    Key? key,
    required this.name,
    this.desc,
    required this.members,
    this.trailing,
    this.initiallyExpanded = false,
    this.showActions = true,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Container(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: members
              .map((m) => Chip(
                    avatar: CircleAvatar(
                      child: Text(
                        _nameInitials(m, count: 1),
                      ),
                    ),
                    label: Text(m),
                  ))
              .toList(),
        ),
      ),
    ];
    if (showActions && actions.isNotEmpty) {
      children.add(
        Container(
          alignment: Alignment.topRight,
          child: Wrap(
            spacing: 8,
            children: actions,
          ),
        ),
      );
    }

    return ExpansionTile(
      title: Text(name),
      subtitle: desc != null ? Text(desc!) : null,
      leading: CircleAvatar(
        child: Text(
          _nameInitials(name),
        ),
      ),
      initiallyExpanded: initiallyExpanded,
      trailing: trailing,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      children: children.intersperse(
        const SizedBox(height: 16),
      ),
    );
  }
}

class GroupsSubPage extends StatelessWidget {
  const GroupsSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      // FIXME: finished tasks should be removed at some time

      return buildTaskListView<GroupTask, Group>(
        model.groupTasks.toList(),
        model.groups,
        finishedTitle: 'Groups',
        emptyView: const EmptyList(
          hint: 'Try creating a new group',
        ),
        unfinishedBuilder: (context, task, _) {
          final group = task.groupBase;

          return GroupTile(
            name: group.name,
            desc: statusMessage(task.status),
            members: group.members.map((m) => m.name).toList(),
            trailing: TaskStatusIndicator(task.status, task.progress),
            initiallyExpanded: true,
            showActions: task.status == TaskStatus.unapproved,
            actions: [
              OutlinedButton(
                child: const Text('JOIN'),
                onPressed: () => model.approveTask(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('DECLINE'),
                onPressed: null,
              )
            ],
          );
        },
        finishedBuilder: (context, group) {
          return GroupTile(
            name: group.name,
            members: group.members.map((m) => m.name).toList(),
            trailing: const Icon(Icons.check, color: Colors.green),
          );
        },
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

ValueNotifier<int> _unapprovedCounter(Stream<MpcTask> stream) {
  final ValueNotifier<int> counter = ValueNotifier(0);
  stream.listen((task) {
    ++counter.value;
    void listener() {
      if (task.status != TaskStatus.unapproved) {
        --counter.value;
        task.removeListener(listener);
      }
    }

    task.addListener(listener);
  });
  return counter;
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  late final ValueNotifier<int> _nGroupReqs;
  late final ValueNotifier<int> _nSignReqs;

  @override
  void initState() {
    super.initState();
    // TODO: when to cancel it?
    MpcModel model = context.read<MpcModel>();
    _nGroupReqs = _unapprovedCounter(model.groupRequests);
    _nSignReqs = _unapprovedCounter(model.signRequests);
  }

  Future<Group?> _selectGroup() async {
    return showDialog<Group?>(
      context: context,
      builder: (context) {
        return Consumer<MpcModel>(
          builder: (context, model, child) {
            return SimpleDialog(
              title: const Text('Select group'),
              // FIXME: only finished groups!
              children: model.groups
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
      },
    );
  }

  static Future<FilePickerResult?> _pickPdfFile() async =>
      FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

  void showErrorDialog({required String title, required String desc}) =>
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(desc),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

  Future<void> _sign() async {
    final res = await _pickPdfFile();
    if (res == null || res.files.isEmpty) return;

    final file = res.files.first;
    final path = file.path;
    if (path == null) return;

    if (file.size > MpcModel.maxFileSize) {
      showErrorDialog(
        title: 'File too large',
        desc: 'Please select a smaller one.',
      );
      return;
    }

    final group = await _selectGroup();
    if (group == null) return;

    try {
      context.read<MpcModel>().sign(path, group);
    } catch (e) {
      showErrorDialog(
        title: 'Sign request failed',
        desc: 'Please try again.',
      );
    }
  }

  Future<void> _group() async {
    final res = await Navigator.pushNamed(context, Routes.newGroup)
        as Map<String, Object>?;
    if (res == null) return;

    try {
      final name = res['name'] as String;
      final members = res['members'] as List<Cosigner>;
      await context.read<MpcModel>().addGroup(name, members, members.length);
    } catch (e) {
      showErrorDialog(
        title: 'Group request failed',
        desc: 'Please try again',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      SigningSubPage(),
      GroupsSubPage(),
    ];

    final signFab = FloatingActionButton.extended(
      key: const ValueKey('SignFab'),
      onPressed: _sign,
      label: const Text('Sign'),
      icon: const Icon(Icons.add),
    );
    final groupFab = FloatingActionButton.extended(
      onPressed: _group,
      label: const Text('New'),
      icon: const Icon(Icons.add),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeeSign'),
        actions: [
          Consumer<MpcModel>(builder: (context, model, child) {
            final name = model.thisDevice.name;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    child: AnimatedBuilder(
                      animation: model.lastUpdate,
                      builder: (context, child) {
                        return Badge(
                          badgeColor: model.lastUpdate.value > -5
                              ? Colors.green
                              : Colors.orange,
                          child: Text(
                            _nameInitials(name),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.pushNamed(context, Routes.qrIdentity);
            },
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            fillColor: Colors.transparent,
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_index],
      ),
      floatingActionButton: _index == 0 ? signFab : groupFab,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _nSignReqs,
              builder: (context, _) => Badge(
                badgeContent: Text('${_nSignReqs.value}'),
                child: const Icon(Icons.lock),
                showBadge: _nSignReqs.value != 0,
              ),
            ),
            label: 'Signing',
          ),
          BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _nGroupReqs,
              builder: (context, _) => Badge(
                badgeContent: Text('${_nGroupReqs.value}'),
                child: const Icon(Icons.people),
                showBadge: _nGroupReqs.value != 0,
              ),
            ),
            label: 'Groups',
          ),
        ],
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
