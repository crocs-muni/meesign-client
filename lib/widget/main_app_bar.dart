import 'package:flutter/material.dart';

import '../enums/screen_layout.dart';
import '../ui_constants.dart';
import 'device_icon.dart';
import 'smart_logo.dart';

PreferredSizeWidget buildAppBar(
    BuildContext context, ScreenLayout currentLayout) {
  return AppBar(
    forceMaterialTransparency: true,
    surfaceTintColor: Colors.transparent,
    toolbarHeight:
        currentLayout == ScreenLayout.mobile ? mobileAppBarHeight : null,
    title: _buildAppBarTitle(context, currentLayout),
  );
}

Widget _buildAppBarTitle(BuildContext context, ScreenLayout currentLayout) {
  const logoFontSize = 32.0;
  const smallLogoFontSize = 24.0;

  const logoWidth = 32.0;
  const smallLogoWidth = 24.0;
  const logoVerticalOffset = -2.0;

  return LayoutBuilder(
    builder: (context, constraints) {
      const minSpaceForDeviceIcon = 60.0;
      const minSpaceForLogo = 120.0;
      const minSpaceForFullLogo = minSpaceForLogo + minSpaceForDeviceIcon;

      final availableWidth = constraints.maxWidth;
      final showFullLogo = availableWidth >= minSpaceForFullLogo;

      return Row(
        children: [
          if (showFullLogo)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MeeSign',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: currentLayout == ScreenLayout.mobile
                            ? smallLogoFontSize
                            : logoFontSize)),
                SizedBox(
                  width: SMALL_GAP,
                ),
                Transform.translate(
                  offset: Offset(0, logoVerticalOffset),
                  child: SmartLogo(
                      logoWidth: currentLayout == ScreenLayout.mobile
                          ? smallLogoWidth
                          : logoWidth),
                )
              ],
            )
          else
            // Show only logo icon on very small screens
            Transform.translate(
              offset: Offset(0, logoVerticalOffset),
              child: SmartLogo(
                  logoWidth: currentLayout == ScreenLayout.mobile
                      ? smallLogoWidth
                      : logoWidth),
            ),
          SizedBox(width: SMALL_PADDING),
          const Flexible(child: DeviceIcon()),
        ],
      );
    },
  );
}
