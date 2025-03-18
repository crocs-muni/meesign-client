import 'package:flutter/material.dart';

void showConfirmationDialog(BuildContext context, String title,
    String description, String confirmButtonText, Function onConfirm) {
  showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(dialogContext);
              },
              child: Text(confirmButtonText),
            )
          ],
        );
      });
}
