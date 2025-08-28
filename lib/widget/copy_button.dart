import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/arb/app_localizations.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({super.key, required this.textToCopy});
  final String textToCopy;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          final data = textToCopy;
          Clipboard.setData(ClipboardData(text: data));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied to clipboard!'),
            ),
          );
        },
        label: Text(AppLocalizations.of(context).copy),
        icon: Icon(Icons.copy));
  }
}
