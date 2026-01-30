import 'package:flutter/material.dart';
import 'package:meesign_client/enums/task_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/new_group_page.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/error_dialog.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

Future<bool> createGroup(
  BuildContext context,
  BuildContext buildContext, {
  TaskType? groupType,
  Group? groupTemplate,
}) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();
  final tabsState = buildContext.read<TabsViewModel>()
    ..newGroupPageActive = true;

  final res = await Navigator.of(context).push(
    MaterialPageRoute<Group?>(
      builder: (context) => NewGroupPage(
        initialGroupType: groupType,
        templateGroup: groupTemplate,
      ),
    ),
  );

  tabsState.newGroupPageActive = false;
  if (res == null) return false;

  try {
    if (buildContext.mounted) {
      await homeState.addGroup(
        res.name,
        res.members,
        res.threshold,
        res.protocol,
        res.keyType,
        res.note,
      );
    }
    return true;
  } catch (e) {
    if (buildContext.mounted) {
      showErrorDialog(
        context: buildContext,
        title: AppLocalizations.of(context).groupCreationFailed,
        desc: AppLocalizations.of(context).pleaseTryAgain,
      );
    }
    rethrow;
  }
}
