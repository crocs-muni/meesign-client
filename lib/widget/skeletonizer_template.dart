import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonizerTemplate extends StatelessWidget {
  const SkeletonizerTemplate({
    required this.child,
    required this.isLoading,
    super.key,
    this.animateLoad = true,
  });
  final Widget child;
  final bool isLoading;
  final bool animateLoad;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: animateLoad,
      enabled: isLoading,
      child: child,
    );
  }
}
