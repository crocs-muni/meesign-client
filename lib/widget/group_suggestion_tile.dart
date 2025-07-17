import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../pages/group_page.dart';
import '../ui_constants.dart';

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
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        children: [
          Text(group.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          Spacer(),
          _buildInfoButton(context)
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => GroupPage(group: group)),
            );
          },
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: SMALL_PADDING, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 4),
                Text("Info",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
