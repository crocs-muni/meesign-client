import 'package:flutter/material.dart';

import '../ui_constants.dart';

class NoResultsPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;

  const NoResultsPlaceholder({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(height: SMALL_GAP),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: XLARGE_GAP),
        ],
      ),
    );
  }
}
