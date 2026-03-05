import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tizen_interop/9.0/tizen.dart';

import 'tizen_bluetooth_manager_type.dart';

typedef BtHidDeviceConnectionStateChangedCallback =
    void Function(int, bool, String);

class TizenBluetoothHidDeviceManager {

  static final methodChannel = const MethodChannel(
    'tizen/bluetooth_hid_device',
  );

  // int bt_hid_device_deactivate (bt_hid_Device_connection_state_changed_cb connection_cb, void *user_data)
  // int bt_hid_Device_deinitialize (void)

  static const EventChannel _hidDeviceConnectionStateChangedEventChannel =
      EventChannel('tizen/bluetooth/hid_device_connection_state_changed');

  static late StreamSubscription<ConnectionInfo>?
  _hidDeviceConnectionStateChangedSubscription;

  static late BtHidDeviceConnectionStateChangedCallback?
  _btHidDeviceConnectionStateChangedCallback;

  static Stream<ConnectionInfo> get hidDeviceConnectionStateChangedStream =>
      _hidDeviceConnectionStateChangedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => ConnectionInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static void btActivate(BtHidDeviceConnectionStateChangedCallback callback) {
    _btHidDeviceConnectionStateChangedCallback = callback;
    methodChannel.invokeMethod<String>('init_bt_hid_device_activate');

    _hidDeviceConnectionStateChangedSubscription =
        hidDeviceConnectionStateChangedStream.listen((ConnectionInfo info) {
          debugPrint(
            'call btHidDeviceConnectionStateChangedCallback result ${info.result}',
          );
          if (_btHidDeviceConnectionStateChangedCallback != null) {
            _btHidDeviceConnectionStateChangedCallback!(
              info.result,
              info.connected,
              info.remoteAddress,
            );
          }
        });
  }

  static int btDeactivate() {
    int ret = tizen.bt_hid_device_deactivate();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_hid_device_deactivate. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _hidDeviceConnectionStateChangedSubscription?.cancel();
    _hidDeviceConnectionStateChangedSubscription = null;
    _btHidDeviceConnectionStateChangedCallback = null;
    return ret;
  }

  static int btConnect(String remoteAddress) {
    final int ret = using((Arena arena) {
      final int connectResult = tizen.bt_hid_device_connect(
        remoteAddress.toNativeChar(allocator: arena),
      );
      if (connectResult != 0) {
        debugPrint(
          'Failed to bt_hid_device_connect. Error code: ${tizen.get_error_message(connectResult).toDartString()}',
        );
      }
      return connectResult;
    });
    if (ret != 0) {
      debugPrint('Failed to btConnect.');
    }
    return ret;
  }

  static int btDisconnect(String remoteAddress) {
    final int ret = using((Arena arena) {
      final int ret = tizen.bt_hid_device_disconnect(
        remoteAddress.toNativeChar(allocator: arena),
      );
      return ret;
    });
    if (ret != 0) {
      debugPrint(
        'Failed to bt_hid_device_connect. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }
}
