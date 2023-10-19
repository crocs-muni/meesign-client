import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meesign_core/meesign_card.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_container.dart';
import '../card/card.dart';
import '../routes.dart';
import '../sync.dart';
import '../util/chars.dart';
import '../widget/counter_badge.dart';
import '../widget/empty_list.dart';
import 'card_reader_page.dart';
import 'home_state.dart';

class TaskStateIndicator extends StatelessWidget {
  final Task task;

  const TaskStateIndicator(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (task.state) {
      case TaskState.created:
        return const Icon(Icons.arrow_drop_down);
      case TaskState.running:
        return SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            value: task.round / task.nRounds,
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
  required Widget Function(BuildContext, Task<T>, bool) taskBuilder,
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
        return taskBuilder(context, unfinished[i - 1], false);
      } else {
        return taskBuilder(context, finished[i - unfinished.length - 2], true);
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

void _launchCardReader(
  BuildContext context,
  Future<void> Function(Card) onCard,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CardReaderPage(
        onCard: onCard,
      ),
    ),
  );
}

class EntityChip extends StatelessWidget {
  final String name;

  const EntityChip({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        child: Text(
          name.initials,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      label: Text(name),
    );
  }
}

class TaskTile<T> extends StatelessWidget {
  final Task<T> task;
  final String name;
  final String? desc;
  final Widget? leading, trailing;
  final Widget? actionChip;
  final List<Widget> approveActions, cardActions, actions;
  final List<Widget> children;

  const TaskTile({
    Key? key,
    required this.task,
    required this.name,
    this.desc,
    this.leading,
    this.trailing,
    this.actionChip,
    this.approveActions = const [],
    this.cardActions = const [],
    this.actions = const [],
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finished = task.state == TaskState.finished;
    final desc = this.desc ?? statusMessage(task);
    final trailing = this.trailing ?? TaskStateIndicator(task);
    final allActions = actions +
        (task.approvable ? approveActions : []) +
        (task.state == TaskState.needsCard ? cardActions : []);

    final actionRow = allActions.isNotEmpty || actionChip != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (actionChip != null) actionChip!,
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: allActions,
                ),
              ),
            ].intersperse(
              const SizedBox(width: 8),
            ),
          )
        : null;

    return ExpansionTile(
      title: Text(name),
      subtitle: desc != null ? Text(desc) : null,
      initiallyExpanded: !finished,
      leading: leading,
      trailing: trailing,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      children: [
        ...children,
        if (actionRow != null) actionRow,
      ].intersperse(
        const SizedBox(height: 8),
      ),
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
        taskBuilder: (context, task, finished) {
          return TaskTile(
            task: task,
            name: task.info.basename,
            actionChip: EntityChip(name: task.info.group.name),
            actions: <Widget>[
              FilledButton.tonal(
                child: const Text('View'),
                onPressed: () => _openFile(task.info.path),
              ),
            ],
            approveActions: [
              FilledButton.tonal(
                child: const Text('Sign'),
                onPressed: () => model.joinSign(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinSign(task, agree: false),
              ),
            ],
          );
        },
      );
    });
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
        taskBuilder: (context, task, finished) {
          final group = task.info;
          final members = group.members;
          return TaskTile(
            task: task,
            name: group.name,
            leading: CircleAvatar(
              child: Text(group.name.initials),
            ),
            approveActions: [
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
              ),
            ],
            cardActions: [
              FilledButton.tonal(
                onPressed: () => _launchCardReader(
                    context, (card) => model.advanceGroupWithCard(task, card)),
                child: const Text('Read card'),
              ),
            ],
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Threshold: ${group.threshold} / ${members.length}'),
                  Text('Purpose: ${[
                    'Sign PDF',
                    'Challenge',
                    'Decrypt'
                  ][group.keyType.index]}'),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [for (var m in members) EntityChip(name: m.name)],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class ChallengeSubPage extends StatelessWidget {
  const ChallengeSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Challenge>(
        model.challengeTasks,
        finishedTitle: 'Finished',
        emptyView: const EmptyList(
          hint: 'Challenge signing requests.',
        ),
        taskBuilder: (context, task, finished) {
          return TaskTile(
            task: task,
            name: task.info.name,
            actionChip: EntityChip(name: task.info.group.name),
            approveActions: [
              FilledButton.tonal(
                child: const Text('Sign'),
                onPressed: () => model.joinChallenge(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinChallenge(task, agree: false),
              )
            ],
            cardActions: [
              FilledButton.tonal(
                onPressed: () => _launchCardReader(context,
                    (card) => model.advanceChallengeWithCard(task, card)),
                child: const Text('Read card'),
              ),
            ],
          );
        },
      );
    });
  }
}

class DecryptSubPage extends StatelessWidget {
  const DecryptSubPage({Key? key}) : super(key: key);

  Future<void> showDecryptDialog(BuildContext context, Decrypt decrypt) async {
    const duration = Duration(seconds: 5);
    const refreshInterval = Duration(milliseconds: 20);
    int steps = duration.inMilliseconds ~/ refreshInterval.inMilliseconds;
    final countdown =
        RangeStream(steps, 0).interval(refreshInterval).shareValue();
    final sub = countdown.listen((value) {
      if (value == 0) Navigator.pop(context);
    });

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: StreamBuilder(
            stream: countdown,
            builder: (context, snapshot) {
              return Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: (snapshot.data ?? steps) / steps,
                  ),
                ),
              );
            },
          ),
          title: Text(decrypt.name),
          content: switch (decrypt.dataType) {
            MimeType.textUtf8 =>
              Text(utf8.decode(decrypt.data, allowMalformed: true)),
            MimeType.imageSvg => SvgPicture.memory(decrypt.data as Uint8List),
            var t when t.isImage => Image.memory(decrypt.data as Uint8List),
            _ => const Text('Error: Unknown data type'),
          },
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hide'),
            ),
          ],
        );
      },
    );

    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Decrypt>(
        model.decryptTasks,
        finishedTitle: 'Finished',
        emptyView: const EmptyList(
          hint: 'Requests for decryptions.',
        ),
        taskBuilder: (context, task, finished) {
          return TaskTile(
            task: task,
            name: task.info.name,
            desc: statusMessage(task),
            actionChip: EntityChip(name: task.info.group.name),
            approveActions: [
              FilledButton.tonal(
                child: const Text('Decrypt'),
                onPressed: () => model.joinDecrypt(task, agree: true),
              ),
              OutlinedButton(
                child: const Text('Decline'),
                onPressed: () => model.joinDecrypt(task, agree: false),
              )
            ],
            actions: [
              if (finished)
                FilledButton.tonal(
                  onPressed: () => showDecryptDialog(context, task.info),
                  child: const Text('View'),
                )
            ],
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

  Future<({String description, String message})?> _inputMessage() async {
    return showDialog<({String description, String message})?>(
      context: context,
      builder: (context) {
        var description = TextEditingController();
        var message = TextEditingController();

        return AlertDialog(
          title: const Text('Enter message'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context,
                  (description: description.text, message: message.text)),
              child: const Text('Next'),
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: message,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
              ),
            ],
          ),
        );
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

  // TODO: reduce repetition across request methods
  // (_sign, _challenge, _group, _encrypt)

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

  Future<void> _challenge() async {
    final result = await _inputMessage();
    if (result == null) return;

    final group = await _selectGroup(KeyType.signChallenge);
    if (group == null) return;

    try {
      await context
          .read<HomeState>()
          .challenge(result.description, result.message, group);
    } catch (e) {
      showErrorDialog(
        title: 'Challenge request failed',
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
    final result = await _inputMessage();
    if (result == null) return;

    final group = await _selectGroup(KeyType.decrypt); // TODO change
    if (group == null) return;

    try {
      await context
          .read<HomeState>()
          .encrypt(result.description, result.message, group);
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
      ChallengeSubPage(),
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
      FloatingActionButton.extended(
        key: const ValueKey('ChallengeFab'),
        onPressed: _challenge,
        label: const Text('Challenge'),
        icon: const Icon(Icons.add),
      ),
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
