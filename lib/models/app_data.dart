import 'package:flutter/material.dart';
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/utils/extensions.dart';

class AppData extends ChangeNotifier implements ItemDisplayInterface {
  String appId;
  String name;
  String icon;
  String packageId;
  String resourcePath;
  String appType;
  String version;
  String packageType;
  bool isNoDisplay;
  bool isPreloaded;
  bool isRunning;
  PackageSizeData? size;
  bool isUninstalled;
  bool isDefaultApp;

  AppData({
    this.appId = '',
    this.name = '',
    this.packageId = '',
    this.icon = '',
    this.resourcePath = '',
    this.appType = '',
    this.packageType = '',
    this.isNoDisplay = false,
    this.isPreloaded = false,
    this.isRunning = false,
    this.version = '',
    this.isUninstalled = false,
    this.isDefaultApp = false,
  });

  void updateSizeInfo(PackageSizeData sizeInfo) {
    size = sizeInfo;
    notifyListeners();
  }

  void updateIsRunning(bool value) {
    isRunning = value;
    notifyListeners();
  }

  void uninstall() {
    isUninstalled = true;
    notifyListeners();
  }

  @override
  String get displayText => name;

  @override
  String get displaySubText => size?.total.toSizeString() ?? 'Bytes';

  @override
  Object get iconSourceData => icon;

  @override
  IconSourceType get iconSourceType => IconSourceType.uri;

  @override
  bool get isSelectable => true;
}

class PackageSizeData {
  int get total => _getTotal();
  late int app;
  late int userData;
  late int cache;

  PackageSizeData({this.app = 0, this.userData = 0, this.cache = 0});

  int _getTotal() {
    return app + userData + cache;
  }
}
