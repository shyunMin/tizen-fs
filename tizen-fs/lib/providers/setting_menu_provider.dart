import 'package:flutter/material.dart';

class SettingMenuProvider extends ChangeNotifier {
  String _uri = '/settings';
  String get uri => _uri;
  set uri(String value) {
    if (_uri == value) return;

    _uri = value;
    notifyListeners();
  }

  int _current = 0;
  int get currentIndex => _current;
  set currentIndex(int value) {
    if (_current == value) return;

    _current = value;
    notifyListeners();
  }
}
