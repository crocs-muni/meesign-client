import 'package:flutter/material.dart';

import '../ui_constants.dart';

class LargeSquareButton extends StatelessWidget {
  const LargeSquareButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.onPressed,
      required this.color});

  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: SMALL_GAP),
      child: SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(0),
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadiusGeometry.circular(SMALL_BORDER_RADIUS))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
