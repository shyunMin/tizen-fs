import 'dart:async';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tizen_interop/9.0/tizen.dart';

import 'tizen_bluetooth_manager_type.dart';

typedef BtHidHostConnectionStateChangedCallback =
    void Function(int, bool, String);

class TizenBluetoothHidHostManager {

  static final methodChannel = const MethodChannel('tizen/bluetooth_hid_host');

  // int bt_hid_host_initialize (bt_hid_host_connection_state_changed_cb connection_cb, void *user_data)
  // int bt_hid_host_deinitialize (void)

  static const EventChannel _hidHostConnectionStateChangedEventChannel =
      EventChannel('tizen/bluetooth/hid_host_connection_state_changed');

  static late StreamSubscription<ConnectionInfo>?
  _hidHostConnectionStateChangedSubscription;

  static late BtHidHostConnectionStateChangedCallback?
  _btHidHostConnectionStateChangedCallback;

  static Stream<ConnectionInfo> get hidHostConnectionStateChangedStream =>
      _hidHostConnectionStateChangedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => ConnectionInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static void btInitialize(BtHidHostConnectionStateChangedCallback callback) {
    _btHidHostConnectionStateChangedCallback = callback;
    methodChannel.invokeMethod<String>('init_bt_hid_host_initialize');

    _hidHostConnectionStateChangedSubscription =
        hidHostConnectionStateChangedStream.listen((ConnectionInfo info) {
          debugPrint(
            'call btHidHostConnectionStateChangedCallback result ${info.result}',
          );
          if (_btHidHostConnectionStateChangedCallback != null) {
            _btHidHostConnectionStateChangedCallback!(
              info.result,
              info.connected,
              info.remoteAddress,
            );
          }
        });
  }

  static int btDeinitialize() {
    int ret = tizen.bt_hid_host_deinitialize();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_hid_host_deinitialize. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
      return ret;
    }

    _hidHostConnectionStateChangedSubscription?.cancel();
    _hidHostConnectionStateChangedSubscription = null;
    _btHidHostConnectionStateChangedCallback = null;

    return ret;
  }

  static int btConnect(String remoteAddress) {
    final int ret = using((Arena arena) {
      final int connectResult = tizen.bt_hid_host_connect(
        remoteAddress.toNativeChar(allocator: arena),
      );
      if (connectResult != 0) {
        debugPrint(
          'Failed to bt_hid_host_connect. Error code: ${tizen.get_error_message(connectResult).toDartString()}',
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
      final int ret = tizen.bt_hid_host_disconnect(
        remoteAddress.toNativeChar(allocator: arena),
      );
      return ret;
    });
    if (ret != 0) {
      debugPrint(
        'Failed to bt_hid_host_connect. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }
}
