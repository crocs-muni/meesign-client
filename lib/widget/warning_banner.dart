import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class WarningBanner extends StatelessWidget {
  final String title;
  final String text;
  final List<Widget> actions;

  const WarningBanner({
    super.key,
    required this.title,
    required this.text,
    this.actions = const [],
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
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.all(16),
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
