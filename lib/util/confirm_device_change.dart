import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
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
    'Confirm deletion',
    'Are you sure you want to delete this device?',
    'Delete',
    () {
      confirmDeviceChange(context, mounted, deleteData: true);
    },
  );
}

Future<bool?> showChangeServerDialog(BuildContext context, bool mounted) {
  return showConfirmationDialog(
    context,
    'Confirm profile change',
    'Are you sure you want to change server or device?',
    'Confirm',
    () {
      confirmDeviceChange(context, mounted, deleteData: false);
    },
  );
}
