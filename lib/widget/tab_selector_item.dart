import 'package:flutter/material.dart';

import 'package:meesign_client/ui_constants.dart';

class TabSelectorItem extends StatelessWidget {
  const TabSelectorItem({
    required this.title,
    required this.stream,
    required this.tabIcon,
    super.key,
  });
  final String title;
  final Stream<int> stream;
  final Icon tabIcon;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (MediaQuery.sizeOf(context).width > 525) ...[
                tabIcon,
                const SizedBox(width: SMALL_GAP),
              ],
              if (constraints.maxWidth > 100) ...[
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: SMALL_GAP),
              ],
              _buildCounterBadge(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterBadge() {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          child: Center(
            child: Text(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
                fontWeight: FontWeight.bold,
              ),
              count > 9 ? '9+' : count.toString(),
            ),
          ),
        );
      },
    );
  }
}
