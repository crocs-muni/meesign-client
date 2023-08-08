import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_container.dart';
import '../card/card.dart';
import '../routes.dart';
import '../sync.dart';
import '../util/chars.dart';
import '../widget/counter_badge.dart';
import '../widget/dismissible.dart';
import '../widget/empty_list.dart';
import 'home_state.dart';

class TaskStateIndicator extends StatelessWidget {
  final TaskState state;
  final double progress;

  const TaskStateIndicator(this.state, this.progress, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TaskState.created:
        return const Icon(Icons.arrow_drop_down);
      case TaskState.running:
        return SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.0,
          ),
        );
      case TaskState.needsCard:
        return const Icon(Icons.payment);
      case TaskState.finished:
        return const Icon(Icons.check, color: Colors.green);
      case TaskState.failed:
        return Icon(Icons.error_outline,
            color: Theme.of(context).colorScheme.error);
    }
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

String? statusMessage(Task task) {
  switch (task.state) {
    case TaskState.created:
      return 'Waiting for confirmation '
          '${task.approved ? 'by others' : ''}';
    case TaskState.running:
      return 'Working on task';
    case TaskState.needsCard:
      return 'Needs card to continue';
    case TaskState.finished:
      return null;
    case TaskState.failed:
      return 'Task failed';
  }
}

Widget buildTaskListView<T>(
  List<Task<T>> tasks, {
  required String finishedTitle,
  required Widget emptyView,
  required Widget Function(BuildContext, Task<T>) unfinishedBuilder,
  required Widget Function(BuildContext, Task<T>) finishedBuilder,
}) {
  final groups = tasks.groupListsBy((task) => task.state == TaskState.finished);
  final unfinished = groups[false] ?? [];
  final finished = groups[true] ?? [];

  // TODO: unfinished.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));

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
        return unfinishedBuilder(context, unfinished[i - 1]);
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
class SignTile extends StatelessWidget {
  final String name;
  final String group;
  final String? desc;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool showActions;
  final List<Widget> actions;

  const SignTile({
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
              avatar: CircleAvatar(
                child: Text(
                  group.initials,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              label: Text(group),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: showActions ? actions : [],
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
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<File>(
        model.signTasks,
        finishedTitle: 'Signed files',
        emptyView: const EmptyList(hint: 'Add new group first.'),
        unfinishedBuilder: (context, task) {
          final approveActions = <Widget>[
            FilledButton.tonal(
              child: const Text('Sign'),
              onPressed: () => model.joinSign(task, agree: true),
            ),
            OutlinedButton(
              child: const Text('Decline'),
              onPressed: () => model.joinSign(task, agree: false),
            ),
          ];

          return SignTile(
            name: task.info.basename,
            group: task.info.group.name,
            desc: statusMessage(task),
            trailing: TaskStateIndicator(task.state, task.round / task.nRounds),
            initiallyExpanded: true,
            actions: <Widget>[
                  FilledButton.tonal(
                    child: const Text('View'),
                    onPressed: () => _openFile(task.info.path),
                  ),
                ] +
                (task.approvable ? approveActions : []),
          );
        },
        finishedBuilder: (context, task) {
          final file = task.info;
          return Deletable(
            dismissibleKey: ObjectKey(file),
            child: SignTile(
              name: file.basename,
              group: file.group.name,
              trailing: const TaskStateIndicator(TaskState.finished, 1),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('View'),
                  onPressed: () => _openFile(file.path),
                ),
              ],
            ),
            confirmTitle: 'Do you really want to delete ${file.basename}?',
            onDeleted: (_) {
              // FIXME: remove the actual file
            },
          );
        },
      );
    });
  }
}

class GroupTile extends StatelessWidget {
  final String name;
  final String? desc;
  final List<String> members;
  final int threshold;
  final KeyType keyType;
  final Widget? trailing;
  final bool initiallyExpanded;
  final bool showActions;
  final List<Widget> actions;

  const GroupTile({
    Key? key,
    required this.name,
    this.desc,
    required this.members,
    required this.threshold,
    required this.keyType,
    this.trailing,
    this.initiallyExpanded = false,
    this.showActions = true,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Threshold: $threshold / ${members.length}'),
          Text('Purpose: ${[
            'Sign PDF',
            'Challenge',
            'Decrypt'
          ][keyType.index]}'),
        ],
      ),
      Container(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: members
              .map((m) => Chip(
                    avatar: CircleAvatar(
                      child: Text(
                        m.initials,
                        style: Theme.of(context).textTheme.labelLarge,
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
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: actions,
          ),
        ),
      );
    }

    return ExpansionTile(
      title: Text(name),
      subtitle: desc != null ? Text(desc!) : null,
      leading: CircleAvatar(
        child: Text(name.initials),
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
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Group>(
        model.groupTasks,
        finishedTitle: 'Groups',
        emptyView: const EmptyList(
          hint: 'Try creating a new group.',
        ),
        unfinishedBuilder: (context, task) {
          final group = task.info;

          return GroupTile(
            name: group.name,
            desc: statusMessage(task),
            members: group.members.map((m) => m.name).toList(),
            threshold: group.threshold,
            keyType: group.keyType,
            trailing: TaskStateIndicator(task.state, task.round / task.nRounds),
            initiallyExpanded: true,
            showActions: task.approvable,
            actions: [
              FilledButton.tonal(
                child: const Text('Join'),
                onPressed: () => model.joinGroup(task, agree: true),
              ),
              if (CardManager.platformSupported && group.protocol.cardSupport)
                FilledButton.tonal(
                  onPressed: () =>
                      model.joinGroup(task, agree: true, withCard: true),
                  child: const Text('Join with card'),
                ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinGroup(task, agree: false),
              )
            ],
          );
        },
        finishedBuilder: (context, task) {
          final group = task.info;
          return GroupTile(
            name: group.name,
            members: group.members.map((m) => m.name).toList(),
            threshold: group.threshold,
            keyType: group.keyType,
            trailing: const Icon(Icons.check, color: Colors.green),
          );
        },
      );
    });
  }
}

class LogInSubPage extends StatelessWidget {
  const LogInSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Challenge>(
        model.challengeTasks,
        finishedTitle: 'Finished',
        emptyView: const EmptyList(
          hint: 'Challenge signing requests.',
        ),
        unfinishedBuilder: (context, task) {
          return SignTile(
            name: task.info.name,
            group: task.info.group.name,
            desc: statusMessage(task),
            trailing: TaskStateIndicator(task.state, task.round / task.nRounds),
            initiallyExpanded: true,
            showActions: task.approvable,
            actions: [
              FilledButton.tonal(
                child: const Text('Sign'),
                onPressed: () => model.joinChallenge(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinChallenge(task, agree: false),
              )
            ],
          );
        },
        finishedBuilder: (context, task) {
          return SignTile(
            name: task.info.name,
            group: task.info.group.name,
            trailing: const TaskStateIndicator(TaskState.finished, 1),
          );
        },
      );
    });
  }
}

class DecryptSubPage extends StatelessWidget {
  const DecryptSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Decrypt>(
        model.decryptTasks,
        finishedTitle: 'Finished',
        emptyView: const EmptyList(
          hint: 'Requests for decryptions.',
        ),
        unfinishedBuilder: (context, task) {
          return SignTile(
            name: task.info.name,
            group: task.info.group.name,
            desc: statusMessage(task),
            trailing: TaskStateIndicator(task.state, task.round / task.nRounds),
            initiallyExpanded: true,
            showActions: task.approvable,
            actions: [
              FilledButton.tonal(
                child: const Text('Decrypt'),
                onPressed: () => model.joinDecrypt(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinDecrypt(task, agree: false),
              )
            ],
          );
        },
        finishedBuilder: (context, task) {
          return SignTile(
            name: task.info.name,
            group: task.info.group.name,
            trailing: const TaskStateIndicator(TaskState.finished, 1),
            desc: utf8.decode(task.info.data, allowMalformed: true),
          );
        },
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final di = context.read<AppContainer>();
    return ChangeNotifierProvider(
      create: (context) => HomeState(
        di.userRepository,
        di.deviceRepository,
        di.groupRepository,
        di.fileRepository,
        di.challengeRepository,
        di.decryptRepository,
      ),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _index = 0;

  Future<Group?> _selectGroup(keyType) async {
    final groups = context.read<HomeState>().groups;
    return showDialog<Group?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select group'),
          children: groups
              .where((group) => group.keyType == keyType)
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

  Future<List<String>?> _inputMessage() async {
    return showDialog<List<String>?>(
      context: context,
      builder: (context) {
        var description = TextEditingController();
        var message = TextEditingController();

        return SimpleDialog(title: const Text('Input message'), children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: description,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: message,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                  onPressed: () {
                    var result = List<String>.empty(growable: true);
                    result.add(description.text);
                    result.add(message.text);
                    Navigator.pop(context, result);
                  },
                  child: const Text("Next"))),
        ]);
      },
    );
  }

  static Future<XFile?> _pickPdfFile() async {
    XFile? file;

    if (Platform.isAndroid) {
      // TODO: migrate to file_selector completely
      // once it allows us to retrieve the display name of the file
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );
      final path = res?.files.firstOrNull?.path;
      if (path != null) file = XFile(path);
    } else {
      file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF Documents', extensions: ['pdf']),
        ],
      );
    }

    return file;
  }

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
    final file = await _pickPdfFile();
    if (file == null) return;

    if (await file.length() > HomeState.maxFileSize) {
      showErrorDialog(
        title: 'File too large',
        desc: 'Please select a smaller one.',
      );
      return;
    }

    final group = await _selectGroup(KeyType.signPdf);
    if (group == null) return;

    try {
      await context.read<HomeState>().sign(file, group);
    } catch (e) {
      showErrorDialog(
        title: 'Sign request failed',
        desc: 'Please try again.',
      );
      rethrow;
    }
  }

  Future<void> _group() async {
    final res = await Navigator.pushNamed(context, Routes.newGroup) as Group?;
    if (res == null) return;

    try {
      await context.read<HomeState>().addGroup(
          res.name, res.members, res.threshold, res.protocol, res.keyType);
    } catch (e) {
      showErrorDialog(
        title: 'Group request failed',
        desc: 'Please try again',
      );
      rethrow;
    }
  }

  Future<void> _encrypt() async {
    final message = await _inputMessage();
    if (message == null) return;

    final group = await _selectGroup(KeyType.decrypt); // TODO change
    if (group == null) return;

    try {
      await context.read<HomeState>().encrypt(message[0], message[1], group);
    } catch (e) {
      showErrorDialog(
        title: 'Decryption request failed',
        desc: 'Please try again.',
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      SigningSubPage(),
      LogInSubPage(),
      DecryptSubPage(),
      GroupsSubPage(),
    ];

    final fabs = [
      FloatingActionButton.extended(
        key: const ValueKey('SignFab'),
        onPressed: _sign,
        label: const Text('Sign'),
        icon: const Icon(Icons.add),
      ),
      null,
      FloatingActionButton.extended(
        key: const ValueKey('EncryptFab'),
        onPressed: _encrypt,
        label: const Text('Encrypt'),
        icon: const Icon(Icons.add),
      ),
      FloatingActionButton.extended(
        onPressed: _group,
        label: const Text('New'),
        icon: const Icon(Icons.add),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeeSign'),
        actions: [
          Consumer<HomeState>(builder: (context, model, child) {
            final name = model.device?.name ?? '';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedBuilder(
                    animation: context.read<Sync>().subscribed,
                    builder: (context, child) {
                      return Badge(
                        backgroundColor: context.read<Sync>().subscribed.value
                            ? Colors.green
                            : Colors.orange,
                        smallSize: 8,
                        child: CircleAvatar(
                          child: Text(name.initials),
                        ),
                      );
                    },
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
      floatingActionButton: fabs[_index],
      bottomNavigationBar: NavigationBar(
        destinations: <Widget>[
          NavigationDestination(
            icon: CounterBadge(
              stream: context.watch<HomeState>().nSignReqs,
              child: const Icon(Icons.draw),
            ),
            label: 'Signing',
          ),
          NavigationDestination(
            icon: CounterBadge(
              stream: context.watch<HomeState>().nChallengeReqs,
              child: const Icon(Icons.quiz),
            ),
            label: 'Challenge',
          ),
          NavigationDestination(
              icon: CounterBadge(
                stream: context.watch<HomeState>().nDecryptReqs,
                child: const Icon(Icons.key),
              ),
              label: 'Decrypt'),
          NavigationDestination(
            icon: CounterBadge(
              stream: context.watch<HomeState>().nGroupReqs,
              child: const Icon(Icons.group),
            ),
            label: 'Groups',
          ),
        ],
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
