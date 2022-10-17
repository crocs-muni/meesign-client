import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final Stream<int> stream;
  final Widget? child;

  const CounterBadge({
    Key? key,
    required this.stream,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      initialData: 0,
      builder: (context, snapshot) {
        int count = snapshot.data ?? 0;
        return Badge(
          badgeContent: Text(
            count.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          showBadge: count != 0,
          child: child,
        );
      },
    );
  }
}
