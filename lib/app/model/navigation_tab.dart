import 'package:flutter/cupertino.dart';

class NavigationTab {
  final Icon icon;
  final String label;
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigationTab({required this.icon, required this.label, required this.child});
}
