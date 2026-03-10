import 'package:flutter/material.dart';

class TabModel {}

class TabBarProvider extends ChangeNotifier {
  final _fixedOrder = ["home", "media", "live"];

  late FocusNode? _tabbarFocusNode;

  late List<String> _tabs;
  List<String> get tabs => _tabs;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  TabBarProvider() {
    _tabs = ["home", "media", "live"];
  }

  void updateIndex(int newIndex) {
    if (_currentIndex == newIndex) return;

    _currentIndex = newIndex;
    notifyListeners();
  }

  void setFocusNode(FocusNode? focusNode) {
    _tabbarFocusNode = focusNode;
  }

  void initIndex(int index) {
    _currentIndex = index;
  }

  void requestFocus() {
    _tabbarFocusNode?.requestFocus();
  }

  void addTab(String tab) {
    if (_tabs.contains(tab)) {
      return;
    }

    if (_fixedOrder.contains(tab)) {
      final index = _fixedOrder.indexOf(tab);
      int insertIndex = 0;

      for (int i = 0; i < index; i++) {
        if (_tabs.contains(_fixedOrder[i])) {
          insertIndex++;
        }
      }

      _tabs.insert(insertIndex, tab);
    } else {
      _tabs.add(tab);
    }

    updateIndex(1);
  }

  void removeTab(String tab) {
    _tabs.remove(tab);
    // Adjust current index if it's out of bounds
    if (_currentIndex >= _tabs.length) {
      _currentIndex = _tabs.length - 1;
    }
    updateIndex(1);
  }
}
