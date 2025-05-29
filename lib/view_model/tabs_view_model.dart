import 'package:flutter/material.dart';

class TabsViewModel extends ChangeNotifier {
  int _index = 0;
  String _postNavigationAction = '';
  bool _newGroupPageActive = false;
  bool _settingsPageInStack = false;

  int get index => _index;
  String get postNavigationAction => _postNavigationAction;
  bool get newGroupPageActive => _newGroupPageActive;
  bool get settingsPageInStack => _settingsPageInStack;

  void setIndex(int newIndex, {String postNavigationAction = ''}) {
    if (_index != newIndex) {
      _index = newIndex;
      _postNavigationAction = postNavigationAction;
      notifyListeners();
    }
  }

  void setNewGroupPageActive(bool isActive) {
    _newGroupPageActive = isActive;
  }

  void setSettingsPageInStack(bool isInStack) {
    _settingsPageInStack = isInStack;
    notifyListeners();
  }
}
