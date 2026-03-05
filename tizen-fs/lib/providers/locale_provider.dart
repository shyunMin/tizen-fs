import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/native/language_input_manager.dart';

class LocaleProvider with ChangeNotifier {
  late Locale _currentLocale;
  late LanguageInputManager _languageManager;
  Function(bool)? _onLocaleChangeComplete;

  Locale get currentLocale => _currentLocale;

  List<DisplayLanguageInfo> get availableLanguages =>
      LanguageInputManager.availableLanguages;

  LocaleProvider() {
    _languageManager = GetIt.instance<LanguageInputManager>();
    loadLanguages();
  }

  void loadLanguages() {
    final systemLocale = _languageManager.getCurrentLocale();
    if (systemLocale.contains('_')) {
      final parts = systemLocale.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = Locale(systemLocale);
      }
    } else {
      _currentLocale = Locale(systemLocale);
    }
  }

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void setLocaleFromString(String localeString) {
    if (localeString.contains('_')) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        setLocale(Locale(parts[0], parts[1]));
      } else {
        setLocale(Locale(localeString));
      }
    } else {
      setLocale(Locale(localeString));
    }
  }

  String getLocale(int index) {
    return _languageManager.getLoacal(index);
  }

  int getCurrentLocaleIndex() {
    return _languageManager.getCurrentLocaleIndex();
  }

  String getCurrentLocale() {
    return _languageManager.getCurrentLocale();
  }

  bool setSystemLocale(String locale, {Function(bool)? onComplete}) {
    _onLocaleChangeComplete = onComplete;
    bool result = _languageManager.setLocale(locale);
    if (result) {
      setLocaleFromString(locale);
      if (_onLocaleChangeComplete != null) {
        _onLocaleChangeComplete!(result);
      }
    }

    return result;
  }

  void setLocaleChangeCompleteCallback(Function(bool) callback) {
    _onLocaleChangeComplete = callback;
  }
}
