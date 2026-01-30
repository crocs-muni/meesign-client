import 'package:flutter/material.dart';

import 'package:meesign_client/ui_constants.dart';

class LargeSquareButton extends StatelessWidget {
  const LargeSquareButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.color,
    super.key,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SMALL_GAP),
      child: SizedBox(
        width: 100,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(SMALL_BORDER_RADIUS),
            ),
          ),
          icon: Icon(icon, color: Colors.white),
          label: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
