import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../enums/fab_type.dart';
import '../util/actions/challenge_creator.dart';
import '../util/actions/document_signer.dart';
import '../util/actions/encrypt_data.dart';
import '../util/actions/group_creator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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

  Widget _buildSignFab(BuildContext context) {
    String key = "SignFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => signDocument(context, buildContext),
      label: const Text('Sign'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildChallengeFab(BuildContext context) {
    String key = "ChallengeFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => createChallenge(context, buildContext),
      label: const Text('Challenge'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildEncryptFab(BuildContext context) {
    String key = "EncryptFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => encryptData(context, buildContext),
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
}
