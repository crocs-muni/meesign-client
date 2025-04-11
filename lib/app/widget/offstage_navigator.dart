import 'package:flutter/material.dart';

import '../model/navigation_tab_model.dart';

class OffstageNavigator extends StatelessWidget {
  final int index;
  final int currentTabIndex;
  final NavigationTabModel navigationTab;

  const OffstageNavigator({
    super.key,
    required this.index,
    required this.currentTabIndex,
    required this.navigationTab,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: currentTabIndex != index,
      child: Navigator(
        key: navigationTab.navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            return KeyedSubtree(
              key: ValueKey('tab_${navigationTab.label}'),
              child: navigationTab.child,
            );
          });
        },
      ),
    );
  }
}
