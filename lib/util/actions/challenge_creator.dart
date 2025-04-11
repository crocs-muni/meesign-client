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
Future<void> createChallenge(
    BuildContext context, BuildContext buildContext) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();

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

  Group? group;
  if (buildContext.mounted) {
    group = await selectGroup(KeyType.signChallenge, buildContext);
  }

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
