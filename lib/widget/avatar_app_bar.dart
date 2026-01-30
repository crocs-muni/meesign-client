import 'package:flutter/material.dart';

class FlexibleAvatarAppBar extends StatelessWidget {
  const FlexibleAvatarAppBar({
    required this.avatar,
    required this.title,
    super.key,
  });
  final Widget avatar;
  final Widget title;

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
                  child: avatar,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: kToolbarHeight,
          child: Center(
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.titleLarge,
              child: title,
            ),
          ),
        ),
      ],
    );
  }
}
