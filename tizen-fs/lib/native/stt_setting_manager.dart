import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_fs/native/language_input_setting_manager.dart';
import 'package:tizen_interop/9.0/tizen.dart' as tz;
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

class Language {
  final String languageId;
  final String engineId;
  final bool isAutoLanguage;

  Language(this.languageId, this.engineId, this.isAutoLanguage);
}

class SttSettingManager extends SettingManager {
  static final SttSettingManager _instance = SttSettingManager._internal();

  factory SttSettingManager() {
    return _instance;
  }

  SttSettingManager._internal() {
    _initialize();
  }

  static void Function(String)? _engineChangedCallback;
  static void Function(String)? _languageChangedCallback;
  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();

  static List<Engine> _engines = [];
  static List<Language> _languages = [];

  static bool _isSetAutoLanguage = false;
  static bool _isSetLanguage = false;

  late final dynamic engineChangedCallback;
  late final dynamic languageChangedCallback;

  void _initialize() {
    var ret = tz.tizen.stt_setting_initialize();
    if (ret != 0) {
      // debugPrint('[STT] Failed to initialize engine: $ret');
    }
    _registerCallbacks();
    _setSttCallbacks();
  }

  void _registerCallbacks() {
    engineChangedCallback = _callbacks
        .register<Void Function(Pointer<Char>, Pointer<Void>)>(
          'stt_setting_engine_changed_cb',
          Pointer.fromFunction(_engineChangedHandler),
          blocking: true,
        );

    languageChangedCallback = _callbacks
        .register<Void Function(Pointer<Char>, Pointer<Void>)>(
          'stt_setting_config_changed_cb',
          Pointer.fromFunction(_languageChangedHandler),
          blocking: true,
        );
  }

  void _setSttCallbacks() {
    var ret = tz.tizen.stt_setting_set_engine_changed_cb(
      engineChangedCallback.interopCallback,
      engineChangedCallback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[STT] Failed to set engine changed callback: $ret');
    }

    ret = tz.tizen.stt_setting_set_config_changed_cb(
      languageChangedCallback.interopCallback,
      languageChangedCallback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[STT] Failed to set language changed callback: $ret');
    }
  }

  void _unsetSttCallbacks() {
    var ret = tz.tizen.stt_setting_unset_engine_changed_cb();
    if (ret != 0) {
      // debugPrint('[STT] Failed to unset engine changed callback: $ret');
    }

    ret = tz.tizen.stt_setting_unset_config_changed_cb();
    if (ret != 0) {
      // debugPrint('[STT] Failed to unset language changed callback: $ret');
    }
  }

  void setEngineChangedListener(void Function(String) callback) {
    _engineChangedCallback = callback;
  }

  void removeEngineChangedListener() {
    _engineChangedCallback = null;
  }

  void setLanguageChangedListener(void Function(String) callback) {
    _languageChangedCallback = callback;
  }

  void removeLanguageChangedListener() {
    _languageChangedCallback = null;
  }

  static void _engineChangedHandler(
    Pointer<Char> engineId,
    Pointer<Void> userData,
  ) {
    if (_isSetAutoLanguage) {
      debugPrint("[STT] Engine changed callback triggered by another reason");
      return;
    }

    try {
      final engineIdStr = engineId.cast<Utf8>().toDartString();
      if (engineIdStr.isNotEmpty) {
        _engineChangedCallback?.call(engineIdStr);
      } else {
        // debugPrint("[STT] Engine change callback received null or empty engineID");
        _engineChangedCallback?.call("");
      }
    } catch (e) {
      debugPrint("[STT] Error engine changed callback: $e");
      _engineChangedCallback?.call("");
    }
  }

  static void _languageChangedHandler(
    Pointer<Char> language,
    Pointer<Void> userData,
  ) {
    if (!_isSetLanguage) return;

    try {
      final languageStr = language.cast<Utf8>().toDartString();

      _languageChangedCallback?.call(languageStr);
    } catch (e) {
      debugPrint("[STT] Error language changed callback: $e");
      _languageChangedCallback?.call('');
    }
  }

  @override
  void dispose() {
    _unsetSttCallbacks();
    removeEngineChangedListener();
    removeLanguageChangedListener();

    var ret = tz.tizen.stt_setting_finalize();
    if (ret != 0) {
      // debugPrint('[STT] Failed to finalize STT setting manager: $ret');
    }
  }

  @override
  Future<List<Engine>> getSupportedEngines() async {
    _engines = [];
    final port = ReceivePort();

    final callback = _callbacks.register<
      Bool Function(Pointer<Char>, Pointer<Char>, Pointer<Char>, Pointer<Void>)
    >(
      'stt_setting_supported_engine_cb',
      Pointer.fromFunction(_localEngineCallback, true),
      blocking: true,
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

    var ret = await tz.tizen.stt_setting_foreach_supported_engines(
      callback.interopCallback,
      callback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[STT] Failed to get engine list: $ret');
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
      // debugPrint("[STT] Engine added: Id: $idStr, Name: $nameStr,");
      return true;
    } catch (e) {
      debugPrint("[STT] Error in engine callback: $e");
      return false;
    }
  }

  Future<List<Language>> getSupportedLanguages() async {
    _languages = [];
    final port = ReceivePort();

    final callback = _callbacks
        .register<Bool Function(Pointer<Char>, Pointer<Char>, Pointer<Void>)>(
          'stt_setting_supported_language_cb',
          Pointer.fromFunction(_localLanguageCallback, false),
          blocking: true,
        );

    await Isolate.spawn(_getVoiceEngines, [port.sendPort, callback]);
    await port.first;

    return List<Language>.from(_languages);
  }

  static void _getVoiceEngines(List<Object> message) async {
    final sendPort = message[0] as SendPort;
    final callback =
        message[1]
            as RegisteredCallback<
              Bool Function(Pointer<Char>, Pointer<Char>, Pointer<Void>)
            >;

    var ret = await tz.tizen.stt_setting_foreach_supported_languages(
      callback.interopCallback,
      callback.interopUserData,
    );

    if (ret != 0) {
      // debugPrint('[STT] Failed to get language list: $ret');
    }

    sendPort.send(null);
  }

  static bool _localLanguageCallback(
    Pointer<Char> engineId,
    Pointer<Char> language,
    Pointer<Void> userData,
  ) {
    try {
      final engineIdStr = engineId.cast<Utf8>().toDartString();
      final languageStr = language.cast<Utf8>().toDartString();
      _languages.add(Language(languageStr, engineIdStr, false));
      // debugPrint("[STT] Language added: engine: $engineIdStr, language: $languageStr");
      return true;
    } catch (e) {
      debugPrint("[STT] Error in language callback: $e");
      return false;
    }
  }

  String getCurrentEngine() {
    final engineIdPtr = calloc<Pointer<Char>>();
    try {
      var ret = tz.tizen.stt_setting_get_engine(engineIdPtr);
      if (ret != 0) {
        // debugPrint('[STT] Failed to get current engine: $ret');
        return "";
      }
      final result = engineIdPtr.value.cast<Utf8>().toDartString();
      // debugPrint('[STT] Return get current engine: $result');
      return result;
    } catch (e) {
      debugPrint("[STT] Error get current engine: $e");
      return "";
    } finally {
      calloc.free(engineIdPtr);
    }
  }

  String getCurrentLanguage() {
    final languagePtr = calloc<Pointer<Char>>();
    try {
      var ret = tz.tizen.stt_setting_get_default_language(languagePtr);
      if (ret != 0) {
        // debugPrint('[STT] Failed to get current language: $ret');
      }

      final languageStr = languagePtr.value.cast<Utf8>().toDartString();

      return languageStr;
    } catch (e) {
      debugPrint("[STT] Error get current language: $e");
      return '';
    } finally {
      calloc.free(languagePtr);
    }
  }

  bool getAutoLanguage() {
    final autoLanguagePtr = calloc<Bool>();
    try {
      var ret = tz.tizen.stt_setting_get_auto_language(autoLanguagePtr);
      if (ret != 0) {
        // debugPrint('[STT] Failed to get auto language: $ret');
      }
      // debugPrint("[STT] Return get auto language: ${autoLanguagePtr.value}");
      return autoLanguagePtr.value;
    } catch (e) {
      debugPrint("[STT] Error get auto language: $e");
      return false;
    } finally {
      calloc.free(autoLanguagePtr);
    }
  }

  void setCurrentEngine(String engineId) {
    final engineIdPtr = engineId.toNativeChar();
    try {
      var ret = tz.tizen.stt_setting_set_engine(engineIdPtr);
      if (ret != 0) {
        // debugPrint('[STT] Failed to set current engine: $ret');
      }
    } catch (e) {
      debugPrint("[STT] Error set current engine: $e");
    } finally {
      calloc.free(engineIdPtr);
    }
  }

  void setCurrentLanguage(String languageId) {
    _isSetLanguage = true;
    final languageIdPtr = languageId.toNativeChar();
    try {
      var ret = tz.tizen.stt_setting_set_default_language(languageIdPtr);
      if (ret != 0) {
        // debugPrint('[STT] Failed to set current language: $ret');
      }
    } catch (e) {
      debugPrint("[STT] Error set current language: $e");
    } finally {
      calloc.free(languageIdPtr);
      _isSetLanguage = false;
    }
  }

  void setAutoLanguage(bool enabled) {
    _isSetAutoLanguage = true;

    try {
      var ret = tz.tizen.stt_setting_set_auto_language(enabled);
      if (ret != 0) {
        // debugPrint('[STT] Failed to set auto language: $ret');
      }
    } catch (e) {
      debugPrint("[STT] Error setting auto language: $e");
    } finally {
      _isSetAutoLanguage = false;
    }
  }
}
