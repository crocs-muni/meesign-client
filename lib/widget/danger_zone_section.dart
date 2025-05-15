import 'package:flutter/material.dart';

import '../pages/register_page.dart';
import '../ui_constants.dart';
import '../util/confirm_device_change.dart';
import '../util/fade_black_page_transition.dart';

class DangerZoneSection extends StatefulWidget {
  const DangerZoneSection(
      {super.key, this.showText = true, this.centerContent = false});
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
            "Danger zone",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: SMALL_GAP),
          Text(
            "This action will effectively delete your device and all associated data. After deletion, you will need to re-register your device to continue using the app.",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          SizedBox(height: MEDIUM_GAP),
        ],
        FilledButton.icon(
          onPressed: () async {
            var res = await showDeleteDialog(context, mounted);

            if (res == null || res == false) {
              return;
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  FadeBlackPageTransition.fadeBlack(
                      destination: RegisterPage()),
                  (route) => false,
                );
              }
            });
          },
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Delete device',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
          ),
          icon: Icon(Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.errorContainer),
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
