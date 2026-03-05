import 'package:flutter/foundation.dart';
import 'package:device_info_plus_tizen/device_info_plus_tizen.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:tizen_interop/9.0/tizen.dart' as tz;
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/native/vconf.dart';

int _fetchNativeSystemInfo(dynamic _) {
  return using((Arena arena) {
    final pMemInfo = arena<tz.runtime_memory_info_s>();
    if (tz.tizen.runtime_info_get_system_memory_info(pMemInfo) == 0) {
      return pMemInfo.ref.total;
    }
    return -1;
  });
}

class DeviceInfoItem extends ChangeNotifier implements ItemDisplayInterface {
  final String _key;
  String _value;
  final bool _isSelectable;

  DeviceInfoItem({
    required String key,
    required String value,
    bool isSelectable = true,
  }) : _key = key,
       _value = value,
       _isSelectable = isSelectable;

  String get key => _key;

  String get value => _value;

  set value(String newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  @override
  String get displayText => _key;

  @override
  String? get displaySubText => _value;

  @override
  Object? get iconSourceData => null;

  @override
  IconSourceType get iconSourceType => IconSourceType.none;

  @override
  bool get isSelectable => _isSelectable;
}

class DeviceInfoProvider with ChangeNotifier {
  TizenDeviceInfo? _tizenDeviceInfo;
  TizenDeviceInfo? get tizenDeviceInfo => _tizenDeviceInfo;
  int _ram = -1;
  int get ram => _ram;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  Object? _error;
  Object? get error => _error;
  bool _isDisposed = false;
  DeviceInfoPluginTizen? _plugin;

  final List<DeviceInfoItem> _deviceInfoItems = [];
  List<DeviceInfoItem> get deviceInfoItems => _deviceInfoItems;

  DeviceInfoProvider() {
    _initializeWithLoadingState();
  }

  void _initializeWithLoadingState() {
    _deviceInfoItems.clear();
    _deviceInfoItems.addAll([
      DeviceInfoItem(key: 'deviceName', value: 'loading'),
      DeviceInfoItem(key: 'model', value: 'loading'),
      DeviceInfoItem(
        key: 'tizenVersion',
        value: 'loading',
        isSelectable: false,
      ),
      DeviceInfoItem(key: 'cpu', value: 'loading'),
      DeviceInfoItem(key: 'ram', value: 'loading'),
      DeviceInfoItem(key: 'resolution', value: 'loading'),
      DeviceInfoItem(key: 'buildId', value: 'loading'),
    ]);
  }

  Future<void> loadDeviceInfo() async {
    if (_isDisposed) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_isDisposed) return;
      _ram = await compute(_fetchNativeSystemInfo, null);
      if (_isDisposed) return;
      _plugin ??= DeviceInfoPluginTizen();
      _tizenDeviceInfo = await _plugin!.tizenInfo;
      _updateDeviceInfoItems();
    } catch (e) {
      if (!_isDisposed) {
        _error = e;
        _tizenDeviceInfo = null;
        _ram = -1;
        _updateWithErrorState(e.toString());
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _updateDeviceInfoItems() {
    _deviceInfoItems.clear();
    final info = _tizenDeviceInfo;
    final width = info?.screenWidth ?? 1;
    final height = info?.screenHeight ?? 1;

    // Read device name from vconf
    final deviceNameKey = 'db/setting/device_name';
    final deviceName = Vconf.getString(deviceNameKey) ?? 'unknown';

    _deviceInfoItems.addAll([
      DeviceInfoItem(key: 'deviceName', value: deviceName),
      DeviceInfoItem(key: 'model', value: info?.modelName ?? 'unknown'),
      DeviceInfoItem(
        key: 'tizenVersion',
        value: info?.platformVersion ?? 'unknown',
      ),
      DeviceInfoItem(key: 'cpu', value: info?.platformProcessor ?? 'unknown'),
      DeviceInfoItem(
        key: 'ram',
        value:
            _ram > 0
                ? '${(_ram / (1024 * 1024)).toStringAsFixed(1)}GB'
                : 'unknown',
      ),
      DeviceInfoItem(
        key: 'resolution',
        value:
            width > 0 && height > 0
                ? '${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}'
                : 'unknown',
      ),
      DeviceInfoItem(key: 'buildId', value: info?.buildString ?? 'unknown'),
    ]);
  }

  void _updateWithErrorState(String errorMessage) {
    _deviceInfoItems.clear();
    _deviceInfoItems.addAll([
      DeviceInfoItem(key: 'name', value: 'error'),
      DeviceInfoItem(key: 'model', value: 'error'),
      DeviceInfoItem(key: 'tizenVersion', value: 'error'),
      DeviceInfoItem(key: 'cpu', value: 'error'),
      DeviceInfoItem(key: 'ram', value: 'error'),
      DeviceInfoItem(key: 'resolution', value: 'error'),
      DeviceInfoItem(key: 'buildId', value: errorMessage),
    ]);
  }

  Future<bool> isEmulator() async {
    await loadDeviceInfo();
    final model =
        _deviceInfoItems.where((item) => item.key == 'model').first.value;
    if (model.toLowerCase().contains('emulator')) {
      return true;
    }
    return false;
  }

  /// Update the device name using vconf.setString API
  void updateDeviceName(String newName) {
    try {
      final key = 'db/setting/device_name';
      final result = Vconf.setString(key, newName);

      if (!result) {
        debugPrint('Failed to update device name');
        return;
      }

      // Update the device name in the items list
      if (_deviceInfoItems.isNotEmpty) {
        _deviceInfoItems[0].value = newName;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating device name: $e');
      _error = e;
    }
  }

  Future<void> refreshDeviceInfo() async {
    if (_isDisposed) return;
    _tizenDeviceInfo = null;
    _ram = -1;
    _error = null;
    await loadDeviceInfo();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _plugin = null;
    _tizenDeviceInfo = null;
    _ram = -1;
    _error = null;
    _isLoading = false;
    _deviceInfoItems.clear();
    super.dispose();
  }
}
