import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../l10n/arb/app_localizations.dart';
import '../widget/confirmation_dialog.dart';

void confirmDeviceChange(BuildContext context, bool mounted,
    {bool deleteData = false}) {
  final appContainer = context.read<AppContainer>();

  appContainer.recreate(deleteData: deleteData);

  if (deleteData) {
    appContainer.settingsController.deleteHostData();
  }
}

Future<bool?> showDeleteDialog(BuildContext context, bool mounted) {
  return showConfirmationDialog(
    context,
    AppLocalizations.of(context).confirmDeletion,
    AppLocalizations.of(context).confirmDeviceDeletion,
    AppLocalizations.of(context).delete,
    () {
      confirmDeviceChange(context, mounted, deleteData: true);
    },
  );
}

Future<bool?> showChangeServerDialog(BuildContext context, bool mounted) {
  return showConfirmationDialog(
    context,
    AppLocalizations.of(context).confirmProfileChange,
    AppLocalizations.of(context).confirmServerOrDeviceChange,
    AppLocalizations.of(context).confirm,
    () {
      confirmDeviceChange(context, mounted, deleteData: false);
    },
  );
}
