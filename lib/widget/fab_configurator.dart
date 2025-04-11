import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../enums/data_input_type.dart';
import '../enums/fab_type.dart';
import '../util/group_creator.dart';
import '../view_model/app_view_model.dart';
import 'data_input_dialog.dart';
import 'error_dialog.dart';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

class FabConfigurator extends StatelessWidget {
  final FabType fabType;
  final BuildContext buildContext;
  const FabConfigurator(
      {super.key, required this.fabType, required this.buildContext});

  @override
  Widget build(BuildContext context) {
    switch (fabType) {
      case FabType.signFab:
        return _buildSignFab(context);
      case FabType.challengeFab:
        return _buildChallengeFab(context);
      case FabType.decryptFab:
        return _buildEncryptFab(context);
      case FabType.groupFab:
        return _buildGroupsFab(context);
    }
  }

  AppViewModel _syncGetHomeState(BuildContext context) =>
      buildContext.read<AppViewModel>();

  Widget _buildSignFab(BuildContext context) {
    String key = "SignFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => _sign(context),
      label: const Text('Sign'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildChallengeFab(BuildContext context) {
    String key = "ChallengeFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => _challenge(context),
      label: const Text('Challenge'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildEncryptFab(BuildContext context) {
    String key = "EncryptFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => _encrypt(context),
      label: const Text('Encrypt'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildGroupsFab(BuildContext context) {
    String key = "GroupFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => createGroup(context, buildContext),
      label: const Text('New'),
      icon: const Icon(Symbols.add),
    );
  }

  // TODO: reduce repetition across request methods
  // (_sign, _challenge, _group, _encrypt)

  Future<void> _encrypt(BuildContext context) async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(buildContext);

    final result = await showDialog<(String, MimeType, Uint8List)?>(
      context: buildContext,
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

    if (data.length > AppViewModel.maxDataSize) {
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'Data too large',
          desc: 'Please select a smaller image or enter a shorter text.',
        );
      }
      return;
    }

    final group = await _selectGroup(KeyType.decrypt); // TODO change
    if (group == null) return;

    try {
      if (buildContext.mounted) {
        await homeState.encrypt(description, mimeType, data, group);
      }
    } catch (e) {
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'Decryption request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }

  Future<void> _challenge(BuildContext context) async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(buildContext);

    final result = await showDialog<(String, MimeType, Uint8List)?>(
      context: buildContext,
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
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'Challenge request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }

  Future<void> _sign(BuildContext context) async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(buildContext);

    final file = await _pickPdfFile();
    if (file == null) return;

    if (await file.length() > AppViewModel.maxDataSize) {
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'File too large',
          desc: 'Please select a smaller one.',
        );
      }
      return;
    }

    final group = await _selectGroup(KeyType.signPdf);
    if (group == null) return;

    try {
      await homeState.sign(file, group);
    } catch (e) {
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'Sign request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }

  Future<Group?> _selectGroup(keyType) async {
    final state = buildContext.read<AppViewModel>();
    final groups = state.groupTasks
        .where((task) =>
            task.state == TaskState.finished &&
            task.info.keyType == keyType &&
            (state.showArchived || !task.archived))
        .map((task) => task.info);

    return showDialog<Group?>(
      context: buildContext,
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
}
