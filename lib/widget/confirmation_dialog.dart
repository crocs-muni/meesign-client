import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context, String title,
    String description, String confirmButtonText, Function onConfirm) {
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(dialogContext, true);
              },
              child: Text(confirmButtonText),
            )
          ],
        );
      });
}
