import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  const CounterBadge({
    required this.stream,
    super.key,
    this.child,
  });
  final Stream<int> stream;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Badge.count(
          count: count,
          isLabelVisible: count > 0,
          child: child,
        );
      },
    );
  }
}
