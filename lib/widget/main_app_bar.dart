import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../pages/device_page.dart';
import '../routes.dart';
import '../theme.dart';
import '../util/chars.dart';
import '../view_model/app_view_model.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text('MeeSign'),
    actions: [
      Consumer<AppViewModel>(builder: (context, model, child) {
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
      }),
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
