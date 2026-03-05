import 'dart:ffi';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_interop/9.0/tizen.dart' as tz;
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';

class WifiManager {
  static late final Pointer<Pointer<Void>> wifiManagerHandle;

  static final callbacks = TizenInteropCallbacks();
  bool _initialized = false;
  bool get initialized => _initialized;
  bool _isSupported = true;
  bool get isSupported => _isSupported;

  static List<WifiAP> _apList = [];
  List<WifiAP> get apList => _apList;

  static List<WifiAP> _specificApList = [];
  List<WifiAP> get specificApList => _specificApList;

  static Function(int result)? onActivated;
  static Function(int result)? onDeactivated;
  static Function(int result)? onScanFinished;
  static Function(int result)? onConnected;
  static Function(int result)? onDisconnected;

  static Function(int state)? onDeviceStateChanged;
  static Function(int state)? onScanStateChanged;
  static Function(int state)? onBackgroundScan;
  static Function(int state)? onConnectionStateChanged;
  static Function(int state)? onRssiLevelChanged;

  late final activatedCallack;
  late final deactivatedCallack;
  late final scanFinishedCallback;
  late final foreachFoundApCallback;
  late final connectedCallback;
  late final disconnectedCallback;

  late final deviceStateChangedCallback;
  late final scanStateChangedCallback;
  late final backgroundScanCallback;
  late final connectionStateChangedCallback;
  late final rssiLevelChangedCallback;

  void init() {
    if (_initialized) return;

    _initialized = initializeWifi();
    registerCallbacks();
    setCallbacks();
  }

  void dispose() {
    if (_initialized) {
      unsetCallbacks();

      callbacks.unregister(activatedCallack);
      callbacks.unregister(deactivatedCallack);
      callbacks.unregister(scanFinishedCallback);
      callbacks.unregister(foreachFoundApCallback);
      callbacks.unregister(connectedCallback);
      callbacks.unregister(disconnectedCallback);

      callbacks.unregister(deviceStateChangedCallback);
      callbacks.unregister(scanStateChangedCallback);
      callbacks.unregister(backgroundScanCallback);
      callbacks.unregister(connectionStateChangedCallback);
      callbacks.unregister(rssiLevelChangedCallback);

      tz.tizen.wifi_manager_deinitialize(wifiManagerHandle.value);
      calloc.free(wifiManagerHandle);

      _clearStaticResources();

      _initialized = false;
    }
  }

  bool initializeWifi() {
    if (_initialized) {
      return _initialized;
    }

    wifiManagerHandle = calloc<tz.wifi_manager_h>();
    final ret = tz.tizen.wifi_manager_initialize(wifiManagerHandle);
    if (ret == tz.wifi_manager_error_e.WIFI_MANAGER_ERROR_NOT_SUPPORTED) {
      _isSupported = false;
    }
    return ret == 0;
  }

  void setCallbacks() {
    setDeviceStateChangedCallback();
    setScanStateChangedCallback();
    setBackgroundScanCallback();
    setConnectionStateChangedCallback();
    setRssiLevelChangedCallback();
  }

  void unsetCallbacks() {
    unsetDeviceStateChangedCallback();
    unsetScanStateChangedCallback();
    unsetBackgroundScanCallback();
    unsetConnectionStateChangedCallback();
    unsetRssiLevelChangedCallback();
  }

  static void _clearStaticResources() {
    onActivated = null;
    onDeactivated = null;
    onScanFinished = null;
    onConnected = null;
    onDisconnected = null;
    onDeviceStateChanged = null;
    onScanStateChanged = null;
    onBackgroundScan = null;
    onConnectionStateChanged = null;
    onRssiLevelChanged = null;
    _apList.clear();
    // _specificApList.clear();
  }

  static void _deviceStateChangedCallback(int state, Pointer<Void> user_data) {
    //activated / deactivated
    onDeviceStateChanged?.call(state);
  }

  int setDeviceStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_set_device_state_changed_cb(
      wifiManagerHandle.value,
      deviceStateChangedCallback.interopCallback,
      deviceStateChangedCallback.interopUserData,
    );
    return ret;
  }

  int unsetDeviceStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_unset_device_state_changed_cb(
      wifiManagerHandle.value,
    );
    return ret;
  }

  static void _scanStateChangedCallback(int state, Pointer<Void> user_data) {
    onScanStateChanged?.call(state);
  }

  int setScanStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_set_scan_state_changed_cb(
      wifiManagerHandle.value,
      scanStateChangedCallback.interopCallback,
      scanStateChangedCallback.interopUserData,
    );
    return ret;
  }

  int unsetScanStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_unset_scan_state_changed_cb(
      wifiManagerHandle.value,
    );
    return ret;
  }

  static void _backgroundScanCallback(int state, Pointer<Void> user_data) {
    onBackgroundScan?.call(state);
  }

  int setBackgroundScanCallback() {
    final ret = tz.tizen.wifi_manager_set_background_scan_cb(
      wifiManagerHandle.value,
      backgroundScanCallback.interopCallback,
      backgroundScanCallback.interopUserData,
    );
    //scan by bg
    return ret;
  }

  int unsetBackgroundScanCallback() {
    final ret = tz.tizen.wifi_manager_unset_background_scan_cb(
      wifiManagerHandle.value,
    );
    return ret;
  }

  static void _connectionStateChangedCallback(
    int state,
    Pointer<Void> user_data,
  ) {
    //connection state changed in ap list
    //0:disconnect 3:connect
    onConnectionStateChanged?.call(state);
  }

  int setConnectionStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_set_connection_state_changed_cb(
      wifiManagerHandle.value,
      connectionStateChangedCallback.interopCallback,
      connectionStateChangedCallback.interopUserData,
    );

    return ret;
  }

  int unsetConnectionStateChangedCallback() {
    final ret = tz.tizen.wifi_manager_unset_connection_state_changed_cb(
      wifiManagerHandle.value,
    );
    return ret;
  }

  static void _rssiLevelChangedCallback(int state, Pointer<Void> user_data) {
    //4:very_strong(-63), 3:strong(-74), 2:weak(-82), 1:very_weak 0:no_signal
    onRssiLevelChanged?.call(state);
  }

  int setRssiLevelChangedCallback() {
    final ret = tz.tizen.wifi_manager_set_rssi_level_changed_cb(
      wifiManagerHandle.value,
      rssiLevelChangedCallback.interopCallback,
      rssiLevelChangedCallback.interopUserData,
    );
    return ret;
  }

  int unsetRssiLevelChangedCallback() {
    final ret = tz.tizen.wifi_manager_unset_rssi_level_changed_cb(
      wifiManagerHandle.value,
    );
    return ret;
  }

  void registerCallbacks() {
    deviceStateChangedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_device_state_changed_cb',
          Pointer.fromFunction(_deviceStateChangedCallback),
        );
    scanStateChangedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_scan_state_changed_cb',
          Pointer.fromFunction(_scanStateChangedCallback),
        );
    backgroundScanCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_scan_finished_cb',
          Pointer.fromFunction(_backgroundScanCallback),
        );
    connectionStateChangedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_connection_state_changed_cb',
          Pointer.fromFunction(_connectionStateChangedCallback),
        );
    rssiLevelChangedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_rssi_level_changed_cb',
          Pointer.fromFunction(_rssiLevelChangedCallback),
        );

    activatedCallack = callbacks.register<Void Function(Int32, Pointer<Void>)>(
      'wifi_manager_activated_cb',
      Pointer.fromFunction(_activatedCallback),
    );

    deactivatedCallack = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_deactivated_cb',
          Pointer.fromFunction(_deactivatedCallback),
        );

    scanFinishedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_scan_finished_cb',
          Pointer.fromFunction(_scanFinishedCallback),
        );

    foreachFoundApCallback = callbacks
        .register<Bool Function(Pointer<Void>, Pointer<Void>)>(
          'wifi_manager_found_ap_cb',
          Pointer.fromFunction(_foreachFoundApCallback, false),
        );

    connectedCallback = callbacks.register<Void Function(Int32, Pointer<Void>)>(
      'wifi_manager_connected_cb',
      Pointer.fromFunction(_connectedCallback),
    );

    disconnectedCallback = callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'wifi_manager_disconnected_cb',
          Pointer.fromFunction(_disconnectedCallback),
        );
  }

  bool isActivated() {
    final activated = calloc<Bool>();
    try {
      final ret = tz.tizen.wifi_manager_is_activated(
        wifiManagerHandle.value,
        activated,
      );

      var result = false;
      if (ret == 0) {
        result = activated.value;
      }
      //debugPrint("@ Wi-Fi Native isActivated=[${result}]");
      return result;
    } finally {
      calloc.free(activated);
    }
  }

  static void _activatedCallback(int result, Pointer<Void> user_data) {
    onActivated?.call(result);
  }

  Future<void> activate() async {
    var ret = await tz.tizen.wifi_manager_activate(
      wifiManagerHandle.value,
      activatedCallack.interopCallback,
      activatedCallack.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to activate wifi manager: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  static void _deactivatedCallback(int result, Pointer<Void> user_data) {
    onDeactivated?.call(result);
  }

  Future<void> deactivate() async {
    final ret = await tz.tizen.wifi_manager_deactivate(
      wifiManagerHandle.value,
      deactivatedCallack.interopCallback,
      deactivatedCallack.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to deactivate wifi manager: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  static void _scanFinishedCallback(int error_code, Pointer<Void> user_data) {
    onScanFinished?.call(error_code);
  }

  void scan() {
    final ret = tz.tizen.wifi_manager_scan(
      wifiManagerHandle.value,
      scanFinishedCallback.interopCallback,
      scanFinishedCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to scan ap: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  String findIdByHandle(Pointer<Void> apHandle) {
    Pointer<Pointer<Char>> essid = calloc<Pointer<Char>>();
    try {
      var ret = tz.tizen.wifi_manager_ap_get_essid(apHandle, essid);
      String id = "";
      if (ret == 0) {
        id = essid.value.toDartString();
      }
      return id;
    } finally {
      calloc.free(essid);
    }
  }

  static bool _foreachFoundApCallback(
    Pointer<Void> ap,
    Pointer<Void> user_data,
  ) {
    if (ap == nullptr) return false;

    Pointer<Pointer<Char>> id = calloc<Pointer<Char>>();
    Pointer<Int32> state = calloc<Int32>();
    Pointer<Int> frequency = calloc<Int>();
    Pointer<Int> rssi = calloc<Int>();
    Pointer<Int32> securityType = calloc<Int32>();
    Pointer<Bool> isPassphraseRequired = calloc<Bool>();
    Pointer<Bool> isWpsSupported = calloc<Bool>();

    try {
      var ret = tz.tizen.wifi_manager_ap_get_essid(ap, id);
      if (ret != 0) {
        debugPrint(
          'Failed to get essid: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_get_connection_state(ap, state);
      if (ret != 0) {
        debugPrint(
          'Failed to get connection state: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_get_frequency(ap, frequency);
      if (ret != 0) {
        debugPrint(
          'Failed to get frequency: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_get_rssi(ap, rssi);
      if (ret != 0) {
        debugPrint(
          'Failed to get rssi: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_get_security_type(ap, securityType);
      if (ret != 0) {
        debugPrint(
          'Failed to get security type: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_is_passphrase_required(
        ap,
        isPassphraseRequired,
      );
      if (ret != 0) {
        debugPrint(
          'Failed to get the state whether a passphrase is requried: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      ret = tz.tizen.wifi_manager_ap_is_wps_supported(ap, isWpsSupported);
      if (ret != 0) {
        debugPrint(
          'Failed to get the state whether the ap supports wps: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }

      SecurityType secType = _convertSecurityType(securityType.value);

      _apList.add(
        WifiAP(
          essid: id.value.toDartString(),
          state: state.value,
          frequency: frequency.value,
          rssi: rssi.value,
          handle: ap,
          securityType: secType,
          isPassphraseRequired: isPassphraseRequired.value,
          isWpsSupported: isWpsSupported.value,
        ),
      );
      return true;
    } finally {
      calloc.free(id);
      calloc.free(state);
      calloc.free(frequency);
      calloc.free(rssi);
      calloc.free(securityType);
      calloc.free(isPassphraseRequired);
      calloc.free(isWpsSupported);
    }
  }

  static SecurityType _convertSecurityType(int securityTypeValue) {
    switch (securityTypeValue) {
      case 0: // WIFI_MANAGER_SECURITY_TYPE_NONE
        return SecurityType.none;
      case 1: // WIFI_MANAGER_SECURITY_TYPE_WEP
        return SecurityType.wep;
      case 2: // WIFI_MANAGER_SECURITY_TYPE_WPA_PSK
        return SecurityType.wpaPsk;
      case 3: // WIFI_MANAGER_SECURITY_TYPE_WPA2_PSK
        return SecurityType.wpa2Psk;
      case 4: // WIFI_MANAGER_SECURITY_TYPE_EAP
        return SecurityType.eap;
      default:
        return SecurityType.unknown;
    }
  }

  void updateApList() {
    if (!isActivated()) {
      return;
    }

    _apList.clear();

    final ret = tz.tizen.wifi_manager_foreach_found_ap(
      wifiManagerHandle.value,
      foreachFoundApCallback.interopCallback,
      foreachFoundApCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to find ap: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  Pointer<Void> getConnectedApHandle() {
    final ap = calloc<tz.wifi_manager_ap_h>();
    try {
      final ret = tz.tizen.wifi_manager_get_connected_ap(
        wifiManagerHandle.value,
        ap,
      );
      if (ret != 0) {
        debugPrint(
          'Failed to get connected ap: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
        );
      }
      var result = ap.value;
      return result;
    } finally {
      calloc.free(ap);
    }
  }

  bool passphraseRequired(Pointer<Void> apHandle) {
    Pointer<Bool> isRequired = calloc<Bool>();
    try {
      final ret = tz.tizen.wifi_manager_ap_is_passphrase_required(
        apHandle,
        isRequired,
      );
      bool result = false;
      if (ret == 0 && isRequired.value == true) result = true;
      return result;
    } finally {
      calloc.free(isRequired);
    }
  }

  bool setPassphrase(Pointer<Void> ap, String passphrase) {
    var password = passphrase.toNativeChar();
    try {
      final ret = tz.tizen.wifi_manager_ap_set_passphrase(ap, password);
      bool result = false;
      if (ret == 0) result = true;
      return result;
    } finally {
      calloc.free(password);
    }
  }

  Pointer<Void> findHandleByName(String name) {
    Pointer<Void> handle = nullptr;
    for (var ap in apList) {
      if (ap.essid == name) {
        return ap.handle;
      }
    }
    return handle;
  }

  static void _connectedCallback(int error_code, Pointer<Void> user_data) {
    onConnected?.call(error_code);
  }

  Future<void> connect(Pointer<Void> apHandle) async {
    final ret = await tz.tizen.wifi_manager_connect(
      wifiManagerHandle.value,
      apHandle,
      connectedCallback.interopCallback,
      connectedCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to connect to wifi: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  static void _disconnectedCallback(int error_code, Pointer<Void> user_data) {
    onDisconnected?.call(error_code);
  }

  Future<void> disconnect(Pointer<Void> apHandle) async {
    final ret = await tz.tizen.wifi_manager_disconnect(
      wifiManagerHandle.value,
      apHandle,
      disconnectedCallback.interopCallback,
      disconnectedCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to disconnect: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  Future<void> scanSpecificAP(String essid) async {
    final ret = await tz.tizen.wifi_manager_scan(
      wifiManagerHandle.value,
      scanFinishedCallback.interopCallback,
      scanFinishedCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to scan specific ap: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    _filterSpecificAP(essid);
  }

  Pointer<Void> findSpecificHandleByName(String name) {
    Pointer<Void> handle = nullptr;
    for (var ap in _specificApList) {
      if (ap.essid == name) {
        return ap.handle;
      }
    }
    return handle;
  }

  void _filterSpecificAP(String targetEssid) {
    _specificApList.clear();
    for (var ap in _apList) {
      if (ap.essid == targetEssid) {
        _specificApList.add(ap);
        break;
      }
    }
  }

  void updateSpecificApList() {
    if (!isActivated()) {
      return;
    }

    _specificApList.clear();

    final ret = tz.tizen.wifi_manager_foreach_found_ap(
      wifiManagerHandle.value,
      foreachFoundApCallback.interopCallback,
      foreachFoundApCallback.interopUserData,
    );
    if (ret != 0) {
      debugPrint(
        'Failed to update specific ap list: ret=$ret, ${tz.tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  Future<bool> forgetNetwork(String essid) async {
    try {
      var apHandle = findHandleByName(essid);

      if (apHandle == nullptr) {
        apHandle = findSpecificHandleByName(essid);
      }

      if (apHandle == nullptr) {
        return false;
      }

      final ret = await tz.tizen.wifi_manager_forget_ap(
        wifiManagerHandle.value,
        apHandle,
      );
      bool result = ret == 0;

      if (result) {
        _specificApList.removeWhere((ap) => ap.essid == essid);
      }

      return result;
    } catch (e) {
      return false;
    }
  }
}
