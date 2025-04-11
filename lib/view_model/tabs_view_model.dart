import 'package:flutter/material.dart';

class TabsViewModel extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int newIndex) {
    if (_index != newIndex) {
      _index = newIndex;
      notifyListeners();
    }
  }
}
