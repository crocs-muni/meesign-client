import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String hint;

  const EmptyList({
    super.key,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '0',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Nothing here yet.\n$hint',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
