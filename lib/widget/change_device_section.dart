import 'package:flutter/material.dart';

import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/ui_constants.dart';

class ChangeDeviceSection extends StatelessWidget {
  const ChangeDeviceSection({
    required this.onChangeServer,
    super.key,
    this.showText = true,
    this.centerContent = false,
  });
  final VoidCallback onChangeServer;
  final bool showText;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (showText) ...[
          Text(
            AppLocalizations.of(context).changeServerOrDeviceTitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: SMALL_GAP),
          Text(
            AppLocalizations.of(context).changeServerOrDeviceDescription,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: MEDIUM_GAP),
        ],
        FilledButton.icon(
          onPressed: onChangeServer,
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(AppLocalizations.of(context).changeDeviceButton),
          ),
          icon: const Icon(Icons.sync),
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
