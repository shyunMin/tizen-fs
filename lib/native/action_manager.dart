import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tizen_audio_manager/tizen_audio_manager.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/action_model.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/providers/locale_provider.dart';
import 'package:tizen_fs/providers/setting_menu_provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/router.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/utils/ui_event.dart';

typedef RunActionFunction =
    Future<bool> Function(Map<String, dynamic> actionData);

class ActionManager {
  static final _eventController = StreamController<UiEvent>.broadcast();
  static Stream<UiEvent> get eventStream => _eventController.stream;
  static int _currentLevel = 0;

  static final Map<String, RunActionFunction> _actionFunctions = {
    'homeVolume': _runVolumeAction,
    'homeSetting': _runSettingsAction,
    'homeApps': _runAppsAction,
    'homeLanguage': _runLanguageAction,
    'homeDevice': _runDeviceAction,
    'homeAdditionalFeature': _runAdditionalFeatureAction,
    'homeVideo': _runVideoAction,
    'homeNotification': _runNotificationAction,
    'homeWifi': _runWifiAction,
    'homeWifiList': _runWifiListAction,
    'homeWifiFind': _runWifiFindAction,
    'homeBluetooth': _runBluetoothAction,
    'homeBluetoothList': _runBluetoothListAction,
    'homeBluetoothFind': _runBluetoothFindAction,
    'homeLive': _runLiveAction,
  };

  static Future<bool> runAction(Map<String, dynamic> actionData) async {
    String reply = '';

    if (actionData.containsKey('__K_ACTION_NAME')) {
      final actionName = actionData['__K_ACTION_NAME'];
      final runAction = _actionFunctions[actionName];
      if (runAction != null) {
        return await runAction(actionData);
      } else {
        reply = 'Not Found: $actionName';
        _eventController.add(ShowToastMessageEvent(reply));
        return false;
      }
    }

    reply = 'Not found action';
    _eventController.add(ShowToastMessageEvent(reply));
    return false;
  }

  static Future<bool> _runVolumeAction(Map<String, dynamic> actionData) async {
    debugPrint('_runVolumeAction');
    int level = 0;

    if (actionData.containsKey('command')) {
      final command = actionData['command'];

      if (command == 'up') {
        _currentLevel = await AudioManager.volumeController.getLevel(
          AudioVolumeType.media,
        );
        level = (_currentLevel > 10 ? _currentLevel + 1 : 10).clamp(0, 15);
      } else if (command == 'down') {
        _currentLevel = await AudioManager.volumeController.getLevel(
          AudioVolumeType.media,
        );
        level = (_currentLevel < 5 ? _currentLevel - 1 : 3).clamp(0, 15);
      } else if (command == 'mute') {
        _currentLevel = await AudioManager.volumeController.getLevel(
          AudioVolumeType.media,
        );
        level = 0;
      } else {
        level = _currentLevel;
      }
    } else if (actionData.containsKey('level')) {
      level = int.tryParse(actionData['level']) ?? 0;
    }

    debugPrint('_currentLevel=$_currentLevel, level=$level');

    if (level != null) {
      await AudioManager.volumeController.setLevel(
        AudioVolumeType.media,
        level,
      );
    }

    // _eventController.add(ShowToastMessageEvent('volumeChangedSuccessfully'));
    _eventController.add(ShowWidgetEvent(WidgetType.volume, null));
    return true;
  }

  static Future<bool> _runSettingsAction(
    Map<String, dynamic> actionData,
  ) async {
    final uri = actionData['uri'].toString();

    getIt<SettingMenuProvider>().uri = uri;
    RouterService.instance.safePush(ScreenPaths.settings);
    return true;
  }

  static Future<bool> _runAppsAction(Map<String, dynamic> actionData) async {
    if (actionData.containsKey('type')) {
      final type = actionData['type'].toString().toLowerCase();

      getIt<AppDataModel>().displayType = type;
    }
    if (actionData.containsKey('app_name')) {
      final filter = actionData['app_name'].toString().toLowerCase();
      getIt<AppDataModel>().filter = filter;
    }

    if (actionData.containsKey('sort')) {
      final sort = actionData['sort'].toString().toLowerCase();

      if (SortOrder.values.any((e) => e.name == sort)) {
        getIt<AppDataModel>().order = SortOrder.values.byName(sort);
      }
    }

    getIt<AppDataModel>().updateDisplayedList();
    _eventController.add(ShowToastMessageEvent('appListChangedSuccessfully'));

    RouterService.instance.safePop();

    return true;
  }

  static Future<bool> _runLanguageAction(
    Map<String, dynamic> actionData,
  ) async {
    final locale = actionData['language'].toString();

    final ret = getIt<LocaleProvider>().setSystemLocale(locale);
    debugPrint('ret=$ret, locale=$locale');
    if (ret) {
      _eventController.add(
        ShowToastMessageEvent('languageChangedSuccessfully'),
      );
      RouterService.instance.safePop();
      return true;
    }
    RouterService.instance.safePop();
    return false;
  }

  static Future<bool> _runDeviceAction(Map<String, dynamic> actionData) async {
    final name = actionData['name'].toString();

    if (name.isNotEmpty) {
      getIt<DeviceInfoProvider>().updateDeviceName(name);
      debugPrint('Device name updated to: $name');
      _eventController.add(
        ShowToastMessageEvent('deviceNameChangedSuccessfully'),
      );

      // Navigate to device settings and pop action page
      getIt<SettingMenuProvider>().uri =
          '/settings/about_device/about_device_device_info';
      RouterService.instance.safePop();
      RouterService.instance.safePush(ScreenPaths.settings);

      return true;
    }
    return false;
  }

  static Future<bool> _runAdditionalFeatureAction(
    Map<String, dynamic> actionData,
  ) async {
    final featureName = actionData['featureName'].toString().toLowerCase();
    final enabled = actionData['enabled'].toString().toLowerCase();

    final provider = getIt<AdditaionalFeatureProvider>();
    final feature = provider.getFeature(featureName);

    if (feature != null) {
      // Toggle the feature to the desired state
      feature.enable(enabled == "on");

      debugPrint('Feature $featureName set to: $enabled');

      if (feature.name != "ai") {
        RouterService.instance.safePop();
        _eventController.add(
          ShowToastMessageEvent('featureStateChangedSuccessfully'),
        );
      }

      return true;
    }

    debugPrint('Feature not found: $featureName');
    return false;
  }

  static Future<bool> _runVideoAction(Map<String, dynamic> actionData) async {
    final url = actionData['url'].toString();

    //if url = kids, entertainment

    RouterService.instance.safePush(
      ScreenPaths.live,
      extra: {'title': '', 'url': url},
    );
    return true;
  }

  static Future<bool> _runNotificationAction(
    Map<String, dynamic> actionData,
  ) async {
    final command = actionData['command'].toString();

    if (command == 'show') {
      _eventController.add(ShowDialogEvent(PanelType.notification));
    }
    return true;
  }

  static Future<bool> _runWifiAction(Map<String, dynamic> actionData) async {
    final command = actionData['command'].toString();
    bool ret = false;

    if (command == 'on') {
      ret = await getIt<WifiProvider>().wifiOn();
      if (!ret) {
        _eventController.add(ShowToastMessageEvent('failedToWifiOn'));
        return false;
      }
    } else {
      ret = await getIt<WifiProvider>().wifiOff();
      if (!ret) {
        _eventController.add(ShowToastMessageEvent('failedToWifiOff'));
        return false;
      }
    }
    return true;
  }

  static Future<bool> _runWifiListAction(
    Map<String, dynamic> actionData,
  ) async {
    _eventController.add(ShowWidgetEvent(WidgetType.wifiList, null));
    return true;
  }

  static Future<bool> _runWifiFindAction(
    Map<String, dynamic> actionData,
  ) async {
    _eventController.add(ShowWidgetEvent(WidgetType.wifiList, null));
    return true;
  }

  static Future<bool> _runBluetoothAction(
    Map<String, dynamic> actionData,
  ) async {
    final command = actionData['command'].toString();
    bool ret = false;

    if (command == 'on') {
      ret = await getIt<BtModel>().enable();
      if (!ret) {
        _eventController.add(ShowToastMessageEvent('failedToBtOn'));
        return false;
      }
    } else {
      if (getIt<BtModel>().isEnabled) {
        ret = await getIt<BtModel>().disable();
      }

      if (!ret) {
        _eventController.add(ShowToastMessageEvent('failedToBtOff'));
        return false;
      }
    }

    _eventController.add(ShowWidgetEvent(WidgetType.bluetooth, null));
    return true;
  }

  static Future<bool> _runBluetoothListAction(
    Map<String, dynamic> actionData,
  ) async {
    _eventController.add(ShowWidgetEvent(WidgetType.bluetoothList, null));
    return true;
  }

  static Future<bool> _runBluetoothFindAction(
    Map<String, dynamic> actionData,
  ) async {
    _eventController.add(ShowWidgetEvent(WidgetType.bluetoothList, null));
    return true;
  }

  static Future<bool> _runLiveAction(Map<String, dynamic> actionData) async {
    String url = actionData['url'].toString();
    debugPrint('############ homeLive: $url');

    //if url = kids, entertainment
    if (url == "kids") {
      url = "https://ebsonair.ebs.co.kr/ebs2familypc/familypc1m/playlist.m3u8";
    } else {
      url =
          "http://amdlive.ctnd.com.edgesuite.net/arirang_1ch/smil:arirang_1ch.smil/chunklist_b2256000_sleng.m3u8";
    }

    // Future.microtask(() async {
    //   await Future.delayed(const Duration(seconds: 1));
    //   RouterService.instance.safePush(
    //     ScreenPaths.live,
    //     extra: {'title': '', 'url': url},
    //   );
    // });

    _eventController.add(ShowWidgetEvent(WidgetType.live, url));

    return true;
  }

  static Map<String, dynamic> genActionData(String jsonString) {
    try {
      final dynamic decoded = jsonDecode(
        jsonString,
        reviver: (key, value) {
          if (value is int) {
            return value.toString();
          }
          return value;
        },
      );
      return decoded as Map<String, dynamic>;
    } catch (e) {
      print("Conversion error: $e");
      return {};
    }
  }

  // TBD: This method wiil be replaced with action trigger
  static Future<Map<String, dynamic>> generateAction(String text) async {
    if (!text.contains(':')) return {};

    final keyword = text.substring(0, text.indexOf(':')).toLowerCase();
    final value = text.substring(text.indexOf(':') + 1).toLowerCase().trim();
    final Map<String, dynamic> actionData = {};

    debugPrint('keyword=$keyword, value=$value');
    if (keyword.contains('volume')) {
      actionData['__K_ACTION_NAME'] = 'homeVolume';

      if (value == 'up' || value == 'down') {
        final currentLevel = await AudioManager.volumeController.getLevel(
          AudioVolumeType.media,
        );
        actionData['level'] =
            (value == 'up' ? currentLevel + 1 : currentLevel - 1).toString();
      } else {
        actionData['level'] = value;
      }
    } else if (keyword.contains('language')) {
      actionData['__K_ACTION_NAME'] = 'homeLanguage';
      if (value == 'english') {
        actionData['language'] = 'en_US';
      } else if (value == 'korean') {
        actionData['language'] = 'ko_KR';
      } else {
        actionData['language'] = value;
      }
    } else if (keyword.contains('device')) {
      actionData['__K_ACTION_NAME'] = 'homeDevice';
      actionData['name'] = value;
    } else if (keyword.contains('feature')) {
      final parts = value.split(' ');
      if (parts.length >= 2) {
        actionData['__K_ACTION_NAME'] = 'homeAdditionalFeature';
        actionData['featureName'] = parts[0];
        actionData['enabled'] = parts[1];
      }
    } else if (keyword.contains('settings')) {
      actionData['__K_ACTION_NAME'] = 'homeSetting';
      actionData['uri'] = value;
    } else if (keyword.contains('wifi')) {
      actionData['__K_ACTION_NAME'] = 'homeWifi';
      actionData['command'] = value;
    } else if (keyword.contains('bluetooth')) {
      actionData['__K_ACTION_NAME'] = 'homeBluetooth';
      actionData['command'] = value;
    } else if (keyword.contains('notification')) {
      actionData['__K_ACTION_NAME'] = 'homeNotification';
      actionData['command'] = value;
    } else if (keyword.contains('run')) {
      actionData['__K_ACTION_NAME'] = 'chat';
    } else if (keyword.contains('live')) {
      actionData['__K_ACTION_NAME'] = 'homeVideo';
      actionData['url'] = ActionModel.actionData[value];
    } else if (keyword.contains('app list')) {
      actionData['__K_ACTION_NAME'] = 'homeApps';

      if (keyword.contains('reorder')) {
      } else if (keyword.contains('filter')) {
        if (keyword.contains('apptype')) {
          actionData['type'] = value;
        } else {
          actionData['app_name'] = value;
        }
      } else if (keyword.contains('reorder')) {
        actionData['sort'] = value;
      }
    }
    return actionData;
  }
}
