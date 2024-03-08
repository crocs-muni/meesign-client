import 'package:flutter/material.dart';

import '../util/chars.dart';

class EntityChip extends StatelessWidget {
  final String name;

  const EntityChip({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        child: Text(
          name.initials,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      label: Text(name),
    );
  }
}
