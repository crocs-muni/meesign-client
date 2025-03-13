import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

void showErrorDialog({
  required BuildContext context,
  required String title,
  required String desc,
}) =>
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Symbols.error),
          title: Text(title),
          content: Text(desc),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
