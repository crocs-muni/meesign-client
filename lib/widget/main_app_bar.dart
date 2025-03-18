import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../enums/screen_layout.dart';
import '../pages/device_page.dart';
import '../routes.dart';
import '../theme.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../view_model/app_view_model.dart';
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
      Consumer<AppViewModel>(
        builder: (context, model, child) {
          final name = model.device?.name ?? '';
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  final device = model.device;
                  if (device == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          DevicePage(device: device),
                    ),
                  );
                },
                icon: AnimatedBuilder(
                  animation:
                      context.read<AppContainer>().session!.sync.subscribed,
                  builder: (context, child) {
                    final session = context.read<AppContainer>().session!;
                    return Badge(
                      backgroundColor: session.sync.subscribed.value
                          ? Theme.of(context).extension<CustomColors>()!.success
                          : Theme.of(context).colorScheme.error,
                      smallSize: 8,
                      child: CircleAvatar(
                        child: Text(name.initials),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // TODO: migrate to MenuAnchor?
      Consumer<AppViewModel>(builder: (context, model, child) {
        return PopupMenuButton(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
            CheckedPopupMenuItem<void>(
              checked: model.showArchived,
              onTap: () => model.showArchived = !model.showArchived,
              child: const Text('Archived'),
            ),
            PopupMenuItem(
              onTap: () => Navigator.pushNamed(context, Routes.about),
              child: const Text('About'),
            ),
          ],
        );
      }),
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
