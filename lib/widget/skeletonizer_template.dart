import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonizerTemplate extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool animateLoad;
  const SkeletonizerTemplate(
      {super.key,
      required this.child,
      required this.isLoading,
      this.animateLoad = true});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enableSwitchAnimation: animateLoad, enabled: isLoading, child: child);
  }
}
