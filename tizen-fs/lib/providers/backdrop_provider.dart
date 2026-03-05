import 'package:flutter/material.dart';

class BackdropProvider extends ChangeNotifier {
  String _url = '';
  String get url => _url;
  set url(String value) {
    _url = value;
    notifyListeners();
  }

  bool _isZoomin = false;
  bool get isZoomIn => _isZoomin;
  set isZoomIn(bool value) {
    _isZoomin = value;
    notifyListeners();
  }

  bool _isGradientEffectOn = true;
  bool get isGradientEffectOn => _isGradientEffectOn;
  set isGradientEffect(bool value) {
    _isGradientEffectOn = value;
    notifyListeners();
  }
}
