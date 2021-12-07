import 'package:animations/animations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
import 'package:provider/provider.dart';

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
  const EmptyList({Key? key}) : super(key: key);

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
          const Text('Nothing here yet.'),
        ],
      ),
    );
  }
}

class SigningSubPage extends StatelessWidget {
  const SigningSubPage({Key? key}) : super(key: key);

  Future<FilePickerResult?> _pickPdfFile() async =>
      FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

  void beginSign() async {
    await _pickPdfFile();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      if (model.files.isEmpty) return const EmptyList();

      return ListView.separated(
        itemCount: model.files.length,
        itemBuilder: (context, i) {
          final file = model.files[i];
          return ListTile(
            title: Text(file.path),
            trailing: ProgressCheck(file.isFinished ? 1.0 : null),
            onTap: () {},
          );
        },
        separatorBuilder: (context, i) => const Divider(),
      );
    });
  }
}

class GroupsSubPage extends StatelessWidget {
  const GroupsSubPage({Key? key}) : super(key: key);

  String _groupInitials(Group group) {
    return group.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MpcModel>(builder: (context, model, child) {
      if (model.groups.isEmpty) return const EmptyList();

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
                  _groupInitials(group),
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

  void _showSignRequest(String group, String file) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('Group $group asks you to sign $file.'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              // TODO: do sign
            },
            child: const Text('SIGN'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('IGNORE'),
          ),
        ],
        leading: const Icon(Icons.warning),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      SigningSubPage(),
      GroupsSubPage(),
    ];

    final signFab = FloatingActionButton.extended(
      key: const ValueKey('SignFab'),
      onPressed: (pages[0] as SigningSubPage).beginSign,
      label: const Text('Sign'),
      icon: const Icon(Icons.add),
    );
    final groupFab = FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/new_group');
      },
      label: const Text('New'),
      icon: const Icon(Icons.add),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MPC Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.pushNamed(context, '/qr_identity');
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Signing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Groups',
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.amber,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }
}
