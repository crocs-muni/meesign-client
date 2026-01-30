import 'package:flutter/material.dart';

class FadeBlackPageTransition {
  static PageRouteBuilder fadeBlack({
    required Widget destination,
    int duration = 2,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return destination;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Black overlay that fades in first
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0, 0.5, curve: Curves.easeInOut),
                ),
              ),
              child: Container(color: Colors.black),
            ),

            // Actual page that fades in after 1 second
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1, curve: Curves.easeInOut),
                ),
              ),
              child: child,
            ),
          ],
        );
      },
      transitionDuration: Duration(seconds: duration),
    );
  }
}
