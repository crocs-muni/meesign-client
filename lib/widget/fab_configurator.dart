import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../enums/data_input_type.dart';
import '../routes.dart';
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
  final int index;
  final BuildContext buildContext;
  const FabConfigurator(
      {super.key, required this.index, required this.buildContext});

  @override
  Widget build(BuildContext context) {
    try {
      return fabs[index];
    } on RangeError {
      return const SizedBox();
    }
  }

  AppViewModel _syncGetHomeState(BuildContext context) =>
      buildContext.read<AppViewModel>();

  List<FloatingActionButton> get fabs => [
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

  // TODO: reduce repetition across request methods
  // (_sign, _challenge, _group, _encrypt)

  Future<void> _encrypt() async {
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

  Future<void> _group() async {
    // Retrieve the HomeState instance before the async gap
    final homeState = _syncGetHomeState(buildContext);

    final res =
        await Navigator.pushNamed(buildContext, Routes.newGroup) as Group?;
    if (res == null) return;

    try {
      if (buildContext.mounted) {
        await homeState.addGroup(res.name, res.members, res.threshold,
            res.protocol, res.keyType, res.note);
      }
    } catch (e) {
      if (buildContext.mounted) {
        showErrorDialog(
          context: buildContext,
          title: 'Group request failed',
          desc: 'Please try again',
        );
      }
      rethrow;
    }
  }

  Future<void> _challenge() async {
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

  Future<void> _sign() async {
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
