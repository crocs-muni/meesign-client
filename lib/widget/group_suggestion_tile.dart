import 'package:flutter/material.dart';
import 'package:meesign_client/pages/group_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_core/meesign_core.dart';

class GroupSuggestionTile extends StatelessWidget {
  const GroupSuggestionTile({
    required this.group,
    super.key,
    this.onChanged,
  });
  final Group group;
  final void Function(Group?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<Group>(
      value: group,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Row(
        children: [
          Text(
            group.name,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const Spacer(),
          _buildInfoButton(context),
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
                builder: (context) => GroupPage(group: group),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SMALL_PADDING,
              vertical: 4,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Info',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
