import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../view_model/tabs_view_model.dart';

class ControlledLottieAnimation extends StatefulWidget {
  final String assetName;
  final double stopAtPercentage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? startAtTabIndex;

  const ControlledLottieAnimation({
    super.key,
    required this.assetName,
    this.stopAtPercentage = 1,
    this.startAtTabIndex,
    this.width,
    this.height,
    this.fit,
  });

  @override
  State<ControlledLottieAnimation> createState() =>
      _ControlledLottieAnimationState();
}

class _ControlledLottieAnimationState extends State<ControlledLottieAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..addListener(() {
        if (_loaded &&
            mounted &&
            _controller.value >= widget.stopAtPercentage) {
          _controller.stop(canceled: false);
        }
      });
  }

  @override
  void dispose() {
    if (mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _checkAnimationStart() {
    final tabIndex = context.watch<TabsViewModel>().index;
    const allTasksTabIndex = 1;

    if (_loaded && !_controller.isAnimating) {
      if (widget.startAtTabIndex == null ||
          tabIndex == widget.startAtTabIndex ||
          tabIndex == allTasksTabIndex) {
        // This replays the animation when the tab is selected.
        // Remove the reset() if you want to keep the animation state.
        _controller.reset();

        // Start the animation if the tab index matches
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAnimationStart();

    return Lottie.asset(
      widget.assetName,
      controller: _controller,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      onLoaded: (composition) {
        if (!mounted) return;

        setState(() {
          _loaded = true;
        });

        _controller.duration = composition.duration;
      },
    );
  }
}
