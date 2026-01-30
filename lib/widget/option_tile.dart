import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    required this.title,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.titlePadding = EdgeInsets.zero,
    this.children = const [],
    this.help,
  });
  final String title;
  final EdgeInsets padding;
  final EdgeInsets titlePadding;
  final List<Widget> children;
  final Widget? help;

  @override
  Widget build(BuildContext context) {
    Widget? helpButton;
    if (help != null) {
      helpButton = SizedBox.square(
        dimension: 24,
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 20,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: const Icon(Symbols.help),
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: help,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Symbols.help, opticalSize: 20),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: titlePadding,
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                if (helpButton != null) helpButton,
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
