import 'package:tizen_fs/native/stt_setting_manager.dart';
import 'package:tizen_fs/providers/language_input_provider.dart';

class SttSettingProvider
    extends LanguageInputSettingProvider<SttSettingManager> {
  List<Language> _languages = [];
  List<Language> get languages => _languages;

  late Language _currentLanguage;
  Language get currentLanguage => _currentLanguage;

  SttSettingProvider() : super(SttSettingManager());

  @override
  void setupCallbacks() {
    super.setupCallbacks();
    manager.setLanguageChangedListener(
      (languageId) => _loadCurrentLanguageFromInfo(languageId),
    );
  }

  @override
  void dispose() {
    manager.removeLanguageChangedListener();
    super.dispose();
  }

  Future<void> loadLanguageList() async {
    try {
      await _loadLanguageList();
    } catch (e) {
      error = e.toString();
      safeNotifyListeners();
    } finally {
      safeNotifyListeners();
    }
  }

  Future<void> _loadLanguageList() async {
    if (_languages.isEmpty) {
      final languages = await manager.getSupportedLanguages();
      _languages = [Language('autoLanguage', '', true), ...languages];
    }

    final languageId =
        manager.getAutoLanguage()
            ? 'autoLanguage'
            : manager.getCurrentLanguage();

    _currentLanguage =
        _languages.where((l) => l.languageId == languageId).first;
  }

  int getLanguageIndex(Language language) {
    return _languages.indexOf(language).clamp(0, _languages.length - 1);
  }

  Language getLanguage(int index) {
    return _languages.elementAt(index);
  }

  Future<void> setCurrentLanguage(Language language) async {
    if (_currentLanguage.languageId == language.languageId) return;

    try {
      if (language.isAutoLanguage) {
        manager.setAutoLanguage(true);
      } else {
        manager.setAutoLanguage(false);
        manager.setCurrentLanguage(language.languageId);
      }
      _currentLanguage = language;
    } catch (e) {
      error = e.toString();
    } finally {
      safeNotifyListeners();
    }
  }

  void _loadCurrentLanguageFromInfo(String languageId) {
    try {
      if (_currentLanguage.languageId != languageId) {
        final language =
            _languages.where((v) => v.languageId == languageId).firstOrNull;
        _currentLanguage = language!;
      }

      safeNotifyListeners();
    } catch (e) {
      error = e.toString();
      safeNotifyListeners();
    }
  }
}
