import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme.dart';

class WarningBanner extends StatelessWidget {
  final String title;
  final String text;
  final List<Widget> actions;
  final bool roundedBorder;

  const WarningBanner({
    super.key,
    required this.title,
    required this.text,
    this.actions = const [],
    this.roundedBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // FIXME: any better way?
    final buttonTheme = Theme.of(context).copyWith(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onErrorContainer,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onErrorContainer,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onError,
          backgroundColor: colorScheme.error,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(XLARGE_PADDING),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(roundedBorder ? MEDIUM_BORDER_RADIUS : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Symbols.warning,
                fill: 1,
                color: colorScheme.error,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Theme(
              data: buttonTheme,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
