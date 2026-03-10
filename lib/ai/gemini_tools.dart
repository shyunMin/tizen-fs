import 'package:google_generative_ai/google_generative_ai.dart';

/// Additional system instruction text appended to all Gemini models using function calling.
const String kFunctionCallingSystemInstruction = '''
[Function Calling Rules]
1. Always call the most appropriate tool (function) for the user's request.
2. When calling a tool, you MUST populate the `uiJsonPayload` parameter with a valid genui-package JSON string that visually represents the result or control widget for the user.
3. When the user says the volume is too loud, or their ears hurt, or asks to lower the sound — NEVER use "mute". Always use the "down" command for homeVolume.
''';

/// Converts the tools.txt specification into a list of [FunctionDeclaration] objects
/// used by the Google Generative AI SDK for function calling.
final List<FunctionDeclaration> tizenFunctionDeclarations = [
  // 1. homeAdditionalFeature
  FunctionDeclaration(
    'homeAdditionalFeature',
    'Enable or disable specific features such as media, live, or ai.',
    Schema.object(
      properties: {
        'featureName': Schema.string(
          description: 'The feature to toggle: "media", "live", or "ai".',
          nullable: false,
        ),
        'enabled': Schema.string(
          description: '"on" to enable, "off" to disable.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['featureName', 'enabled', 'uiJsonPayload'],
    ),
  ),

  // 2. homeApps
  FunctionDeclaration(
    'homeApps',
    'Perform an action on the Home Screen App List: launch, sort, or filter apps.',
    Schema.object(
      properties: {
        'sort': Schema.string(
          description: 'Sort order: "DESC" or "ASC".',
          nullable: true,
        ),
        'type': Schema.string(
          description: 'Filter by app type: "", "dotnet", "capp", or "webapp".',
          nullable: true,
        ),
        'app_name': Schema.string(
          description: 'Keyword to filter or search apps.',
          nullable: true,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 3. homeBluetooth
  FunctionDeclaration(
    'homeBluetooth',
    'Turn Bluetooth on or off.',
    Schema.object(
      properties: {
        'command': Schema.string(
          description: '"on" to enable Bluetooth, "off" to disable.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['command', 'uiJsonPayload'],
    ),
  ),

  // 4. homeDevice
  FunctionDeclaration(
    'homeDevice',
    'Change the device name.',
    Schema.object(
      properties: {
        'name': Schema.string(
          description: 'The new device name to set.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['name', 'uiJsonPayload'],
    ),
  ),

  // 5. homeLanguage
  FunctionDeclaration(
    'homeLanguage',
    'Change the system language. Map "korean" -> "ko_KR", "english" -> "en_US".',
    Schema.object(
      properties: {
        'language': Schema.string(
          description:
              'Target language code: "ko_KR" for Korean, "en_US" for English.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['language', 'uiJsonPayload'],
    ),
  ),

  // 6. homeNotification
  FunctionDeclaration(
    'homeNotification',
    'Show system notifications.',
    Schema.object(
      properties: {
        'command': Schema.string(
          description: 'Must be "show".',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['command', 'uiJsonPayload'],
    ),
  ),

  // 7. homeSetting
  FunctionDeclaration(
    'homeSetting',
    'Open a specific System Settings page using the appropriate URI.',
    Schema.object(
      properties: {
        'uri': Schema.string(
          description:
              'The settings page URI. Examples: "/settings", "/settings/wifi", "/settings/bluetooth", "/settings/apps", etc.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uri', 'uiJsonPayload'],
    ),
  ),

  // 8. homeVideo
  FunctionDeclaration(
    'homeVideo',
    'Play a video.',
    Schema.object(
      properties: {
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 9. homeVolume
  FunctionDeclaration(
    'homeVolume',
    'Adjust the system volume. If the user says ears hurt or sound is too loud, use "down" — never "mute".',
    Schema.object(
      properties: {
        'command': Schema.string(
          description:
              'Volume command: "up", "down", "mute", or "unmute". Use "down" when user expresses discomfort with loud sound.',
          nullable: true,
        ),
        'level': Schema.string(
          description: 'A specific volume level value.',
          nullable: true,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 10. homeWifi
  FunctionDeclaration(
    'homeWifi',
    'Turn Wi-Fi on or off.',
    Schema.object(
      properties: {
        'command': Schema.string(
          description: '"on" to enable Wi-Fi, "off" to disable.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['command', 'uiJsonPayload'],
    ),
  ),

  // 11. homeWifiList
  FunctionDeclaration(
    'homeWifiList',
    'Get the list of available Wi-Fi access points. Available ONLY when Wi-Fi is already activated.',
    Schema.object(
      properties: {
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 12. homeWifiFind
  FunctionDeclaration(
    'homeWifiFind',
    'Find an access point in the scanned Wi-Fi list by name.',
    Schema.object(
      properties: {
        'name': Schema.string(
          description: 'The SSID name of the AP to find.',
          nullable: true,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 13. homeWifiConnect
  FunctionDeclaration(
    'homeWifiConnect',
    'Connect to a specific Wi-Fi access point. Available ONLY when Wi-Fi is already activated.',
    Schema.object(
      properties: {
        'ap': Schema.string(
          description: 'The name (SSID) of the AP to connect to.',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['ap', 'uiJsonPayload'],
    ),
  ),

  // 14. homeBluetoothList
  FunctionDeclaration(
    'homeBluetoothList',
    'Get the list of available Bluetooth devices. Available ONLY when Bluetooth is already activated.',
    Schema.object(
      properties: {
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 15. homeBluetoothFind
  FunctionDeclaration(
    'homeBluetoothFind',
    'Find a Bluetooth device in the scanned list by name.',
    Schema.object(
      properties: {
        'name': Schema.string(
          description: 'The name of the Bluetooth device to find.',
          nullable: true,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['uiJsonPayload'],
    ),
  ),

  // 16. homeLive
  FunctionDeclaration(
    'homeLive',
    'Play live streaming content for kids or entertainment. Ask a follow-up question after selection.',
    Schema.object(
      properties: {
        'url': Schema.string(
          description: 'Content type to stream: "kids" or "entertainment".',
          nullable: false,
        ),
        'uiJsonPayload': Schema.string(
          description: '명령 수행 결과나 제어 위젯을 화면에 보여주기 위한 genui 패키지 규격의 JSON 문자열',
          nullable: false,
        ),
      },
      requiredProperties: ['url', 'uiJsonPayload'],
    ),
  ),
];

/// Handles an AI function call by running the appropriate device action
/// and returning a `<gen_ui>` wrapped payload for the UI layer.
///
/// Returns a `<gen_ui>...</gen_ui>` string if [uiJsonPayload] is present.
/// Otherwise returns an empty string.
String handleFunctionCall(String name, Map<String, Object?> args) {
  final uiJsonPayload = args['uiJsonPayload'] as String? ?? '';

  switch (name) {
    case 'homeAdditionalFeature':
      // TODO: [Device API] homeAdditionalFeature 파라미터 연동
      break;
    case 'homeApps':
      // TODO: [Device API] homeApps 파라미터 연동
      break;
    case 'homeBluetooth':
      // TODO: [Device API] homeBluetooth 파라미터 연동
      break;
    case 'homeDevice':
      // TODO: [Device API] homeDevice 파라미터 연동
      break;
    case 'homeLanguage':
      // TODO: [Device API] homeLanguage 파라미터 연동
      break;
    case 'homeNotification':
      // TODO: [Device API] homeNotification 파라미터 연동
      break;
    case 'homeSetting':
      // TODO: [Device API] homeSetting 파라미터 연동
      break;
    case 'homeVideo':
      // TODO: [Device API] homeVideo 파라미터 연동
      break;
    case 'homeVolume':
      // TODO: [Device API] homeVolume 파라미터 연동
      break;
    case 'homeWifi':
      // TODO: [Device API] homeWifi 파라미터 연동
      break;
    case 'homeWifiList':
      // TODO: [Device API] homeWifiList 파라미터 연동
      break;
    case 'homeWifiFind':
      // TODO: [Device API] homeWifiFind 파라미터 연동
      break;
    case 'homeWifiConnect':
      // TODO: [Device API] homeWifiConnect 파라미터 연동
      break;
    case 'homeBluetoothList':
      // TODO: [Device API] homeBluetoothList 파라미터 연동
      break;
    case 'homeBluetoothFind':
      // TODO: [Device API] homeBluetoothFind 파라미터 연동
      break;
    case 'homeLive':
      // TODO: [Device API] homeLive 파라미터 연동
      break;
    default:
      break;
  }

  // Always return the uiJsonPayload wrapped in <gen_ui> tags for the UI layer to render.
  return '<gen_ui>$uiJsonPayload</gen_ui>';
}
