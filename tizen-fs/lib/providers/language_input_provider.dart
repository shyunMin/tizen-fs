import 'package:flutter/material.dart';
import 'package:tizen_fs/native/language_input_setting_manager.dart';

class LanguageInputSettingProvider<T extends SettingManager>
    with ChangeNotifier {
  final T manager;

  bool _isDisposed = false;

  List<Engine> _engines = [];
  List<Engine> get engines => _engines;

  Engine? _currentEngine;
  Engine? get currentEngine => _currentEngine;

  String? _error;
  String? get error => _error;
  set error(String? error) {
    _error = error;
  }

  LanguageInputSettingProvider(this.manager) {
    setupCallbacks();
  }

  void safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @protected
  void setupCallbacks() {
    manager.setEngineChangedListener(
      (engineId) => _handleEngineChanged(engineId),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    manager.removeEngineChangedListener();
    manager.dispose();
    super.dispose();
  }

  Future<void> loadEngineData() async {
    try {
      await _loadEngineData();
    } catch (e) {
      _error = e.toString();
      safeNotifyListeners();
    } finally {
      safeNotifyListeners();
    }
  }

  Future<void> _loadEngineData() async {
    if (_engines.isEmpty) {
      _engines = await manager.getSupportedEngines();
    }

    final engineId = manager.getCurrentEngine();
    _currentEngine = _engines.where((e) => e.engineId == engineId).first;
  }

  int getEngineIndex(String engineId) {
    return _engines
        .indexWhere((e) => e.engineId == engineId)
        .clamp(0, _engines.length - 1);
  }

  String getEngineId(int index) {
    return _engines.elementAt(index).engineId;
  }

  Future<void> setCurrentEngine(String engineId) async {
    if (_currentEngine?.engineId == engineId) return;

    final engine = _engines.where((e) => e.engineId == engineId).firstOrNull;
    if (engine == null) return;

    try {
      manager.setCurrentEngine(engineId);
      _currentEngine = engine;
    } catch (e) {
      _error = e.toString();
    } finally {
      safeNotifyListeners();
    }
  }

  void _handleEngineChanged(String engineId) {
    try {
      if (_currentEngine?.engineId != engineId) {
        final engine =
            _engines.where((e) => e.engineId == engineId).firstOrNull;
        _currentEngine = engine;
      }
    } catch (e) {
      _error = e.toString();
      safeNotifyListeners();
    }
  }
}
