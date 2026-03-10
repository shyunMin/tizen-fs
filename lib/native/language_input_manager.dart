import 'package:flutter/material.dart';
import 'package:tizen_fs/native/vconf.dart';
import 'dart:ffi';
import 'package:tizen_interop/9.0/tizen.dart' as tz;
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

class DisplayLanguageInfo {
  final String locale;
  final String name;
  final String language;
  final String mcc;

  DisplayLanguageInfo({
    required this.locale,
    required this.name,
    required this.language,
    required this.mcc,
  });

  String getLocale() => locale;
  String getName() => name;
  String getLanguage() => language;
  String getMcc() => mcc;
}

class LanguageInputManager {
  static const String vconfRegionAutomatic = "db/setting/region_automatic";
  static const String vconfLanguageAutomatic = "db/setting/lang_automatic";
  static const String vconfWidgetLanguage = "db/menu_widget/language";

  static final List<DisplayLanguageInfo> availableLanguages = [
    DisplayLanguageInfo(
      locale: "en_US",
      name: "English (United States)",
      language: "English(US)",
      mcc: "310,311,313,316",
    ),
    DisplayLanguageInfo(
      locale: "ko_KR",
      name: "한국어",
      language: "Korean",
      mcc: "450",
    ),
  ];

  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();
  static void Function(String)? _onLanguageChanged;
  late final languageChangedCallback;

  LanguageInputManager() {
    _registerCallbacks();
    _setSystemCallback();
  }

  void _registerCallbacks() {
    languageChangedCallback = _callbacks
        .register<Void Function(Int32, Pointer<Void>)>(
          'system_settings_changed_cb',
          Pointer.fromFunction(_languageChangedHandler),
        );
  }

  void _setSystemCallback() {
    final result = tz.tizen.system_settings_set_changed_cb(
      tz.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_LANGUAGE,
      languageChangedCallback.interopCallback,
      languageChangedCallback.interopUserData,
    );

    if (result != 0) {
      debugPrint(
        "[LanguageInputManager] Error in system_settings_set_changed_cb: $result",
      );
    }
  }

  void _unsetSystemCallback() {
    final result = tz.tizen.system_settings_unset_changed_cb(
      tz.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_LANGUAGE,
    );

    if (result != 0) {
      debugPrint(
        "[LanguageInputManager] Error in system_settings_unset_changed_cb: ${result}",
      );
    }
  }

  void setLanguageChangedListener(void Function(String) callback) {
    _onLanguageChanged = callback;
  }

  void removeLanguageChangedListener() {
    _onLanguageChanged = null;
  }

  static void _languageChangedHandler(int key, Pointer<Void> userData) {
    try {
      String? currentLanguage = Vconf.getString(vconfWidgetLanguage);
      if (currentLanguage == null) {
        debugPrint("[LanguageInputManager] Failed to get currentLanguage.");
        return;
      }

      List<String> qStrings = currentLanguage.split('.');
      if (qStrings.isNotEmpty) {
        currentLanguage = qStrings[0];
      }

      if (_onLanguageChanged != null) {
        _onLanguageChanged!(currentLanguage);
      }
    } catch (e) {
      debugPrint("[LanguageInputManager] Error in _languageChangedHandler: $e");
    }
  }

  void dispose() {
    _unsetSystemCallback();
    removeLanguageChangedListener();
  }

  bool setLocale(String locale) {
    if (availableLanguages.indexWhere((l) => l.locale == locale) == -1)
      return false;

    try {
      Vconf.setBool(vconfLanguageAutomatic, false);

      final result = tz.tizen.system_settings_set_value_string(
        tz.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_LANGUAGE,
        locale.toNativeChar(),
      );

      if (result != 0) {
        debugPrint(
          "[LanguageInputManager] Failed to system_settings_set_value_string: $result",
        );
        return false;
      }

      bool? regionAutomatic = Vconf.getBool(vconfRegionAutomatic);
      if (regionAutomatic == null) {
        debugPrint("[LanguageInputManager] Failed to get regionAutomatic.");
      } else if (regionAutomatic) {
        final regionResult = tz.tizen.system_settings_set_value_string(
          tz.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_COUNTRY,
          locale.toNativeChar(),
        );

        if (regionResult != 0) {
          debugPrint(
            "[LanguageInputManager] Error in system_settings_set_value_string: $regionResult",
          );
        }
      }

      String? paLanguage = Vconf.getString(vconfWidgetLanguage);
      if (paLanguage == null) {
        debugPrint("[LanguageInputManager] Failed to get paLanguage");
        return false;
      }

      final defaultResult = tz.tizen.system_settings_set_value_string(
        tz.system_settings_key_e.SYSTEM_SETTINGS_KEY_LOCALE_COUNTRY,
        paLanguage.toNativeChar(),
      );

      if (defaultResult != 0) {
        debugPrint(
          "[LanguageInputManager] Error in system_settings_set_value_string: $defaultResult",
        );
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("[LanguageInputManager] Error in setLocaleLanguage: $e");
      return false;
    }
  }

  int getCurrentLocaleIndex() {
    var locale = getCurrentLocale();
    try {
      var languageInfo = availableLanguages.firstWhere(
        (x) => x.getLocale() == locale,
      );
      return availableLanguages.indexOf(languageInfo);
    } catch (e) {
      debugPrint(
        "[LanguageInputManager] Error in getCurrentLocaleIndex: ${locale}",
      );
      return -1;
    }
  }

  int getLanguageIndex(String locale) {
    return availableLanguages
        .indexWhere((l) => l.getLocale() == locale)
        .clamp(0, availableLanguages.length - 1);
  }

  String getLoacal(int index) {
    if (index < 0 || index > availableLanguages.length - 1) return '';
    final lang = availableLanguages.elementAt(index);
    return lang.getLocale();
  }

  String getCurrentLocale() {
    String? locale = Vconf.getString(vconfWidgetLanguage);
    if (locale == null) {
      debugPrint("[LanguageInputManager] Failed to get locale");
      return "";
    }

    List<String> qStrings = locale.split('.');
    if (qStrings.isNotEmpty) {
      return qStrings[0];
    }
    return locale;
  }

  String getCurrentLanguageName() {
    const String automaticName = "Automatic";

    bool? langAutomatic = Vconf.getBool(vconfLanguageAutomatic);
    if (langAutomatic == null) {
      debugPrint("[LanguageInputManager] Could not get langAutomatic");
    } else if (langAutomatic) {
      return automaticName;
    }

    String locale = getCurrentLocale();

    try {
      var displayLanguage = availableLanguages.firstWhere(
        (x) => x.getLocale() == locale,
      );
      // debugPrint("[LanguageInputManager] getCurrentLanguageName: ${displayLanguage.getName()}");
      return displayLanguage.getName();
    } catch (e) {
      debugPrint(
        "[LanguageInputManager] Error in getCurrentLanguageName: $locale",
      );
      return locale;
    }
  }
}
