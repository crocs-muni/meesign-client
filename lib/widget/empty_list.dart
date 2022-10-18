import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String hint;

  const EmptyList({
    Key? key,
    this.hint = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '0',
            style: Theme.of(context).textTheme.headline3,
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
