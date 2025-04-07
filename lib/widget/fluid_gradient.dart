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
                Color(0xFF20190E),
                Color(0xFF302614),
                Color(0xFF55411C),
                Color(0xFF3C3321),
              ]
            : const [
                Color(0xFFFFF5E4),
                Color(0xFFDAD2C5),
                Color(0xFFF1DDBA),
                Color(0xFFF1CB88),
              ],
        options: AnimatedMeshGradientOptions(speed: animationSpeed),
      ),
    );
  }
}

/*

This is for blue theme which should not be used
on devel branch.

  const [
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

 */
