import 'package:flutter/material.dart';

import 'package:meesign_client/app/model/navigation_tab_model.dart';

class OffstageNavigator extends StatelessWidget {
  const OffstageNavigator({
    required this.index,
    required this.currentTabIndex,
    required this.navigationTab,
    super.key,
  });
  final int index;
  final int currentTabIndex;
  final NavigationTabModel navigationTab;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: currentTabIndex != index,
      child: Navigator(
        key: navigationTab.navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) {
              return navigationTab.child;
            },
          );
        },
      ),
    );
  }
}
