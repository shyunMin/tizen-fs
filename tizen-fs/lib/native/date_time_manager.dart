import 'package:flutter/widgets.dart';
import 'package:tizen_fs/native/vconf.dart';
import 'dart:ffi';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:tizen_interop/9.0/tizen.dart' as tizen;
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

final DynamicLibrary _alarmLib = DynamicLibrary.open(
  'libcapi-appfw-alarm.so.0',
);

typedef _AlarmSetSystimeNative = Int32 Function(Int64 timestamp);
typedef _AlarmSetSystimeDart = int Function(int timestamp);

class DateTimeManager {
  static const String vconfAutoDateTimeUpdate =
      "db/setting/automatic_time_update";
  static const String vconfTimeFormat = "db/menu_widget/regionformat_time1224";
  static const String vconfTimezoneId = "db/setting/timezone_id";

  static final List<String> popularTimezones = [
    'Asia/Seoul',
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Hong_Kong',
    'Asia/Singapore',
    'Australia/Sydney',
    'Pacific/Auckland',
    'America/Toronto',
    'America/Vancouver',
    'Europe/Moscow',
    'Asia/Dubai',
    'America/Mexico_City',
    'America/Sao_Paulo',
    'Asia/Kolkata',
  ];

  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();
  static void Function(String)? _onTimezoneChanged;
  late final timezoneChangedCallback;

  DateTimeManager() {
    _registerCallbacks();
    _setSystemCallback();
    _initizlizeTimezone();
  }

  void _registerCallbacks() {
    timezoneChangedCallback = _callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'system_settings_changed_cb',
          Pointer.fromFunction(_timezoneChangedHandler),
        );
  }

  void _setSystemCallback() {
    final result = tizen.tizen.system_settings_set_changed_cb(
      tizen.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_TIMEZONE,
      timezoneChangedCallback.interopCallback,
      timezoneChangedCallback.interopUserData,
    );
    if (result != 0)
      debugPrint(
        "[DateTimeManager] Error in system_settings_set_changed_cb: $result",
      );
  }

  void _unsetSystemCallback() {
    final result = tizen.tizen.system_settings_unset_changed_cb(
      tizen.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_TIMEZONE,
    );
    if (result != 0)
      debugPrint(
        "[DateTimeManager] Error in system_settings_unset_changed_cb: $result",
      );
  }

  void setTimezoneChangedListener(void Function(String) callback) {
    _onTimezoneChanged = callback;
  }

  void removeTimezoneChangedListener() {
    _onTimezoneChanged = null;
  }

  static void _timezoneChangedHandler(int key, Pointer<Void> userData) {
    try {
      String? currentTimezone = Vconf.getString(vconfTimezoneId);
      if (currentTimezone == null) {
        debugPrint("[DateTimeManager] Failed to get currentTimezone");
        return;
      }

      if (_onTimezoneChanged != null) {
        _onTimezoneChanged!(currentTimezone);
      }
    } catch (e) {
      debugPrint(
        "[DateTimeManager] Error in removeTimezoneChangedListener: $e",
      );
    }
  }

  void dispose() {
    _unsetSystemCallback();
    removeTimezoneChangedListener();
  }

  static bool get isAutoUpdated =>
      Vconf.getBool(vconfAutoDateTimeUpdate) ?? false;
  static bool get is24HourFormat => Vconf.getBool(vconfTimeFormat) ?? true;
  static String get currentTimezone =>
      Vconf.getString(vconfTimezoneId) ?? "error";
  static DateTime get currentDateTime => DateTime.now();

  static bool _initialized = false;
  static List<String> _availableTimezones = [];

  void _initizlizeTimezone() {
    tz.initializeTimeZones();
    _initialized = true;
    _availableTimezones = getAvailableTimezones();
  }

  List<String> getAvailableTimezones() {
    var allTimezones = tz.timeZoneDatabase.locations;
    return allTimezones.keys.toList();
  }

  List<String> getPopularTimezones() {
    if (!_initialized) _initizlizeTimezone();
    List<String> popularTimezonesList = [];
    for (String timezoneId in popularTimezones) {
      if (_availableTimezones.contains(timezoneId)) {
        popularTimezonesList.add(timezoneId);
      }
    }
    return popularTimezonesList;
  }

  static bool setAutoUpdate(bool value) {
    if (isAutoUpdated != value) {
      var ret = Vconf.setBool(vconfAutoDateTimeUpdate, value);
      return ret == 0;
    }
    return true;
  }

  static bool setTimeFormat(bool is24Hour) {
    if (is24HourFormat != is24Hour) {
      var ret = Vconf.setBool(vconfTimeFormat, is24Hour);
      return ret == 0;
    }
    return true;
  }

  static bool setTimezone(String newTimezone) {
    if (currentTimezone != newTimezone) {
      var ret = Vconf.setString(vconfTimezoneId, newTimezone);

      if (ret == 0) {
        tz.initializeTimeZones();
        var location = tz.getLocation(newTimezone);
        var dt = tz.TZDateTime.now(location);
        setManualDateTime(
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute),
        );
      }
      return ret == 0;
    }
    return true;
  }

  static final _AlarmSetSystimeDart _alarmSetSystime = _alarmLib
      .lookupFunction<_AlarmSetSystimeNative, _AlarmSetSystimeDart>(
        'alarm_set_systime',
      );

  static bool setManualDateTime(DateTime dateTime) {
    try {
      final int timestamp = dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
      final int result = _alarmSetSystime(timestamp);

      if (result == 0) return true;
      return false;
    } catch (e) {
      debugPrint("[DateTimeManager] Error in setManualDateTime: $e");
      return false;
    }
  }

  static String formatTime(DateTime? time) {
    if (time == null) time = currentDateTime;
    if (is24HourFormat) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      int hour = time.hour % 12;
      if (hour == 0) hour = 12;
      String period = time.hour >= 12 ? "PM" : "AM";
      return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
    }
  }

  static String formatDate(DateTime? date) {
    if (date == null) date = currentDateTime;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static bool get isSupported {
    try {
      return Vconf.getBool(vconfAutoDateTimeUpdate) != null;
    } catch (e) {
      return false;
    }
  }
}
