import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/ai/ai_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';

class FeatureData extends ChangeNotifier implements ItemDisplayInterface {
  String name;
  String? description;
  bool isEnabled;
  VoidCallback? on;
  VoidCallback? off;

  FeatureData({
    this.name = '',
    this.description,
    this.isEnabled = false,
    this.on,
    this.off,
  });

  @override
  String get displayText => name;

  @override
  String? get displaySubText => null;

  @override
  Object? get iconSourceData => null;

  @override
  IconSourceType get iconSourceType => IconSourceType.none;

  @override
  bool get isSelectable => true;

  void toggle() {
    isEnabled = !isEnabled;
    if (isEnabled) {
      on?.call();
    } else {
      off?.call();
    }
    notifyListeners();
  }

  void enable(bool enable) {
    isEnabled = enable;
    if (enable) {
      on?.call();
    } else {
      off?.call();
    }

    notifyListeners();
  }
}

class AdditaionalFeatureProvider extends ChangeNotifier {
  final TabBarProvider _tabsProvider;
  final AIProvider _aiProvider;
  final List<FeatureData> _features = [];

  List<FeatureData> get features => _features;

  AdditaionalFeatureProvider(this._tabsProvider, this._aiProvider) {
    _features.add(
      FeatureData(
        name: "media",
        description: '',
        isEnabled: true,
        on: () {
          _tabsProvider.addTab("media");
        },
        off: () {
          _tabsProvider.removeTab("media");
        },
      ),
    );
    _features.add(
      FeatureData(
        name: "live",
        description: '',
        isEnabled: true,
        on: () {
          _tabsProvider.addTab("live");
        },
        off: () {
          _tabsProvider.removeTab("live");
        },
      ),
    );
    _features.add(
      FeatureData(
        name: 'ai',
        description: '',
        isEnabled: false,
        on: () {
          _aiProvider.enable();
          notifyListeners();
        },
        off: () {
          _aiProvider.disable();
          notifyListeners();
        },
      ),
    );
  }

  FeatureData? getFeature(String name) {
    return _features.where((f) => f.name == name).firstOrNull;
  }
}
