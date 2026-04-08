import 'package:flutter/material.dart';

import 'package:meesign_client/l10n/arb/app_localizations.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context,
  String title,
  String description,
  String confirmButtonText,
  Function onConfirm,
) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(confirmButtonText),
          ),
        ],
      );
    },
  );
}
