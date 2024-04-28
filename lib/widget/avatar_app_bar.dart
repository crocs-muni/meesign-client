import 'package:flutter/material.dart';

import '../util/chars.dart';

class FlexibleAvatarAppBar extends StatelessWidget {
  final String name;

  const FlexibleAvatarAppBar({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: FittedBox(
                child: CircleAvatar(
                  child: Text(name.initials),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: kToolbarHeight,
          child: Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}
