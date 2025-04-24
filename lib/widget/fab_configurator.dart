import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../enums/fab_type.dart';
import '../enums/task_type.dart';
import '../util/actions/challenge_creator.dart';
import '../util/actions/document_signer.dart';
import '../util/actions/encrypt_data.dart';
import '../util/actions/group_creator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../util/actions/task_type_selector.dart';
import '../view_model/app_view_model.dart';

class FabConfigurator extends StatelessWidget {
  final FabType fabType;
  final BuildContext buildContext;

  final AppViewModel? viewModel;
  const FabConfigurator(
      {super.key,
      required this.fabType,
      required this.buildContext,
      this.viewModel});

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
      case FabType.newTaskFab:
        return _buildNewTaskFab(context);
    }
  }

  Widget _buildNewTaskFab(BuildContext context) {
    String key = "NewTaskFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () async {
        TaskType? result = await showTaskTypeDialog(context);

        if (context.mounted) {
          if (result == TaskType.sign) {
            signDocument(context, context);
          } else if (result == TaskType.decrypt) {
            encryptData(context, context);
          } else if (result == TaskType.challenge) {
            createChallenge(context, context);
          }
        }
      },
      label: const Text('New task'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildSignFab(BuildContext context) {
    String key = "SignFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => signDocument(context, buildContext),
      label: const Text('New signature'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildChallengeFab(BuildContext context) {
    String key = "ChallengeFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => createChallenge(context, buildContext),
      label: const Text('New challenge'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildEncryptFab(BuildContext context) {
    String key = "EncryptFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => encryptData(context, buildContext),
      label: const Text('New encryption'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildGroupsFab(BuildContext context) {
    String key = "GroupFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => createGroup(context, buildContext),
      label: const Text('New group'),
      icon: const Icon(Symbols.add),
    );
  }
}
