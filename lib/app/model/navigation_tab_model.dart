import 'package:flutter/cupertino.dart';

class NavigationTabModel {
  final Widget icon;
  final String label;
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigationTabModel({
    required this.icon,
    required this.label,
    required this.child,
  });
}
