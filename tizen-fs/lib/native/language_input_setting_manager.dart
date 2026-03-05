class Language {
  final String languageId;
  final String engineId;
  final bool isAutoLanguage;

  Language(this.languageId, this.engineId, this.isAutoLanguage);
}

class Engine {
  final String engineId;
  final String engineName;

  Engine(this.engineId, this.engineName);
}

abstract class SettingManager {
  void setEngineChangedListener(void Function(String) callback);
  void removeEngineChangedListener();

  Future<List<Engine>> getSupportedEngines();
  String getCurrentEngine();
  void setCurrentEngine(String engineId);

  void dispose();
}
