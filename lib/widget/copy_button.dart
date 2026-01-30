import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:meesign_client/l10n/arb/app_localizations.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({required this.textToCopy, super.key});
  final String textToCopy;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        final data = textToCopy;
        Clipboard.setData(ClipboardData(text: data));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard!'),
          ),
        );
      },
      label: Text(AppLocalizations.of(context).copy),
      icon: const Icon(Icons.copy),
    );
  }
}
