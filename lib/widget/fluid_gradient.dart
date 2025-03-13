import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class FluidGradient extends StatelessWidget {
  final double animationSpeed;

  const FluidGradient({
    super.key,
    this.animationSpeed = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: AnimatedMeshGradient(
        colors: Theme.of(context).brightness == Brightness.dark
            ? const [
                Color(0xFF121920),
                Color(0xFF1D1D22),
                Color(0xFF1A1A1A),
                Color(0xFF172A35),
              ]
            : const [
                Color(0xFF80C1FF),
                Color(0xFFC7F3FF),
                Color(0xFF74A0FF),
                Color(0xFFF5F8FF),
              ],
        options: AnimatedMeshGradientOptions(speed: animationSpeed),
      ),
    );
  }
}
