import 'package:flutter/material.dart';

import 'package:meesign_client/ui_constants.dart';

class NoResultsPlaceholder extends StatelessWidget {
  const NoResultsPlaceholder({
    required this.icon,
    super.key,
    this.label = '',
    this.customLabel,
  });
  final String label;
  final Widget? customLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
          ),
          const SizedBox(height: SMALL_GAP),
          customLabel ??
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
          const SizedBox(height: XLARGE_GAP),
        ],
      ),
    );
  }
}
