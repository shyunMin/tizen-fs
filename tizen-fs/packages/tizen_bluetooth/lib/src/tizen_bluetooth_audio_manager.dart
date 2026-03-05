import 'dart:async';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tizen_interop/9.0/tizen.dart';

import 'tizen_bluetooth_manager_type.dart';

typedef BtAudioConnectionStateChangedCallback =
    void Function(int, bool, String, BluetoothAudioProfileType);

class TizenBluetoothAudioManager {

  static final methodChannel = const MethodChannel('tizen/bluetooth_audio');

  static int btInitialize() {
    int ret = tizen.bt_audio_initialize();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_audio_initialize. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btDeinitialize() {
    int ret = tizen.bt_audio_deinitialize();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_audio_deinitialize. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  static int btAudioConnect(
    String remoteAddress,
    BluetoothAudioProfileType type,
  ) {

    if (_btAudioConnectionStateChangedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    _audioConnectionStateChangedSubscription = audioConnectionStateChangedStream
        .listen((AudioConnectionInfo info) {
          debugPrint(
            'call _btDeviceSetBondCreatedCallback result ${info.result}',
          );
          if (_btAudioConnectionStateChangedCallback != null) {
            _btAudioConnectionStateChangedCallback!(
              info.result,
              info.connected,
              info.remoteAddress,
              BluetoothAudioProfileType.values[info.type],
            );
          }
        });

    final int ret = using((Arena arena) {
      final int connectResult = tizen.bt_audio_connect(
        remoteAddress.toNativeChar(allocator: arena),
        type.index,
      );
      if (connectResult != 0) {
        debugPrint(
          'Failed to bt_audio_connect. Error code: ${tizen.get_error_message(connectResult).toDartString()}',
        );
      }
      return connectResult;
    });
    if (ret != 0) {
      debugPrint('Failed to btAudioConnect.');
    }
    return ret;
  }

  static int btAudioDisconnect(
    String remoteAddress,
    BluetoothAudioProfileType type,
  ) {
    
    if (_btAudioConnectionStateChangedCallback == null) {
      debugPrint('No callback');
      return -1;
    }

    _audioConnectionStateChangedSubscription = audioConnectionStateChangedStream
        .listen((AudioConnectionInfo info) {
          debugPrint(
            'call _btDeviceSetBondCreatedCallback result ${info.result}',
          );
          if (_btAudioConnectionStateChangedCallback != null) {
            _btAudioConnectionStateChangedCallback!(
              info.result,
              info.connected,
              info.remoteAddress,
              BluetoothAudioProfileType.values[info.type],
            );
          }
        });

    final int ret = using((Arena arena) {
      final int connectResult = tizen.bt_audio_disconnect(
        remoteAddress.toNativeChar(allocator: arena),
        type.index,
      );
      return connectResult;
    });

    if (ret != 0) {
      debugPrint(
        'Failed to bt_audio_connect. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
    return ret;
  }

  // bt_audio_set_connection_state_changed_cb (*: Pointer)
  // bt_audio_unset_connection_state_changed_cb
  static const EventChannel _audioConnectionStateChangedEventChannel =
      EventChannel('tizen/bluetooth/audio_connection_state_changed');

  static late StreamSubscription<AudioConnectionInfo>?
  _audioConnectionStateChangedSubscription;

  static late BtAudioConnectionStateChangedCallback?
  _btAudioConnectionStateChangedCallback;

  static Stream<AudioConnectionInfo> get audioConnectionStateChangedStream =>
      _audioConnectionStateChangedEventChannel.receiveBroadcastStream().map(
        (dynamic event) => AudioConnectionInfo.fromMap(
          (event as Map<dynamic, dynamic>).cast<String, dynamic>(),
        ),
      );

  static void btAudioSetConnectionStateChangedCallback(
    BtAudioConnectionStateChangedCallback callback,
  ) {
    _btAudioConnectionStateChangedCallback = callback;
    methodChannel.invokeMethod<String>(
      'init_bt_audio_set_connection_state_changed_cb',
    );
  }

  static void btAudioUnsetConnectionStateChangedCallback() {
    int ret = tizen.bt_audio_unset_connection_state_changed_cb();
    if (ret != 0) {
      debugPrint(
        'Failed to bt_audio_unset_connection_state_changed_cb. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }

    _audioConnectionStateChangedSubscription?.cancel();
    _audioConnectionStateChangedSubscription = null;
    _btAudioConnectionStateChangedCallback = null;
  }
}
