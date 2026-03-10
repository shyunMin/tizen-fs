import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/native/mcp_service.dart';
import 'package:tizen_fs/models/ai_model.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class GaussService implements AIService {
  bool _isInitialized = false;
  final _timeout = const Duration(seconds: 30);

  String _systemPrompt = '';

  String _clientKey = '';
  String _passKey = '';
  String _email = '';
  String _endpointUrl = '';

  String _modelId = '';
  String _modelname = '';

  @override
  String get modelName => _modelname;

  Map<String, String>? _header = null;
  final _promptManager = SystemPromptManager();

  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      String gaussConfig = '';
      final directory = await getApplicationSupportDirectory();
      debugPrint(directory.path.toString());
      // /opt/usr/home/owner/apps_rw/org.tizen.homescreen/data
      final configFile = File('${directory.path}/gauss_config.json');
      debugPrint('configFile.existsSync() = ${configFile.existsSync()}');

      await _promptManager.initialize();

      if (configFile.existsSync()) {
        gaussConfig = await configFile.readAsString();
      } else {
        gaussConfig = await rootBundle.loadString('assets/gauss_config.json');
      }

      final Map<String, dynamic> configJson = json.decode(gaussConfig);
      _clientKey =
          dotenv.env['GAUSS_CLIENT_KEY'] ?? configJson['client_key'] ?? '';
      _passKey = dotenv.env['GAUSS_PASS_KEY'] ?? configJson['pass_key'] ?? '';
      _email = dotenv.env['GAUSS_EMAIL'] ?? configJson['email'] ?? '';
      _endpointUrl = configJson['endpoint_url'] ?? '';
    } catch (e) {
      debugPrint('Failed to load config file: $e');
      return;
    }

    if (_clientKey.isEmpty || _passKey.isEmpty || _email.isEmpty) {
      debugPrint('Failed to load config file');
      return;
    }

    _header ??= {
      "x-generative-ai-client": _clientKey,
      "x-openapi-token": _passKey,
      "x-generative-ai-user-email": _email,
      "Content-Type": 'application/json',
    };

    _isInitialized = true;
  }

  @override
  Future<void> disconnect() async {
    await McpService.disconnect();
  }

  @override
  Future<bool> connect() async {
    await _init();

    if (!_isInitialized) return false;

    _generateSystemPrompt();

    if (_modelId.isNotEmpty) return true;

    try {
      final url = Uri.parse('$_endpointUrl/openapi/chat/v1/models');
      final response = await http
          .get(url, headers: _header)
          .timeout(
            _timeout,
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        final models = jsonList.map((json) => Model.fromJson(json)).toList();
        _modelname = models.firstOrNull?.getName('en') ?? '';
        _modelId = models.firstOrNull?.modelId ?? '';

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<String> sendMessage(String message) async {
    debugPrint('service.sendMessage: $message');
    if (_modelId.isEmpty) return 'No model connected.';

    _generateSystemPrompt();

    final url = Uri.parse('$_endpointUrl/openapi/chat/v1/messages');
    String responseMessage = '';

    final Map<String, dynamic> body = {
      "modelIds": ["$_modelId"], //"0198ebef-43e7-7b10-bdb4-287d66e0d8d9"
      "contents": ["$message"],
      "llmConfig": {
        "max_new_tokens": 2024,
        "seed": null,
        "top_k": 14,
        "top_p": 0.94,
        "temperature": 0.4,
        "repetition_penalty": 1.04,
      },
      "systemPrompt": _systemPrompt,
      "isStream": false,
    };

    try {
      debugPrint('send to ai : $message');
      final response = await http
          .post(url, headers: _header, body: jsonEncode(body))
          .timeout(
            _timeout,
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );
      debugPrint("response: ${response.statusCode}");
      debugPrint(response.body);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        responseMessage = jsonResponse['content'];
      } else if (response.statusCode == 429) {
        responseMessage = jsonResponse['description'];
      }
      return responseMessage;
    } catch (e) {
      return e.toString();
    }
  }

  void _generateSystemPrompt() {
    // debugPrint('####_generateSystemPrompt - start');
    _promptManager.resetDeviceStatus();

    // // Get real device status from WifiProvider
    final wifiProvider = GetIt.instance<WifiProvider>();

    // // Ensure WifiProvider is initialized before accessing status
    String wifiPower = 'off';
    if (wifiProvider.isInitialized) {
      wifiPower = wifiProvider.isActivated ? 'on' : 'off';
    } else {
      wifiPower = wifiProvider.isSupported ? "supported" : "Not Supported";
    }

    final btProvider = GetIt.instance<BtModel>();
    String btPower = 'off';
    if (btProvider.isEnabled) {
      btPower = btProvider.isEnabled ? 'on' : 'off';
    } else {
      btPower = btProvider.isBtSupported ? "supported" : "Not Supported";
    }

    _promptManager.updateDeviceStatus("wifi_power", wifiPower);
    if (wifiProvider.isActivated) {
      _promptManager.updateDeviceStatus(
        "Wi-Fi Connected",
        wifiProvider.connectedAp?.essid ?? '',
      );
    }

    _promptManager.updateDeviceStatus("bluetooth_power", btPower);
    if (btProvider.isEnabled) {
      for (var device in btProvider.connectedDevices) {
        _promptManager.updateDeviceStatus(
          "Bluetooth Connected Device",
          (device as BtDevice).remoteName,
        );
      }
    }
    _systemPrompt = _promptManager.generateFullPrompt();
    // debugPrint('####_generateSystemPrompt - end');
    // debugPrint(_systemPrompt);
  }
}

class SystemPromptManager {
  String _logicFlow = "";
  String _outputRules = "";
  String _deviceStatusScript = "";
  String _tools = "";

  // 기기 상태를 저장하는 맵 (예: wifi: connected)
  final Map<String, String> _deviceStatus = {};

  /// 1. Assets 파일 읽기 및 초기화
  Future<void> initialize() async {
    try {
      // 파일을 읽어올 때 줄바꿈과 공백이 유지됩니다.
      _logicFlow = await rootBundle.loadString('assets/logic_flow.txt');
      _outputRules = await rootBundle.loadString('assets/output_rules.txt');
      _deviceStatusScript = await rootBundle.loadString(
        'assets/device_status.txt',
      );

      final isEmulator = await getIt<DeviceInfoProvider>().isEmulator();
      debugPrint("isEmulator: ${isEmulator}");
      if (isEmulator) {
        _tools = await rootBundle.loadString('assets/tools.txt');
      } else {
        await McpService.connect();
        _tools = McpService.getActionsString();
      }
    } catch (e) {
      print("Error loading prompt assets: $e");
    }
  }

  /// 2. 기기 상태 추가/업데이트
  void updateDeviceStatus(String key, String value) {
    _deviceStatus[key] = value;
  }

  /// 3. 기기 상태 제거
  void removeDeviceStatus(String key) {
    _deviceStatus.remove(key);
  }

  /// 2. 기기 상태 추가/업데이트
  void resetDeviceStatus() {
    _deviceStatus.clear();
  }

  /// 4. 최종 시스템 프롬프트 조립 (Serialization)
  String generateFullPrompt() {
    StringBuffer promptBuffer = StringBuffer();
    promptBuffer.writeln(
      _deviceStatusScript.trim(),
    ); // instruction, device status
    if (_deviceStatus.isEmpty) {
      promptBuffer.writeln("No specific device status available.");
    } else {
      _deviceStatus.forEach((key, value) {
        promptBuffer.writeln("- $key: $value");
      });
    }
    promptBuffer.writeln(_outputRules.trim());
    promptBuffer.writeln(_tools.trim());
    promptBuffer.writeln(_logicFlow.trim());

    return promptBuffer.toString();
  }
}
