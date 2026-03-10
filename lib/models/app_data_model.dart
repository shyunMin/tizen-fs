import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:tizen_app_manager/app_manager.dart';
import 'package:tizen_fs/native/app_manager.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_interop/9.0/tizen.dart';
import 'package:tizen_package_manager/tizen_package_manager.dart';

enum SortOrder { asc, desc }

class AppDataModel extends ChangeNotifier {
  final String defaultAppId = 'org.tizen.homescreen';

  List<AppData> _apps = [];
  List<AppData> _displayedApps = [];
  List<AppData> _installedApps = [];
  List<AppData> _runningApps = [];

  bool _isLoading = false;
  bool _appLoaded = false;
  bool _pkgLoaded = false;

  int _selectedIndex = 0;
  bool _initialized = false;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  late AppData? _selectedApp;
  AppData get selectedApp => getSelectedAppData();
  set selectedApp(AppData app) {
    _selectedApp = app;
  }

  List<AppData> get allApps => _apps;
  List<AppData> get displayedApps => _displayedApps;
  List<AppData> get installedApps => _installedApps;
  List<AppData> get runningApps => _runningApps;

  SortOrder order = SortOrder.asc;
  String displayType = '';
  String filter = '';

  Future<void> updateDisplayedList() async {
    if (displayType.isEmpty) {
      _displayedApps =
          _installedApps.where((app) => (app.isNoDisplay == false)).toList();
    } else {
      _displayedApps =
          _installedApps
              .where(
                (app) =>
                    (app.isNoDisplay == false && app.appType == displayType),
              )
              .toList();
    }

    if (filter.isNotEmpty) {
      _displayedApps =
          _displayedApps
              .where((app) => app.name.toLowerCase().contains(filter))
              .toList();
    }

    if (order == SortOrder.asc) {
      _displayedApps.sort(
        (app1, app2) =>
            app1.name.toUpperCase().compareTo(app2.name.toUpperCase()),
      );
    } else {
      _displayedApps.sort(
        (app1, app2) =>
            app2.name.toUpperCase().compareTo(app1.name.toUpperCase()),
      );
    }

    notifyListeners();
  }

  Future<List<AppData>>? _loadAppsFuture;
  Future<List<AppData>>? _loadRunningAppsFuture;
  Future<List<AppData>>? _loadPacakgeInfosFuture;
  Future<void>? _loadAppSizeFuture;

  AppDataModel() {
    initialize();
    ApplicationManager.init();
  }

  void initialize() async {
    if (_initialized) return;

    await loadApps();
    await loadPackageInfos();

    _initialized = true;
  }

  @override
  void dispose() {
    ApplicationManager.dispose();
    super.dispose();
  }

  Future<void> loadApps() async {
    if (_appLoaded) return;

    _isLoading = true;

    if (_loadAppsFuture != null) return;

    _loadAppsFuture ??= _loadApps();
    _apps = await _loadAppsFuture!;
    _loadAppsFuture = null;

    _apps.sort(
      (app1, app2) =>
          app1.name.toUpperCase().compareTo(app2.name.toUpperCase()),
    );

    _appLoaded = true;
    _pkgLoaded = false;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> loadRunningApps() async {
    if (_loadAppsFuture != null) {
      await _loadAppsFuture;
    }

    if (_loadRunningAppsFuture != null) return;

    _loadRunningAppsFuture = _loadRunningApps();
    _runningApps = await _loadRunningAppsFuture!;
    _loadRunningAppsFuture = null;

    notifyListeners();
  }

  Future<List<AppData>> _loadRunningApps() async {
    List<AppData> runningApps = [];
    final apps = [..._apps];
    using((Arena arena) {
      for (var app in apps) {
        final isRunning = arena<Bool>();
        int ret = tizen.app_manager_is_running(
          app.appId.toNativeChar(allocator: arena),
          isRunning,
        );
        if (ret != 0) {
          debugPrint(
            'Failed to app_manager_is_running. Error code: ${tizen.get_error_message(ret).toDartString()}',
          );
        }

        app.updateIsRunning(isRunning.value);

        if (isRunning.value) {
          runningApps.add(app);
        }
      }
    });

    return runningApps;
  }

  Future<void> loadPackageInfos() async {
    if (_pkgLoaded) return;

    if (_loadAppsFuture != null) {
      await _loadAppsFuture;
    }

    if (_loadPacakgeInfosFuture != null) return;

    _loadPacakgeInfosFuture = _loadPackageInfos();
    final apps = await _loadPacakgeInfosFuture!;
    _loadPacakgeInfosFuture = null;

    _installedApps = apps.where((app) => app.isPreloaded == false).toList();

    if (displayType.isEmpty) {
      _displayedApps =
          _installedApps.where((app) => (app.isNoDisplay == false)).toList();
    } else {
      _displayedApps =
          _installedApps
              .where(
                (app) =>
                    (app.isNoDisplay == false &&
                        app.appType.toLowerCase().contains(displayType)),
              )
              .toList();
    }

    if (order == SortOrder.desc) {
      _displayedApps.sort(
        (app1, app2) =>
            app2.name.toUpperCase().compareTo(app1.name.toUpperCase()),
      );
    }

    _selectedApp = _displayedApps.firstOrNull;

    _pkgLoaded = true;

    notifyListeners();
  }

  Future<List<AppData>> _loadPackageInfos() async {
    final packages = await PackageManager.getPackagesInfo();
    final apps = [..._apps];
    for (AppData app in apps) {
      final pkg =
          packages.where((pkg) => pkg.packageId == app.packageId).firstOrNull;

      app.isPreloaded = pkg?.isPreloaded ?? false;
      app.version = pkg?.version ?? '';
      app.packageType = pkg?.packageType.toString() ?? '';
    }
    return apps;
  }

  Future<void> loadAppSize() async {
    if (_loadAppsFuture != null) {
      await _loadAppsFuture;
    }

    if (_loadAppSizeFuture != null) return;

    _loadAppSizeFuture = _loadAppSize();
    await _loadAppSizeFuture;
    _loadAppSizeFuture = null;
  }

  Future<void> _loadAppSize() async {
    final apps = [..._apps];
    for (var app in apps) {
      final sizeInfo = await ApplicationManager.getPackageSizeInfo(
        app.packageId,
      );
      app.updateSizeInfo(
        PackageSizeData(
          app: sizeInfo.appSize + sizeInfo.externalAppSize,
          cache: sizeInfo.cacheSize + sizeInfo.externalCacheSize,
          userData: sizeInfo.dataSize + sizeInfo.externalDataSize,
        ),
      );
    }
  }

  Future<void> reloadAppSize(AppData app) async {
    final sizeInfo = await ApplicationManager.getPackageSizeInfo(app.packageId);
    app.updateSizeInfo(
      PackageSizeData(
        app: sizeInfo.appSize + sizeInfo.externalAppSize,
        cache: sizeInfo.cacheSize + sizeInfo.externalCacheSize,
        userData: sizeInfo.dataSize + sizeInfo.externalDataSize,
      ),
    );
    notifyListeners();
  }

  AppData getAppData(int index) {
    if (_isLoading) {
      return AppData(
        appId: 'Loading...',
        name: 'Loading...',
        icon: 'Loading...',
        resourcePath: 'Loading...',
      );
    }
    return _apps[index];
  }

  AppData getSelectedAppData() {
    if (_isLoading || _selectedApp == null) {
      return AppData(
        appId: 'Loading...',
        name: 'Loading...',
        icon: 'Loading...',
        resourcePath: 'Loading...',
      );
    }
    return _selectedApp!;
  }

  Future<List<AppData>> _loadApps() async {
    final installedApps = await AppManager.getInstalledApps();
    List<AppData> apps = [];
    for (AppInfo app in installedApps) {
      if (app.label.isNotEmpty) {
        apps.add(
          AppData(
            appId: app.appId,
            name: app.label,
            packageId: app.packageId,
            icon: app.iconPath ?? 'assets/images/default_icon.png',
            resourcePath: app.sharedResourcePath,
            appType: app.appType,
            isNoDisplay: app.isNoDisplay,
            isDefaultApp: app.appId == defaultAppId,
          ),
        );
      }
    }

    _pkgLoaded = false;
    return apps;
  }

  bool _applaunching = false;
  bool get isAppLaunching => _applaunching;
  set isAppLaunching(bool value) {
    _applaunching = value;
    notifyListeners();
  }

  Future<void> launchApp(String appid) async {
    if (isAppLaunching) return;

    isAppLaunching = true;

    final timer = Timer(const Duration(seconds: 15), () {
      debugPrint('Failed to launch the app within timeout');
      isAppLaunching = false;
    });

    try {
      await ApplicationManager.launch(appid);
    } catch (e) {
      debugPrint('Failed to launch the app: $e');
    }

    isAppLaunching = false;
    timer.cancel();
  }

  Future<void> removeUninstalledApp(String pkgid) async {
    _appLoaded = false;

    if (_loadAppsFuture != null) {
      await _loadAppsFuture;
    }

    _isLoading = true;
    _apps.removeWhere((app) => app.packageId == pkgid);
    _installedApps = _apps.where((app) => app.isPreloaded == false).toList();

    if (displayType.isEmpty) {
      _displayedApps =
          _installedApps.where((app) => (app.isNoDisplay == false)).toList();
    } else {
      _displayedApps =
          _installedApps
              .where(
                (app) =>
                    (app.isNoDisplay == false &&
                        app.appType.toLowerCase().contains(displayType)),
              )
              .toList();
    }

    if (order == SortOrder.desc) {
      _displayedApps.sort(
        (app1, app2) =>
            app2.name.toUpperCase().compareTo(app1.name.toUpperCase()),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addInstalledApp(String pkgid) async {
    _appLoaded = false;

    if (_loadAppsFuture != null) return;
    await loadApps();
    await loadPackageInfos();
    await loadAppSize();
    await loadRunningApps();
  }

  void removeRunningApp(AppData app) {
    _runningApps.remove(app);
    notifyListeners();
  }
}
