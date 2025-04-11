import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../enums/data_input_type.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/data_input_dialog.dart';
import '../../widget/error_dialog.dart';
import 'select_group.dart';

// TODO: reduce repetition across request methods
// (_sign, _challenge, _group, _encrypt)
Future<void> encryptData(
    BuildContext context, BuildContext buildContext) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();

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

  Group? group;
  if (buildContext.mounted) {
    group = await selectGroup(KeyType.decrypt, buildContext); // TODO change
  }

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
