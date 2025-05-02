import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

class GroupSuggestionTile extends StatelessWidget {
  final Group group;
  final bool active;
  final bool selected;
  final void Function(bool?)? onChanged;

  const GroupSuggestionTile({
    super.key,
    required this.group,
    this.active = false,
    this.selected = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<bool>(
      value: true,
      groupValue: selected,
      onChanged: onChanged,
      title: Text(group.name,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
    );
  }
}
