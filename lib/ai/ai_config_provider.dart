import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tizen_fs/models/item_display_interface.dart';

class AIConfigProperty extends ChangeNotifier implements ItemDisplayInterface {
  String _key;
  String _value;
  bool _isSelectable;

  AIConfigProperty({
    required String key,
    required String value,
    bool isSelectable = true,
  }) : _key = key,
       _value = value,
       _isSelectable = isSelectable;

  String get key => _key;

  String get value => _value.isEmpty ? "N/A" : _value;

  set value(String newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  String _maskSensitiveValue(String value) {
    if (value.isEmpty || value == "N/A") {
      return value;
    }
    // Show first 4 characters and mask the rest with asterisks
    if (value.length <= 4) {
      return '*' * 10;
    }
    return value.substring(0, 4) + '*' * 10;
  }

  @override
  String get displayText => key;

  @override
  String? get displaySubText {
    // Mask sensitive values for clientKey and passKey
    if (_key == 'clientKey' || _key == 'passKey') {
      return _maskSensitiveValue(value);
    }
    return value;
  }

  @override
  Object? get iconSourceData => null;

  @override
  IconSourceType get iconSourceType => IconSourceType.none;

  @override
  bool get isSelectable => _isSelectable;
}

class AIConfigProvider extends ChangeNotifier {
  final List<AIConfigProperty> _properties = [];
  String _configFilePath = '';

  AIConfigProvider() {
    _initializeProperties();
  }

  void _initializeProperties() {
    _properties.addAll([
      AIConfigProperty(key: 'clientKey', value: '', isSelectable: false),
      AIConfigProperty(key: 'passKey', value: '', isSelectable: false),
      AIConfigProperty(key: 'email', value: '', isSelectable: false),
      AIConfigProperty(key: 'endpointUrl', value: '', isSelectable: false),
      AIConfigProperty(key: 'configFilePath', value: _configFilePath),
    ]);
  }

  /// Get the current configuration file path
  String get configFilePath => _configFilePath;

  /// Set the configuration file path
  void setConfigFilePath(String path) {
    _configFilePath = path;
    _properties[4].value = path;
    loadConfiguration();
    notifyListeners();
  }

  List<AIConfigProperty> get properties => _properties;

  String get clientKey => _properties[0].value;
  String get passKey => _properties[1].value;
  String get email => _properties[2].value;
  String get endpointUrl => _properties[3].value;
  String get configFilePathDisplay => _properties[4].value;

  Future<void> loadConfiguration() async {
    try {
      if (_configFilePath.isEmpty) {
        final directory = await getApplicationSupportDirectory();
        // /opt/usr/home/owner/apps_rw/org.tizen.homescreen/data

        _configFilePath = '${directory.path}gauss_config.json';
        _properties[4].value = _configFilePath;
      }

      final file = File(_configFilePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        _properties[0].value = jsonData['client_key'] ?? '';
        _properties[1].value = jsonData['pass_key'] ?? '';
        _properties[2].value = jsonData['email'] ?? '';
        _properties[3].value = jsonData['endpoint_url'] ?? '';
      } else {
        _properties[0].value = '';
        _properties[1].value = '';
        _properties[2].value = '';
        _properties[3].value = '';
      }
    } catch (e) {
      debugPrint('Error loading AI configuration: $e');
      _properties[0].value = '';
      _properties[1].value = '';
      _properties[2].value = '';
      _properties[3].value = '';
    }

    notifyListeners();
  }
}
