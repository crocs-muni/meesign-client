import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/screen_layout.dart';
import '../ui_constants.dart';
import '../app/widget/tabbed_scaffold.dart';
import '../view_model/tabs_view_model.dart';
import 'device_icon.dart';
import 'smart_logo.dart';

PreferredSizeWidget buildAppBar(
    BuildContext context, ScreenLayout currentLayout) {
  return AppBar(
    forceMaterialTransparency: true,
    surfaceTintColor: Colors.transparent,
    toolbarHeight:
        currentLayout == ScreenLayout.mobile ? mobileAppBarHeight : null,
    title: _buildAppBarTitle(context),
    actions: [
      DeviceIcon(),
      Padding(
          padding: const EdgeInsets.only(right: SMALL_GAP),
          child: Consumer<TabsViewModel>(
            builder: (context, model, child) {
              return IconButton(
                  onPressed:
                      model.settingsPageInStack || model.newGroupPageInStack
                          ? null
                          : () {
                              TabbedScaffold.openSettingsInContext(context);
                            },
                  icon: Icon(Icons.settings));
            },
          ))
    ],
  );
}

Widget _buildAppBarTitle(BuildContext context) {
  final logoFontSize = Theme.of(context).textTheme.headlineLarge?.fontSize;
  const logoWidth = 32.0;
  const logoVerticalOffset = -2.0;

  return Row(
    children: [
      Text('MeeSign',
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: logoFontSize)),
      SizedBox(
        width: SMALL_GAP,
      ),
      Transform.translate(
        offset: Offset(0, logoVerticalOffset),
        child: SmartLogo(logoWidth: logoWidth),
      )
    ],
  );
}
