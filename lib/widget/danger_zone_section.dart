import 'package:flutter/material.dart';

import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/register_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/confirm_device_change.dart';
import 'package:meesign_client/util/fade_black_page_transition.dart';

class DangerZoneSection extends StatefulWidget {
  const DangerZoneSection({
    super.key,
    this.showText = true,
    this.centerContent = false,
  });
  final bool showText;
  final bool centerContent;

  @override
  State<DangerZoneSection> createState() => _DangerZoneSectionState();
}

class _DangerZoneSectionState extends State<DangerZoneSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.centerContent
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (widget.showText) ...[
          Text(
            AppLocalizations.of(context).dangerZoneTitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: SMALL_GAP),
          Text(
            AppLocalizations.of(context).dangerZoneDescription,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: MEDIUM_GAP),
        ],
        FilledButton.icon(
          onPressed: () async {
            final res = await showDeleteDialog(context, mounted: mounted);

            if (res == null || !res) {
              return;
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  FadeBlackPageTransition.fadeBlack(
                    destination: const RegisterPage(),
                  ),
                  (route) => false,
                );
              }
            });
          },
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              AppLocalizations.of(context).deleteDeviceButton,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.errorContainer,
            ),
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
