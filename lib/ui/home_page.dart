import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_card.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_container.dart';
import '../card/card.dart';
import '../routes.dart';
import '../theme.dart';
import '../util/chars.dart';
import '../util/platform.dart';
import '../widget/counter_badge.dart';
import '../widget/dismissible.dart';
import '../widget/empty_list.dart';
import '../widget/entity_chip.dart';
import 'card_reader_page.dart';
import 'device_page.dart';
import 'group_page.dart';
import 'home_state.dart';

class TaskStateIndicator extends StatelessWidget {
  final Task task;

  const TaskStateIndicator(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return switch (task.state) {
      TaskState.created => const Icon(Symbols.arrow_drop_down),
      TaskState.running => SizedBox(
          height: 24,
          width: 24,
          // TODO: add animation
          child: CircularProgressIndicator(
            value: task.round / task.nRounds,
            strokeWidth: 2.0,
          ),
        ),
      TaskState.needsCard => const Icon(Symbols.payment),
      TaskState.finished => Icon(
          Symbols.check,
          color: Theme.of(context).extension<CustomColors>()!.success,
        ),
      TaskState.failed => Icon(
          switch (task.error) {
            TaskError.rejected => Symbols.block,
            _ => Symbols.error_outline,
          },
          color: Theme.of(context).colorScheme.error,
        ),
    };
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
  return switch (task.state) {
    TaskState.created => 'Waiting for confirmation '
        '${task.approved ? 'by others' : ''}',
    TaskState.running => 'Working on task',
    TaskState.needsCard => 'Needs card to continue',
    _ => null,
  };
}

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

void _openFile(String path) {
  if (Platform.isLinux) {
    launchUrl(Uri.file(path));
  } else {
    // FIXME: try to avoid open_file package,
    // it seems to be of low quality
    OpenFilex.open(path);
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

class TaskTile<T> extends StatelessWidget {
  final Task<T> task;
  final String name;
  final String? desc;
  final Widget? leading, trailing;
  final Widget? actionChip;
  final List<Widget> approveActions, cardActions, actions;
  final List<Widget> children;
  final void Function(bool)? onArchiveChange;

  const TaskTile({
    super.key,
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
    this.onArchiveChange,
  });

  @override
  Widget build(BuildContext context) {
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

    return Deletable(
      dismissibleKey: ObjectKey(task),
      icon: task.archived ? Symbols.unarchive : Symbols.archive,
      color: task.archived
          ? Theme.of(context).colorScheme.surfaceVariant
          : Theme.of(context).extension<CustomColors>()!.successContainer!,
      onDeleted: (_) {
        if (onArchiveChange != null) onArchiveChange!(!task.archived);
      },
      child: ExpansionTile(
        title: Text(name),
        subtitle: desc != null ? Text(desc) : null,
        initiallyExpanded: !task.archived &&
            task.state != TaskState.finished &&
            task.state != TaskState.failed,
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
      ),
    );
  }
}

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<File>(
        model.signTasks,
        emptyView: EmptyList(
          hint: model.hasGroup(KeyType.signPdf)
              ? 'Try signing a PDF file.'
              : 'Start by creating a group for signing.',
        ),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          return TaskTile(
            task: task,
            name: task.info.basename,
            actionChip: GroupChip(group: task.info.group),
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
            onArchiveChange: (archive) =>
                model.archiveTask(task, archive: archive),
          );
        },
      );
    });
  }
}

class GroupsSubPage extends StatelessWidget {
  const GroupsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Group>(
        model.groupTasks,
        emptyView: const EmptyList(
          hint: 'Try creating a new group.',
        ),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          final group = task.info;
          final members = group.members;
          final thisMember = members.firstWhere(
            (m) => m.device.id == model.device?.id,
          );

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
              if (CardManager.platformSupported &&
                  group.protocol.cardSupport &&
                  thisMember.shares == 1)
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
            actions: [
              FilledButton.tonal(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => GroupPage(
                        group: group,
                      ),
                    ),
                  );
                },
                child: const Text('View'),
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
              Container(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var m in members) DeviceChip(device: m.device)
                  ],
                ),
              ),
            ],
            onArchiveChange: (archive) =>
                model.archiveTask(task, archive: archive),
          );
        },
      );
    });
  }
}

enum DataView { hex, text }

class ChallengeSubPage extends StatelessWidget {
  const ChallengeSubPage({super.key});

  Future<void> showChallengeDialog(
    BuildContext context,
    Challenge challenge,
  ) async {
    final dataHex = hex.encode(challenge.data);
    String? dataStr;
    try {
      dataStr = utf8.decode(
        challenge.data,
        allowMalformed: false,
      );
    } on FormatException {
      dataStr = null;
    }

    await showDialog(
      context: context,
      builder: (context) {
        final supportedViews = {
          if (dataStr != null) DataView.text,
          DataView.hex,
        };
        DataView view = supportedViews.first;

        return AlertDialog(
          icon: const Icon(Symbols.quiz),
          title: Text(challenge.name),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (supportedViews.length > 1) ...[
                      SegmentedButton<DataView>(
                        segments: [
                          for (final view in supportedViews)
                            ButtonSegment(
                              value: view,
                              label: Text(view.name.capitalize()),
                            ),
                        ],
                        selected: {view},
                        onSelectionChanged: (newView) {
                          setState(() => view = newView.first);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Center(
                      child: switch (view) {
                        DataView.hex => Text(
                            dataHex,
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        DataView.text => Text(
                            dataStr!,
                          ),
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hide'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, model, child) {
      return buildTaskListView<Challenge>(
        model.challengeTasks,
        emptyView: EmptyList(
          hint: model.hasGroup(KeyType.signChallenge)
              ? 'Try creating a new challenge.'
              : 'Start by creating a group for challenges.',
        ),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          return TaskTile(
            task: task,
            name: task.info.name,
            actionChip: GroupChip(group: task.info.group),
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
            actions: [
              FilledButton.tonal(
                onPressed: () => showChallengeDialog(context, task.info),
                child: const Text('View'),
              )
            ],
            onArchiveChange: (archive) =>
                model.archiveTask(task, archive: archive),
          );
        },
      );
    });
  }
}

class DecryptSubPage extends StatelessWidget {
  const DecryptSubPage({super.key});

  static Future<void> _shareDecrypt(Decrypt decrypt) async {
    final file = XFile.fromData(
      decrypt.data as Uint8List,
      name: decrypt.name,
      mimeType: decrypt.dataType.value,
    );

    if (PlatformGroup.isDesktop) {
      final ext = extensionFromMime(decrypt.dataType.value);
      final loc = await getSaveLocation(
        suggestedName: '${decrypt.name}.$ext',
      );
      if (loc != null) {
        file.saveTo(loc.path);
      }
    }
    if (PlatformGroup.isMobile) {
      await Share.shareXFiles([file], text: decrypt.name);
    }
  }

  Future<void> showDecryptDialog(BuildContext context, Decrypt decrypt) async {
    const duration = Duration(seconds: 5);
    const refreshInterval = Duration(milliseconds: 20);
    int steps = duration.inMilliseconds ~/ refreshInterval.inMilliseconds;
    final countdown =
        Stream.periodic(refreshInterval, (i) => max(0, steps - i));
    final countdownSubject = BehaviorSubject<int>();
    final sub = countdown.listen((value) {
      countdownSubject.add(value);
      if (value == 0) Navigator.pop(context);
    });

    final text = decrypt.dataType == MimeType.textUtf8
        ? utf8.decode(decrypt.data, allowMalformed: true)
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: StreamBuilder(
            stream: countdownSubject.stream,
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
            MimeType.textUtf8 => Text(text!, textAlign: TextAlign.center),
            MimeType.imageSvg => SvgPicture.memory(decrypt.data as Uint8List),
            var t when t.isImage => Image.memory(decrypt.data as Uint8List),
            _ => const Text(
                'Error: Unknown data type',
                textAlign: TextAlign.center,
              ),
          },
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            switch (decrypt.dataType) {
              MimeType.textUtf8 => IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text!));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied!')),
                    );
                  },
                  icon: const Icon(Symbols.content_copy),
                ),
              var t when t.isImage => IconButton(
                  onPressed: () async {
                    sub.pause();
                    await _shareDecrypt(decrypt);
                    sub.resume();
                  },
                  icon: Icon(PlatformGroup.isMobile
                      ? Symbols.share
                      : Symbols.save_alt),
                ),
              _ => const SizedBox(),
            },
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
        emptyView: EmptyList(
          hint: model.hasGroup(KeyType.decrypt)
              ? 'Try encrypting some data.'
              : 'Start by creating a group for decryption.',
        ),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          return TaskTile(
            task: task,
            name: task.info.name,
            desc: statusMessage(task),
            actionChip: GroupChip(group: task.info.group),
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
              if (task.state == TaskState.finished)
                FilledButton.tonal(
                  onPressed: () => showDecryptDialog(context, task.info),
                  child: const Text('View'),
                )
            ],
            onArchiveChange: (archive) =>
                model.archiveTask(task, archive: archive),
          );
        },
      );
    });
  }
}

enum DataInputType { image, text }

class DataInputDialog extends StatefulWidget {
  final String title;
  final Set<DataInputType> dataInputTypes;
  final DataInputType? defaultDataInputType;

  DataInputDialog({
    super.key,
    this.title = 'Enter input',
    required this.dataInputTypes,
    this.defaultDataInputType,
  }) {
    assert(dataInputTypes.isNotEmpty);
    if (defaultDataInputType != null) {
      assert(dataInputTypes.contains(defaultDataInputType));
    }
  }

  @override
  State<DataInputDialog> createState() => _DataInputDialogState();
}

class _DataInputDialogState extends State<DataInputDialog> {
  final _description = TextEditingController();
  late DataInputType _dataInputType;

  final _message = TextEditingController();

  Uint8List? _image;
  MimeType? _imageMimeType;

  Future<void> _selectImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    final header =
        bytes.sublist(0, min(defaultMagicNumbersMaxLength, bytes.length));
    final mimeTypeStr = lookupMimeType(file.path, headerBytes: header);

    setState(() {
      _image = bytes;
      _imageMimeType = mimeTypeStr != null ? MimeType(mimeTypeStr) : null;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    final (mimeType, data) = switch (_dataInputType) {
      DataInputType.text => (MimeType.textUtf8, utf8.encode(_message.text)),
      DataInputType.image => (_imageMimeType, _image),
    };
    final description = _description.text;

    // TODO: disable ok button instead
    if (description.isEmpty || mimeType == null || data == null) return;

    Navigator.pop(context, (description, mimeType, data));
  }

  @override
  void initState() {
    super.initState();
    _dataInputType = widget.defaultDataInputType ?? widget.dataInputTypes.first;
  }

  @override
  void didUpdateWidget(covariant DataInputDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dataInputType = widget.defaultDataInputType ?? widget.dataInputTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return AlertDialog(
      title: Text(widget.title),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleOk,
          child: const Text('OK'),
        )
      ],
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _description,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<DataInputType>(
            selected: {_dataInputType},
            showSelectedIcon: false,
            onSelectionChanged: (values) {
              setState(() {
                _dataInputType = values.first;
              });
            },
            segments: [
              for (final type in widget.dataInputTypes)
                ButtonSegment<DataInputType>(
                  value: type,
                  icon: Icon(
                    switch (type) {
                      DataInputType.text => Symbols.description,
                      DataInputType.image => Symbols.image,
                    },
                    fill: _dataInputType == type ? 1 : 0,
                  ),
                  label: Text(type.name.capitalize()),
                ),
            ],
          ),
          const SizedBox(height: 16),
          switch (_dataInputType) {
            DataInputType.text => TextField(
                controller: _message,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
              ),
            DataInputType.image => image == null
                ? OutlinedButton(
                    onPressed: _selectImage,
                    child: const Text('Select'),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      _imageMimeType == MimeType.imageSvg
                          ? SvgPicture.memory(image)
                          : Image.memory(image),
                      Positioned.fill(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: _selectImage,
                          ),
                        ),
                      ),
                    ],
                  ),
          },
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppContainer>().session!;
    return ChangeNotifierProvider(
      create: (context) => HomeState(
        session.user,
        session.deviceRepository,
        session.groupRepository,
        session.fileRepository,
        session.challengeRepository,
        session.decryptRepository,
      ),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _index = 0;

  Future<Group?> _selectGroup(keyType) async {
    final state = context.read<HomeState>();
    final groups = state.groupTasks
        .where((task) =>
            task.state == TaskState.finished &&
            task.info.keyType == keyType &&
            (state.showArchived || !task.archived))
        .map((task) => task.info);

    return showDialog<Group?>(
      context: context,
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
            icon: const Icon(Symbols.error),
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

    if (await file.length() > HomeState.maxDataSize) {
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
    final result = await showDialog<(String, MimeType, Uint8List)?>(
      context: context,
      builder: (context) {
        return DataInputDialog(
          title: 'Enter challenge',
          dataInputTypes: const {DataInputType.text},
        );
      },
    );
    if (result == null) return;

    final group = await _selectGroup(KeyType.signChallenge);
    if (group == null) return;

    try {
      final (description, _, data) = result;
      await context.read<HomeState>().challenge(description, data, group);
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
      await context.read<HomeState>().addGroup(res.name, res.members,
          res.threshold, res.protocol, res.keyType, res.note);
    } catch (e) {
      showErrorDialog(
        title: 'Group request failed',
        desc: 'Please try again',
      );
      rethrow;
    }
  }

  Future<void> _encrypt() async {
    final result = await showDialog<(String, MimeType, Uint8List)?>(
      context: context,
      builder: (context) {
        return DataInputDialog(
          title: 'Enter message',
          dataInputTypes: const {DataInputType.text, DataInputType.image},
          defaultDataInputType: DataInputType.text,
        );
      },
    );
    if (result == null) return;
    final (description, mimeType, data) = result;

    if (data.length > HomeState.maxDataSize) {
      showErrorDialog(
        title: 'Data too large',
        desc: 'Please select a smaller image or enter a shorter text.',
      );
      return;
    }

    final group = await _selectGroup(KeyType.decrypt); // TODO change
    if (group == null) return;

    try {
      await context
          .read<HomeState>()
          .encrypt(description, mimeType, data, group);
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
        icon: const Icon(Symbols.add),
      ),
      FloatingActionButton.extended(
        key: const ValueKey('ChallengeFab'),
        onPressed: _challenge,
        label: const Text('Challenge'),
        icon: const Icon(Symbols.add),
      ),
      FloatingActionButton.extended(
        key: const ValueKey('EncryptFab'),
        onPressed: _encrypt,
        label: const Text('Encrypt'),
        icon: const Icon(Symbols.add),
      ),
      FloatingActionButton.extended(
        onPressed: _group,
        label: const Text('New'),
        icon: const Icon(Symbols.add),
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
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    final device = model.device;
                    if (device == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            DevicePage(device: device),
                      ),
                    );
                  },
                  icon: AnimatedBuilder(
                    animation:
                        context.read<AppContainer>().session!.sync.subscribed,
                    builder: (context, child) {
                      final session = context.read<AppContainer>().session!;
                      return Badge(
                        backgroundColor: session.sync.subscribed.value
                            ? Theme.of(context)
                                .extension<CustomColors>()!
                                .success
                            : Theme.of(context).colorScheme.error,
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
          // TODO: migrate to MenuAnchor?
          Consumer<HomeState>(builder: (context, model, child) {
            return PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
                CheckedPopupMenuItem<void>(
                  checked: model.showArchived,
                  onTap: () => model.showArchived = !model.showArchived,
                  child: const Text('Archived'),
                ),
              ],
            );
          }),
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
              child: Icon(Symbols.draw, fill: _index == 0 ? 1 : 0),
            ),
            label: 'Signing',
          ),
          NavigationDestination(
            icon: CounterBadge(
              stream: context.watch<HomeState>().nChallengeReqs,
              child: Icon(Symbols.quiz, fill: _index == 1 ? 1 : 0),
            ),
            label: 'Challenge',
          ),
          NavigationDestination(
              icon: CounterBadge(
                stream: context.watch<HomeState>().nDecryptReqs,
                child: Icon(Symbols.key, fill: _index == 2 ? 1 : 0),
              ),
              label: 'Decrypt'),
          NavigationDestination(
            icon: CounterBadge(
              stream: context.watch<HomeState>().nGroupReqs,
              child: Icon(Symbols.group, fill: _index == 3 ? 1 : 0),
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
