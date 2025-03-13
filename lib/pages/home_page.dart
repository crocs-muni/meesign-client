import 'dart:io';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../enums/data_input_type.dart';
import '../routes.dart';
import '../theme.dart';
import '../util/chars.dart';
import '../widget/counter_badge.dart';
import '../ui/device_page.dart';
import '../ui/home_state.dart';
import '../widget/data_input_dialog.dart';
import 'challenge_sub_page.dart';
import 'decrypt_sub_page.dart';
import 'groups_sub_page.dart';
import 'signing_sub_page.dart';

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

  HomeState _syncGetHomeState(BuildContext context) =>
      context.read<HomeState>();

  Future<void> _sign() async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(context);

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
      await homeState.sign(file, group);
    } catch (e) {
      showErrorDialog(
        title: 'Sign request failed',
        desc: 'Please try again.',
      );
      rethrow;
    }
  }

  Future<void> _challenge() async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(context);

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

      await homeState.challenge(description, data, group);
    } catch (e) {
      showErrorDialog(
        title: 'Challenge request failed',
        desc: 'Please try again.',
      );
      rethrow;
    }
  }

  Future<void> _group() async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(context);

    final res = await Navigator.pushNamed(context, Routes.newGroup) as Group?;
    if (res == null) return;

    try {
      if (context.mounted) {
        await homeState.addGroup(res.name, res.members, res.threshold,
            res.protocol, res.keyType, res.note);
      }
    } catch (e) {
      showErrorDialog(
        title: 'Group request failed',
        desc: 'Please try again',
      );
      rethrow;
    }
  }

  Future<void> _encrypt() async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(context);

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
      if (context.mounted) {
        await homeState.encrypt(description, mimeType, data, group);
      }
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
                PopupMenuItem(
                  onTap: () => Navigator.pushNamed(context, Routes.about),
                  child: const Text('About'),
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
