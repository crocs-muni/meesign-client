import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final Stream<int> stream;
  final Widget? child;

  const CounterBadge({
    super.key,
    required this.stream,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      initialData: 0,
      builder: (context, snapshot) {
        int count = snapshot.data ?? 0;
        return Badge.count(
          count: count,
          isLabelVisible: count > 0,
          child: child,
        );
      },
    );
  }
}
