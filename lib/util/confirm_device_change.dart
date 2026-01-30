import 'package:flutter/cupertino.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/widget/confirmation_dialog.dart';
import 'package:provider/provider.dart';

void confirmDeviceChange(
  BuildContext context, {
  required bool mounted,
  bool deleteData = false,
}) {
  final appContainer = context.read<AppContainer>()
    ..recreate(deleteData: deleteData);

  if (deleteData) {
    appContainer.settingsController.deleteHostData();
  }
}

Future<bool?> showDeleteDialog(BuildContext context, {required bool mounted}) {
  return showConfirmationDialog(
    context,
    AppLocalizations.of(context).confirmDeletion,
    AppLocalizations.of(context).confirmDeviceDeletion,
    AppLocalizations.of(context).delete,
    () {
      confirmDeviceChange(context, mounted: mounted, deleteData: true);
    },
  );
}

Future<bool?> showChangeServerDialog(
  BuildContext context, {
  required bool mounted,
}) {
  return showConfirmationDialog(
    context,
    AppLocalizations.of(context).confirmProfileChange,
    AppLocalizations.of(context).confirmServerOrDeviceChange,
    AppLocalizations.of(context).confirm,
    () {
      confirmDeviceChange(context, mounted: mounted);
    },
  );
}
