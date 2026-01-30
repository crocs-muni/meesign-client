import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/enums/fab_type.dart';
import 'package:meesign_client/enums/task_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/util/actions/challenge_creator.dart';
import 'package:meesign_client/util/actions/document_signer.dart';
import 'package:meesign_client/util/actions/encrypt_data.dart';
import 'package:meesign_client/util/actions/group_creator.dart';
import 'package:meesign_client/util/actions/task_type_selector.dart';
import 'package:meesign_client/view_model/app_view_model.dart';

class FabConfigurator extends StatelessWidget {
  const FabConfigurator({
    required this.fabType,
    required this.buildContext,
    super.key,
    this.viewModel,
  });
  final FabType fabType;
  final BuildContext buildContext;

  final AppViewModel? viewModel;

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
    const key = 'NewTaskFab';
    return FloatingActionButton.extended(
      key: const ValueKey(key),
      heroTag: key,
      onPressed: () async {
        final result = await showTaskTypeDialog(context);

        if (context.mounted) {
          if (result == TaskType.sign) {
            signDocument(context: context, buildContext: context);
          } else if (result == TaskType.decrypt) {
            encryptData(context: context, buildContext: context);
          } else if (result == TaskType.challenge) {
            createChallenge(context: context, buildContext: context);
          }
        }
      },
      label: const Text('New task'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildSignFab(BuildContext context) {
    const key = 'SignFab';
    return FloatingActionButton.extended(
      key: const ValueKey(key),
      heroTag: key,
      onPressed: () => signDocument(context: context, buildContext: context),
      label: const Text('New signature'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildChallengeFab(BuildContext context) {
    const key = 'ChallengeFab';
    return FloatingActionButton.extended(
      key: const ValueKey(key),
      heroTag: key,
      onPressed: () => createChallenge(context: context, buildContext: context),
      label: const Text('New challenge'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildEncryptFab(BuildContext context) {
    const key = 'EncryptFab';
    return FloatingActionButton.extended(
      key: const ValueKey(key),
      heroTag: key,
      onPressed: () => encryptData(context: context, buildContext: context),
      label: const Text('New encryption'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildGroupsFab(BuildContext context) {
    const key = 'GroupFab';
    return FloatingActionButton.extended(
      key: const ValueKey(key),
      heroTag: key,
      onPressed: () => createGroup(context, buildContext),
      label: Text(AppLocalizations.of(context).newGroup),
      icon: const Icon(Symbols.add),
    );
  }
}
