import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tizen_interop/9.0/tizen.dart';
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';
import 'package:ffi/ffi.dart';

import 'tizen_bluetooth_manager_type.dart';

typedef BtAdapterBondedDeviceCallback = void Function(BluetoothDeviceInfo);
typedef BtAdapterSetStateChangedCallback = void Function(int, int);

typedef BtAdapterDeviceDiscoveryStateChangedCallback =
    void Function(int, int, DeviceDiscoveryInfo);
typedef BtDeviceSetBondCreatedCallback =
    void Function(int, BluetoothDeviceInfo);

typedef BtDeviceBondDestroyedCallback = void Function(int, String);

class TizenBluetoothManager {
  static final TizenInteropCallbacks tizenBluetoothInteropCallbacks =
      TizenInteropCallbacks();

  static late BtAdapterBondedDeviceCallback _bondedDeviceCallback;

  static final Map<int, BtAdapterSetStateChangedCallback>
  _btAdapterSetStateChangedCallbackCallbacks = {};
  static int _btAdapterSetStateChangedCallbackIdCounter = 0;

  static final methodChannel = const MethodChannel('tizen/bluetooth');

  static int btGetState() {
    return using((Arena arena) {
      final state = arena<Int32>();
      int ret = tizen.bt_adapter_get_state(state);
      if (ret != 0) {
        debugPrint(
          'Failed to get bt adapter state: $ret: ${tizen.get_error_message(ret).toDartString()}',
        );
        return ret;
      }
      return state.value;
    });
  }

  static int btInitialize() {
    int ret = tizen.bt_initialize();
    if (ret != 0) {
      debugPrint(
        'Failed to enable Bluetooth adapter. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btDeinitialize() {
    int ret = tizen.bt_deinitialize();
    if (ret != 0) {
      debugPrint(
        'Failed to enable Bluetooth adapter. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btAdapterEnable() {
    int ret = tizen.bt_adapter_enable();
    if (ret != 0) {
      debugPrint(
        'Failed to enable Bluetooth adapter. Error code: $ret, ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btAdapterDisable() {
    int ret = tizen.bt_adapter_disable();
    if (ret != 0) {
      debugPrint(
        'Failed to disable Bluetooth adapter. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static bool onBtAdapterBondedDeviceCallback(
    Pointer<bt_device_info_s> deviceInfo,
    Pointer<Void> userData,
  ) {
    debugPrint('[Start] onBtAdapterBondedDeviceCallback');

    final BluetoothDeviceInfo bluetoothDeviceInfo =
        BluetoothDeviceInfo.deviceInfoSToBluetoothDeviceInfo(deviceInfo.ref);

    if (_bondedDeviceCallback != null) {
      _bondedDeviceCallback(bluetoothDeviceInfo);
    } else {
      debugPrint('Callback not found.');
    }

    return true;
  }

  static int btAdapterForeachBondedDevice(
    BtAdapterBondedDeviceCallback callback,
  ) {
    _bondedDeviceCallback = callback;

    int ret = tizen.bt_adapter_foreach_bonded_device(
      Pointer.fromFunction<bt_adapter_bonded_device_cbFunction>(
        onBtAdapterBondedDeviceCallback,
        false,
      ),
      nullptr,
    );

    if (ret != 0) {
      final error = tizen.get_error_message(ret).toDartString();
      debugPrint('Failed to bt_adapter_foreach_bonded_device: $error');
    }
    return ret;
  }

  static const EventChannel _deviceDiscoveryStateChangedEventChannel =
      EventChannel('tizen/bluetooth/device_discovery_state_changed');

  static late StreamSubscription<DeviceDiscoveryInfo>?
  _deviceDiscoveryStateChangedSubscription = null;

  static late BtAdapterDeviceDiscoveryStateChangedCallback?
  _btAdapterDeviceDiscoveryStateChangedCallback = null;

  static Stream<DeviceDiscoveryInfo> get deviceDiscoveryStateChangedStream =>
      _deviceDiscoveryStateChangedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => DeviceDiscoveryInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static void btAdapterSetDeviceDiscoveryStateChangedCallback(
    BtAdapterDeviceDiscoveryStateChangedCallback callback,
  ) {
    _btAdapterDeviceDiscoveryStateChangedCallback = callback;
    methodChannel.invokeMethod<String>(
      'init_device_discovery_state_changed_cb',
    );
  }

  static int btAdapterUnsetDeviceDiscoveryStateChangedCallback() {
    int ret = tizen.bt_adapter_unset_device_discovery_state_changed_cb();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_adapter_unset_device_discovery_state_changed_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _deviceDiscoveryStateChangedSubscription?.cancel();
    _deviceDiscoveryStateChangedSubscription = null;
    _btAdapterDeviceDiscoveryStateChangedCallback = null;
    return ret;
  }

  static int btAdapterStartDeviceDiscovery() {
    if (_btAdapterDeviceDiscoveryStateChangedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    _deviceDiscoveryStateChangedSubscription = deviceDiscoveryStateChangedStream
        .listen((DeviceDiscoveryInfo info) {
          debugPrint(
            'call _btAdapterDeviceDiscoveryStateChangedCallback result ${info.result} state ${info.state}',
          );
          if (_btAdapterDeviceDiscoveryStateChangedCallback != null) {
            _btAdapterDeviceDiscoveryStateChangedCallback!(
              info.result,
              info.state,
              info,
            );
            if (info.state == 1) {
              _deviceDiscoveryStateChangedSubscription?.cancel();
            }
          }
        });

    int ret = tizen.bt_adapter_start_device_discovery();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_adapter_start_device_discovery. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btAdapterStopDeviceDiscovery() {
    if (_btAdapterDeviceDiscoveryStateChangedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    int ret = tizen.bt_adapter_stop_device_discovery();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_adapter_stop_device_discovery. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static void onBtAdapterSetStateChangedCallback(
    int result,
    int state,
    Pointer<Void> userData,
  ) {
    debugPrint('CalledonBtAdapterSetStateChangedCallback');

    final callbackId = TizenInteropCallbacks.getUserObject<int>(userData)!;

    final BtAdapterSetStateChangedCallback? callback =
        _btAdapterSetStateChangedCallbackCallbacks[callbackId];

    if (callback != null) {
      callback(result, state);
    } else {
      debugPrint('Callback not found for id: $callbackId');
    }

    return;
  }

  static int btAdapterSetStateChangedCallback(
    BtAdapterSetStateChangedCallback callback,
  ) {
    final callbackId = _btAdapterSetStateChangedCallbackIdCounter++;
    _btAdapterSetStateChangedCallbackCallbacks[callbackId] = callback;

    final stateChangedCallback = tizenBluetoothInteropCallbacks
        .register<bt_adapter_state_changed_cbFunction>(
          'bt_adapter_state_changed_cb',
          Pointer.fromFunction(onBtAdapterSetStateChangedCallback),
          userObject: callbackId,
          blocking: false,
        );
    int ret = tizen.bt_adapter_set_state_changed_cb(
      stateChangedCallback.interopCallback,
      stateChangedCallback.interopUserData,
    );

    if (ret != 0) {
      _btAdapterSetStateChangedCallbackCallbacks.remove(callbackId);
      debugPrint(
        'Failed to bt_adapter_set_state_changed_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btAdapterUnsetStateChangedCallback() {
    int ret = tizen.bt_adapter_unset_state_changed_cb();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_adapter_unset_state_changed_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _btAdapterSetStateChangedCallbackIdCounter = 0;
    _btAdapterSetStateChangedCallbackCallbacks.clear();
    return ret;
  }

  // [bt_device_create_bond]
  // [bt_device_set_bond_create_cb]
  // [bt_device_unset_bond_create_cb]

  static const EventChannel _deviceSetBondCreatedEventChannel = EventChannel(
    'tizen/bluetooth/device_bond_created',
  );

  static late StreamSubscription<BluetoothDeviceInfo>?
  _deviceSetBondCreatedSubscription;

  static late BtDeviceSetBondCreatedCallback? _btDeviceSetBondCreatedCallback;

  static Stream<BluetoothDeviceInfo> get deviceBondCreatedStream =>
      _deviceSetBondCreatedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => BluetoothDeviceInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static int btDeviceCreateBond(String remoteAddress) {
    if (_btDeviceSetBondCreatedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    _deviceSetBondCreatedSubscription = deviceBondCreatedStream.listen((
      BluetoothDeviceInfo info,
    ) {
      if (_btDeviceSetBondCreatedCallback != null) {
        _btDeviceSetBondCreatedCallback!(info.result, info);
      }
    });

    final int ret = using((Arena arena) {
      final int ret = tizen.bt_device_create_bond(
        remoteAddress.toNativeChar(allocator: arena),
      );
      return ret;
    });
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_create_bond. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static void btDeviceSetBondCreatedCallback(
    BtDeviceSetBondCreatedCallback callback,
  ) {
    _btDeviceSetBondCreatedCallback = callback;
    methodChannel.invokeMethod<String>('init_bt_device_set_bond_created_cb');
  }

  static int btDeviceUnsetBondCreatedCallback() {
    int ret = tizen.bt_device_unset_bond_created_cb();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_unset_bond_created_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _deviceSetBondCreatedSubscription?.cancel();
    _deviceSetBondCreatedSubscription = null;
    _btDeviceSetBondCreatedCallback = null;
    return ret;
  }

  // [bt_device_destroy_bond]
  // [bt_device_set_bond_destroyed_cb]
  // [bt_device_unset_bond_destroyed_cb]

  static const EventChannel _deviceSetBondDestroyedEventChannel = EventChannel(
    'tizen/bluetooth/device_bond_destroyed',
  );

  static late StreamSubscription<BluetoothDeviceInfo>?
  _deviceSetBondDestroyedSubscription;

  static late BtDeviceBondDestroyedCallback? _btDeviceSetBondDestroyedCallback;

  static Stream<BluetoothDeviceInfo> get deviceBondDestroyedStream =>
      _deviceSetBondDestroyedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => BluetoothDeviceInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static int btDeviceDestroyBond(String remoteAddress) {
    if (_btDeviceSetBondDestroyedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    _deviceSetBondDestroyedSubscription = deviceBondDestroyedStream.listen((
      BluetoothDeviceInfo info,
    ) {
      debugPrint(
        'call _btDeviceSetBondDestroyedCallback result ${info.result}',
      );
      if (_btDeviceSetBondDestroyedCallback != null) {
        _btDeviceSetBondDestroyedCallback!(info.result, info.remoteAddress);
      }
    });

    final int ret = using((Arena arena) {
      final int ret = tizen.bt_device_destroy_bond(
        remoteAddress.toNativeChar(allocator: arena),
      );
      return ret;
    });
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_destroy_bond. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static void btDeviceSetBondDestroyedCallback(
    BtDeviceBondDestroyedCallback callback,
  ) {
    _btDeviceSetBondDestroyedCallback = callback;
    methodChannel.invokeMethod<String>('init_bt_device_set_bond_destroyed_cb');
  }

  static int btDeviceUnsetBondDestroyedCallback() {
    int ret = tizen.bt_device_unset_bond_destroyed_cb();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_unset_bond_destroyed_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _deviceSetBondDestroyedSubscription?.cancel();
    _deviceSetBondDestroyedSubscription = null;
    _btDeviceSetBondDestroyedCallback = null;
    return ret;
  }

  static int btDeviceCancelBonding() {
    int ret = tizen.bt_device_cancel_bonding();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_cancel_bonding. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btDeviceSetAlias(String remoteAddress, String alias) {
    final int ret = using((Arena arena) {
      final int ret = tizen.bt_device_set_alias(
        remoteAddress.toNativeChar(allocator: arena),
        alias.toNativeChar(allocator: arena),
      );
      return ret;
    });
    if (ret != 0) {
      debugPrint(
        'Failed to bt_device_set_alias. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }
}
