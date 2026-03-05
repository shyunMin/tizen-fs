import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_interop/9.0/tizen.dart' as tz;
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';
import 'language_input_setting_manager.dart';

class Voice {
  final String voiceId;
  final int voiceType;
  final bool isDefault;
  final bool isAutoVoice;

  Voice(this.voiceId, this.voiceType, this.isDefault, this.isAutoVoice);
}

class TtsSettingManager extends SettingManager {
  static final TtsSettingManager _instance = TtsSettingManager._internal();

  factory TtsSettingManager() {
    return _instance;
  }

  TtsSettingManager._internal() {
    _initialize();
  }

  static void Function(String)? _engineChangedCallback;
  static void Function(String)? _voiceChangedCallback;
  static void Function(int)? _speedChangedCallback;
  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();

  static List<Engine> _engines = [];
  static List<Voice> _voices = [];

  static bool _isSetEngine = false;

  late final dynamic engineChangedCallback;
  late final dynamic voiceChangedCallback;
  late final dynamic speedChangedCallback;

  void _initialize() {
    var ret = tz.tizen.tts_setting_initialize();
    if (ret != 0) {
      // debugPrint('[TTS] Failed to initialize TTS setting manager: $ret');
    }
    _registerCallbacks();
    _setTtsCallbacks();
  }

  void _registerCallbacks() {
    engineChangedCallback = _callbacks
        .register<Void Function(Pointer<Char>, Pointer<Void>)>(
          'tts_setting_engine_changed_cb',
          Pointer.fromFunction(_engineChangedHandler),
          blocking: true,
        );

    voiceChangedCallback = _callbacks
        .register<Void Function(Pointer<Char>, Int32, Bool, Pointer<Void>)>(
          'tts_setting_voice_changed_cb',
          Pointer.fromFunction(_voiceChangedHandler),
          blocking: true,
        );

    speedChangedCallback = _callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'tts_setting_speed_changed_cb',
          Pointer.fromFunction(_speedChangedHandler),
        );
  }

  void _setTtsCallbacks() {
    var ret = tz.tizen.tts_setting_set_engine_changed_cb(
      engineChangedCallback.interopCallback,
      engineChangedCallback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[TTS] Failed to set engine changed callback: $ret');
    }

    ret = tz.tizen.tts_setting_set_voice_changed_cb(
      voiceChangedCallback.interopCallback,
      voiceChangedCallback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[TTS] Failed to set voice changed callback: $ret');
    }

    ret = tz.tizen.tts_setting_set_speed_changed_cb(
      speedChangedCallback.interopCallback,
      speedChangedCallback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[TTS] Failed to set speed changed callback: $ret');
    }
  }

  void _unsetTtsCallbacks() {
    var ret = tz.tizen.tts_setting_unset_engine_changed_cb();
    if (ret != 0) {
      // debugPrint('[TTS] Failed to unset engine changed callback: $ret');
    }

    ret = tz.tizen.tts_setting_unset_voice_changed_cb();
    if (ret != 0) {
      // debugPrint('[TTS] Failed to unset voice changed callback: $ret');
    }

    ret = tz.tizen.tts_setting_unset_speed_changed_cb();
    if (ret != 0) {
      // debugPrint('[TTS] Failed to unset speed changed callback: $ret');
    }
  }

  void setEngineChangedListener(void Function(String) callback) {
    _engineChangedCallback = callback;
  }

  void removeEngineChangedListener() {
    _engineChangedCallback = null;
  }

  void setVoiceChangedListener(void Function(String) callback) {
    _voiceChangedCallback = callback;
  }

  void removeVoiceChangedListener() {
    _voiceChangedCallback = null;
  }

  void setSpeedChangedListener(void Function(int) callback) {
    _speedChangedCallback = callback;
  }

  void removeSpeedChangedListener() {
    _speedChangedCallback = null;
  }

  static void _engineChangedHandler(
    Pointer<Char> engineId,
    Pointer<Void> userData,
  ) {
    //SetVoice 시 EngineChanged 와 VoiceChanged 가 둘다 발생 함
    if (_isSetEngine) {
      // debugPrint("Callback triggered by set Engine");
      _isSetEngine = false;
    } else {
      // debugPrint("Callback triggered by set voice");
      return;
    }
    try {
      final engineIdStr = engineId.cast<Utf8>().toDartString();
      // debugPrint("_engineChangedHandler[$engineIdStr]");

      if (engineIdStr.isNotEmpty) {
        _engineChangedCallback?.call(engineIdStr);
      } else {
        // debugPrint("Engine change callback received null or empty engineID");
        _engineChangedCallback?.call("");
      }
    } catch (e) {
      debugPrint("Error handling engine change callback: $e");
      _engineChangedCallback?.call("");
    }
  }

  static void _voiceChangedHandler(
    Pointer<Char> voiceId,
    int voiceType,
    bool autoVoice,
    Pointer<Void> userData,
  ) {
    try {
      final voiceIdStr = voiceId.cast<Utf8>().toDartString();
      // debugPrint("voiceId[${voiceIdStr}] Type[$voiceType], Auto[$autoVoice]");
      _voiceChangedCallback?.call(voiceIdStr);
    } catch (e) {
      debugPrint("Error handling voice change callback: $e");
      _voiceChangedCallback?.call('');
    }
  }

  static void _speedChangedHandler(int speed, Pointer<Void> userData) {
    try {
      final speedInt = speed;
      _speedChangedCallback?.call(speedInt);
    } catch (e) {
      // debugPrint("Error handling speed change callback: $e");
    }
  }

  void dispose() {
    _unsetTtsCallbacks();
    removeEngineChangedListener();
    removeVoiceChangedListener();
    removeSpeedChangedListener();

    var ret = tz.tizen.tts_setting_finalize();
    if (ret != 0) {
      // debugPrint('[TTS] Failed to finalize TTS setting manager: $ret');
    }
  }

  @override
  Future<List<Engine>> getSupportedEngines() async {
    _engines = [];
    final port = ReceivePort();

    final callback = _callbacks.register<
      Bool Function(Pointer<Char>, Pointer<Char>, Pointer<Char>, Pointer<Void>)
    >(
      'tts_setting_supported_engine_cb',
      Pointer.fromFunction(_localEngineCallback, true),
    );

    await Isolate.spawn(_getEngines, [port.sendPort, callback]);
    await port.first;

    return List<Engine>.from(_engines);
  }

  static void _getEngines(List<Object> message) async {
    final sendPort = message[0] as SendPort;
    final callback =
        message[1]
            as RegisteredCallback<
              Bool Function(
                Pointer<Char>,
                Pointer<Char>,
                Pointer<Char>,
                Pointer<Void>,
              )
            >;

    var ret = await tz.tizen.tts_setting_foreach_supported_engines(
      callback.interopCallback,
      callback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[TTS] Failed to get engine list: $ret');
    }

    sendPort.send(null);
  }

  static bool _localEngineCallback(
    Pointer<Char> engineId,
    Pointer<Char> engineName,
    Pointer<Char> settingPath,
    Pointer<Void> userData,
  ) {
    try {
      final idStr = engineId.cast<Utf8>().toDartString();
      final nameStr = engineName.cast<Utf8>().toDartString();

      _engines.add(Engine(idStr, nameStr));
      // debugPrint("Engine added: Id=$idStr, Name=$nameStr, Path=$pathStr");

      return true;
    } catch (e) {
      debugPrint("Error in engine callback: $e");
      return false;
    }
  }

  Future<List<Voice>> getSupportedVoices() async {
    _voices = [];
    final port = ReceivePort();

    final callback = _callbacks.register<
      Bool Function(Pointer<Char>, Pointer<Char>, Int, Pointer<Void>)
    >(
      'tts_setting_supported_voice_cb',
      Pointer.fromFunction(_localVoiceCallback, false),
    );

    await Isolate.spawn(_getVoiceEngines, [port.sendPort, callback]);
    await port.first;

    return List<Voice>.from(_voices);
  }

  static void _getVoiceEngines(List<Object> message) async {
    final sendPort = message[0] as SendPort;
    final callback =
        message[1]
            as RegisteredCallback<
              Bool Function(Pointer<Char>, Pointer<Char>, Int, Pointer<Void>)
            >;

    try {
      var ret = await tz.tizen.tts_setting_foreach_supported_voices(
        callback.interopCallback,
        callback.interopUserData,
      );

      if (ret != 0) {
        // debugPrint('[TTS] Failed to get voice list: $ret');
      }
    } catch (e) {
      debugPrint("[TTS] Error getting supported voices: $e");
    }

    sendPort.send(null);
  }

  static bool _localVoiceCallback(
    Pointer<Char> engineId,
    Pointer<Char> voiceId,
    int voiceType,
    Pointer<Void> userData,
  ) {
    try {
      final voiceIdStr = voiceId.cast<Utf8>().toDartString();

      _voices.add(Voice(voiceIdStr, voiceType, false, false));
      // debugPrint("Voice added: Engine=$engineIdStr, Voice ID=$voiceIdStr, Type=$voiceType");
      return true;
    } catch (e) {
      debugPrint("Error in voice callback: $e");
      return false;
    }
  }

  String getCurrentEngine() {
    final engineIdPtr = calloc<Pointer<Char>>();
    try {
      var ret = tz.tizen.tts_setting_get_engine(engineIdPtr);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to get current engine: $ret');
        return "";
      }
      final result = engineIdPtr.value.cast<Utf8>().toDartString();
      // debugPrint('[TTS] getCurrentEngine: $result');
      return result;
    } catch (e) {
      debugPrint("[TTS] Exception in getCurrentEngine: $e");
      return "";
    } finally {
      calloc.free(engineIdPtr);
    }
  }

  String getCurrentVoice() {
    final voiceIdPtr = calloc<Pointer<Char>>();
    final voiceTypePtr = calloc<Int>();
    // final autoVoicePtr = calloc<Bool>();
    try {
      var ret = tz.tizen.tts_setting_get_voice(voiceIdPtr, voiceTypePtr);

      if (ret != 0) {
        // debugPrint('[TTS] Failed to get current voice: $ret');
      }

      final voiceIdStr = voiceIdPtr.value.cast<Utf8>().toDartString();

      return voiceIdStr;
    } finally {
      calloc.free(voiceIdPtr);
    }
  }

  bool getAutoVoice() {
    final autoVoicePtr = calloc<Bool>();
    try {
      var ret = tz.tizen.tts_setting_get_auto_voice(autoVoicePtr);

      if (ret != 0) {
        // debugPrint('[TTS] Failed to get auto voice: $ret');
      }
      return autoVoicePtr.value;
    } finally {
      calloc.free(autoVoicePtr);
    }
  }

  void setCurrentEngine(String engineId) {
    _isSetEngine = true;
    final engineIdPtr = engineId.toNativeUtf8().cast<Char>();
    try {
      var ret = tz.tizen.tts_setting_set_engine(engineIdPtr);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to set current engine: $ret');
      }
    } finally {
      calloc.free(engineIdPtr);
    }
  }

  void setCurrentVoiceDirect(String voiceId, int voiceType) {
    final voiceIdPtr = voiceId.toNativeChar();
    // debugPrint("[TTS] manager setCurrentVoiceDirect [${voiceId}][${voiceType}]");

    try {
      var ret = tz.tizen.tts_setting_set_voice(voiceIdPtr, voiceType);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to set current voice: $ret');
      }
    } finally {
      calloc.free(voiceIdPtr);
    }
  }

  void setAutoVoice(bool enabled) {
    try {
      var ret = tz.tizen.tts_setting_set_auto_voice(enabled);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to set auto voice: $ret');
      }
    } catch (e) {
      debugPrint("[TTS] Error setting auto voice: $e");
    }
  }

  int getSpeedRange() {
    final minPtr = calloc<Int>();
    final maxPtr = calloc<Int>();
    final normalPtr = calloc<Int>();
    try {
      var ret = tz.tizen.tts_setting_get_speed_range(minPtr, normalPtr, maxPtr);

      if (ret != 0) {
        // debugPrint('[TTS] Failed to get speed range: $ret');
      }
      return maxPtr.value - minPtr.value;
    } finally {
      calloc.free(minPtr);
      calloc.free(normalPtr);
      calloc.free(maxPtr);
    }
  }

  int getCurrentSpeed() {
    final speedPtr = calloc<Int>();
    try {
      var ret = tz.tizen.tts_setting_get_speed(speedPtr);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to get current speed: $ret');
      }
      return speedPtr.value;
    } finally {
      calloc.free(speedPtr);
    }
  }

  void setCurrentSpeed(int speed) {
    try {
      var ret = tz.tizen.tts_setting_set_speed(speed);
      if (ret != 0) {
        // debugPrint('[TTS] Failed to set current speed: $ret');
      }
    } catch (e) {
      debugPrint("[TTS] Error setting speed: $e");
    }
  }
}
