import 'package:tizen_fs/native/tts_setting_manager.dart';
import 'package:tizen_fs/providers/language_input_provider.dart';

class TtsSettingProvider
    extends LanguageInputSettingProvider<TtsSettingManager> {
  List<Voice> _voices = [];
  List<Voice> get voices => _voices;

  late Voice _currentVoice;
  Voice get currentVoice => _currentVoice;

  TtsSettingProvider() : super(TtsSettingManager());

  @override
  void setupCallbacks() {
    super.setupCallbacks();
    manager.setVoiceChangedListener(
      (voiceId) => _loadCurrentVoiceFromInfo(voiceId),
    );
  }

  @override
  void dispose() {
    manager.removeVoiceChangedListener();
    super.dispose();
  }

  Future<void> loadVoiceData() async {
    try {
      await _loadVoiceData();
    } catch (e) {
      error = e.toString();
      safeNotifyListeners();
    } finally {
      safeNotifyListeners();
    }
  }

  Future<void> _loadVoiceData() async {
    if (voices.isEmpty) {
      final voices = await manager.getSupportedVoices();
      _voices = [Voice('autoVoice', 0, true, true), ...voices];
    }

    final voiceId =
        manager.getAutoVoice() ? 'autoVoice' : manager.getCurrentVoice();

    _currentVoice = _voices.where((v) => v.voiceId == voiceId).first;
  }

  int getVoiceIndex(Voice voice) {
    return _voices.indexOf(voice).clamp(0, _voices.length - 1);
  }

  Voice getVoice(int index) {
    return _voices.elementAt(index);
  }

  Future<void> setCurrentVoice(Voice voice) async {
    if (_currentVoice.voiceId == voice.voiceId) return;

    try {
      if (voice.isAutoVoice) {
        manager.setAutoVoice(true);
      } else {
        manager.setAutoVoice(false);
        manager.setCurrentVoiceDirect(voice.voiceId, voice.voiceType);
      }
      _currentVoice = voice;
    } catch (e) {
      error = e.toString();
    } finally {
      safeNotifyListeners();
    }
  }

  void _loadCurrentVoiceFromInfo(String voiceId) {
    try {
      if (_currentVoice.voiceId != voiceId) {
        final voice = _voices.where((v) => v.voiceId == voiceId).first;
        _currentVoice = voice;
      }

      safeNotifyListeners();
    } catch (e) {
      error = e.toString();
      safeNotifyListeners();
    }
  }
}
