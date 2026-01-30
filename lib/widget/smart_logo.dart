import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SmartLogo extends StatelessWidget {
  const SmartLogo({required this.logoWidth, super.key});

  final double logoWidth;
  @override
  Widget build(BuildContext context) {
    const lightModeLogo = 'assets/icon_logo_light_mode.svg';
    const darkModeLogo = 'assets/icon_logo_dark_mode.svg';

    return SvgPicture.asset(
      Theme.of(context).brightness == Brightness.dark
          ? darkModeLogo
          : lightModeLogo,
      width: logoWidth,
    );
  }
}
