import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../enums/task_type.dart';
import '../../pages/new_group_page.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/tabs_view_model.dart';
import '../../widget/error_dialog.dart';

// TODO: reduce repetition across request methods
// (_sign, _challenge, _group, _encrypt)
Future<void> createGroup(BuildContext context, BuildContext buildContext,
    {TaskType? groupType}) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();
  final tabsState = buildContext.read<TabsViewModel>();

  tabsState.setNewGroupPageActive(true);

  final res = await Navigator.of(context, rootNavigator: false).push(
    MaterialPageRoute(
        builder: (context) => NewGroupPage(
              initialGroupType: groupType,
            )),
  ) as Group?;

  tabsState.setNewGroupPageActive(false);
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
