import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../pages/new_group_page.dart';
import '../view_model/app_view_model.dart';
import '../widget/error_dialog.dart';

Future<void> createGroup(
    BuildContext context, BuildContext buildContext) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();

  final res = await Navigator.of(context, rootNavigator: false).push(
    MaterialPageRoute(builder: (context) => NewGroupPage()),
  ) as Group?;

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
