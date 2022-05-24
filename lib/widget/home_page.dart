import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../model/mpc_model.dart';
import '../model/tasks.dart';
import '../routes.dart';
import 'dismissible.dart';

class ProgressCheck extends StatelessWidget {
  const ProgressCheck(this.value, {Key? key}) : super(key: key);

  final double? value;

  @override
  Widget build(BuildContext context) {
    if (value == 1.0) return const Icon(Icons.check, color: Colors.green);
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 2.0,
      ),
    );
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

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      if (model.files.isEmpty) {
        return const EmptyList(hint: 'Add new group first.');
      }

      return ListView.separated(
        itemCount: model.files.length,
        itemBuilder: (context, i) {
          final file = model.files[i];
          return Deletable(
            dismissibleKey: ObjectKey(file),
            child: ListTile(
              title: Text(file.basename),
              trailing: ProgressCheck(file.isFinished ? 1.0 : null),
              onTap: () {
                OpenFile.open(file.path);
              },
            ),
            confirmTitle: 'Do you really want to delete ${file.basename}?',
            onDeleted: (_) {
              // FIXME: remove the actual file
              model.files.remove(file);
            },
          );
        },
        separatorBuilder: (context, i) => const Divider(
          height: 1,
        ),
      );
    });
  }
}

String _nameInitials(String name) => name
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w.characters.first.toUpperCase())
    .join();

class GroupsSubPage extends StatelessWidget {
  const GroupsSubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      if (model.groups.isEmpty) {
        return const EmptyList(hint: 'Try creating a new group.');
      }

      return ListView.builder(
          itemCount: model.groups.length,
          itemBuilder: (context, i) {
            final group = model.groups[i];

            return ListTile(
              title: Text(group.name),
              subtitle: Text('Threshold: '
                  '${group.threshold} out of ${group.members.length}'),
              onTap: () {},
              leading: CircleAvatar(
                child: Text(
                  _nameInitials(group.name),
                ),
              ),
              trailing: ProgressCheck(group.isFinished ? 1.0 : null),
            );
          });
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  int _nSignReqs = 0, _nGroupReqs = 0;

  @override
  void initState() {
    super.initState();
    // TODO: when to cancel it?
    MpcModel model = context.read<MpcModel>();
    model.groupRequests.listen(_showGroupRequest);
    model.signRequests.listen(_showSignRequest);
  }

  void _showGroupRequest(GroupTask task) {
    // FIXME: rebuilds whole tree?
    setState(() {
      ++_nGroupReqs;
    });
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('Do you want to join group ${task.group.name}?'),
        leading: const Icon(Icons.group_add),
        actions: [
          TextButton(
            child: const Text('JOIN'),
            onPressed: () {
              setState(() {
                --_nGroupReqs;
              });
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              context.read<MpcModel>().approveTask(task, agree: true);
            },
          ),
          TextButton(
            child: const Text('DECLINE'),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              context.read<MpcModel>().approveTask(task, agree: false);
            },
          ),
        ],
      ),
    );
  }

  void _showSignRequest(SignTask task) {
    setState(() {
      ++_nSignReqs;
    });
    SignedFile file = task.file;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('Group ${file.group.name} asks you '
            'to sign ${file.basename}.'),
        leading: const Icon(Icons.lock),
        actions: [
          TextButton(
            child: const Text('VIEW'),
            onPressed: () {
              OpenFile.open(file.path);
            },
          ),
          TextButton(
            child: const Text('SIGN'),
            onPressed: () {
              setState(() {
                --_nSignReqs;
              });
              // FIXME: add one handler for both approve, reject
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              context.read<MpcModel>().approveTask(task, agree: true);
            },
          ),
          TextButton(
            child: const Text('IGNORE'),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              // FIXME: decline?
            },
          ),
        ],
      ),
    );
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

    final model = context.read<MpcModel>();
    model.sign(path, group);
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
      onPressed: () {
        Navigator.pushNamed(context, Routes.newGroup);
      },
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
                    child: Text(_nameInitials(name)),
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
            icon: Badge(
              badgeContent: Text('$_nSignReqs'),
              child: Icon(Icons.lock),
              showBadge: _nSignReqs != 0,
            ),
            label: 'Signing',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              badgeContent: Text('$_nGroupReqs'),
              child: Icon(Icons.people),
              showBadge: _nGroupReqs != 0,
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
