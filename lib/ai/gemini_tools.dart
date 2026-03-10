import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:tizen_fs/native/mcp_service.dart';

// ---------------------------------------------------------------------------
// Gemini Function Calling — Tizen Device Tools
//
// These FunctionDeclarations mirror the tools.txt specification.
// The AI calls these functions instead of producing a raw JSON action block.
// The uiJsonPayload is NO LONGER a parameter here; genui rendering is handled
// separately by the AI's text response (normal conversation turn).
// ---------------------------------------------------------------------------

/// System instruction that replaces logic_flow.txt + output_rules.txt for Gemini.
/// This tells the model to use Function Calling instead of a raw JSON action block.
const String kFunctionCallingSystemInstruction = '''
[Function Calling Rules — Replace MODE B with Tool Calls]
You are a highly intelligent, empathetic AI assistant for a Tizen smart TV device.

DECISION LOGIC (replaces the legacy MODE A / MODE B output rules):

1. GENERAL CONVERSATION (no tool needed):
   - Weather, knowledge, opinions, casual chat → respond with plain text only.
   - If a requested action is already in the desired state (e.g. Wi-Fi is already on) → respond in plain text explaining the current state.

2. SYSTEM ACTION (call the matching tool):
   - Wi-Fi:
     • "Turn on Wi-Fi" AND wifi_power is "on"  → call homeWifiList
     • "Turn on Wi-Fi" AND wifi_power is "off" → call homeWifi(command:"on")
     • "Turn off Wi-Fi" AND wifi_power is "on" → call homeWifi(command:"off")
   - Bluetooth:
     • "Turn on Bluetooth" AND bluetooth_power is "on"  → call homeBluetoothList
     • "Turn on Bluetooth" AND bluetooth_power is "off" → call homeBluetooth(command:"on")
     • "Turn off Bluetooth" AND bluetooth_power is "on" → call homeBluetooth(command:"off")
   - Volume: call homeVolume with the appropriate command.
     ⚠ If the user says ears hurt, sound is too loud, or asks to lower volume → use "down", NEVER "mute".
   - Boredom / entertainment → call homeLive(url:"entertainment")
   - Child content → call homeLive(url:"kids")
   - Specific video → call homeVideo
   - App-related:
     • Launch/sort/filter apps on home screen → call homeApps
     • Configure apps / open settings menu → call homeSetting
   - All other tool intents → call the matching tool from the tool list.

3. APP VIEWS DISTINCTION:
   - homeApps (Launcher View): launching apps, sort order of home screen icons, filter by app type.
   - homeSetting (Management View): configure apps, installed/running lists, settings menus.

4. RESPONSE TEXT (companion text for every tool call):
   - After calling a tool, you MUST ALSO provide a rich, warm, empathetic text response explaining what you did.
   - If the action relates to settings, include the relevant settings URL (e.g. "/settings/wifi") in your response.
   - Use markdown formatting (\\n\\n, **bold**) for readability.
   - Do NOT output raw JSON in your text response.
''';

/// Converts the tools.txt specification into a list of [FunctionDeclaration] objects.
final List<FunctionDeclaration> tizenFunctionDeclarations = [
  // 1. homeAdditionalFeature
  FunctionDeclaration(
    'homeAdditionalFeature',
    'Enable or disable specific features (media, live, ai).',
    Schema.object(
      properties: {
        'featureName': Schema.string(
          description: 'Feature to toggle: "media", "live", or "ai".',
          nullable: false,
        ),
        'enabled': Schema.string(
          description: '"on" to enable, "off" to disable.',
          nullable: false,
        ),
      },
      requiredProperties: ['featureName', 'enabled'],
    ),
  ),

  // 2. homeApps
  FunctionDeclaration(
    'homeApps',
    'Home Screen App List action: launch, sort, or filter apps.',
    Schema.object(
      properties: {
        'sort': Schema.string(
          description: 'Sort order: "DESC" or "ASC".',
          nullable: true,
        ),
        'type': Schema.string(
          description: 'Filter by type: "", "dotnet", "capp", or "webapp".',
          nullable: true,
        ),
        'app_name': Schema.string(
          description: 'Keyword to search or filter apps.',
          nullable: true,
        ),
      },
      requiredProperties: [],
    ),
  ),

  // 3. homeBluetooth
  FunctionDeclaration(
    'homeBluetooth',
    'Turn Bluetooth on or off.',
    Schema.object(
      properties: {
        'command': Schema.string(
          description: '"on" or "off".',
          nullable: false,
        ),
      },
      requiredProperties: ['command'],
    ),
  ),

  // 4. homeDevice
  FunctionDeclaration(
    'homeDevice',
    'Change the device name.',
    Schema.object(
      properties: {
        'name': Schema.string(description: 'New device name.', nullable: false),
      },
      requiredProperties: ['name'],
    ),
  ),

  // 5. homeLanguage
  FunctionDeclaration(
    'homeLanguage',
    'Change system language. Map korean→ko_KR, english→en_US.',
    Schema.object(
      properties: {
        'language': Schema.string(
          description: '"ko_KR" for Korean, "en_US" for English.',
          nullable: false,
        ),
      },
      requiredProperties: ['language'],
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
      },
      requiredProperties: ['command'],
    ),
  ),

  // 7. homeSetting
  FunctionDeclaration(
    'homeSetting',
    'Open a specific System Settings page.',
    Schema.object(
      properties: {
        'uri': Schema.string(
          description:
              'Settings URI: "/settings", "/settings/wifi", "/settings/bluetooth", '
              '"/settings/date_time", "/settings/language_input", "/settings/apps", '
              '"/settings/apps/installed_apps", "/settings/apps/running_apps", '
              '"/settings/apps/all_apps", "/settings/storage", "/settings/volume", '
              '"/settings/additional_features", "/settings/profile", "/settings/about_device".',
          nullable: false,
        ),
      },
      requiredProperties: ['uri'],
    ),
  ),

  // 8. homeVideo
  FunctionDeclaration(
    'homeVideo',
    'Play a video.',
    Schema.object(properties: {}, requiredProperties: []),
  ),

  // 9. homeVolume
  FunctionDeclaration(
    'homeVolume',
    'Adjust system volume. Use "down" when user expresses discomfort — never "mute".',
    Schema.object(
      properties: {
        'command': Schema.string(
          description:
              '"up", "down", "mute", or "unmute". Use "down" for auditory discomfort.',
          nullable: true,
        ),
        'level': Schema.string(
          description: 'Specific volume value (0–100).',
          nullable: true,
        ),
      },
      requiredProperties: [],
    ),
  ),

  // 10. homeWifi
  FunctionDeclaration(
    'homeWifi',
    'Turn Wi-Fi on or off.',
    Schema.object(
      properties: {
        'command': Schema.string(
          description: '"on" or "off".',
          nullable: false,
        ),
      },
      requiredProperties: ['command'],
    ),
  ),

  // 11. homeWifiList
  FunctionDeclaration(
    'homeWifiList',
    'Get list of available Wi-Fi APs. Only when Wi-Fi is already active.',
    Schema.object(properties: {}, requiredProperties: []),
  ),

  // 12. homeWifiFind
  FunctionDeclaration(
    'homeWifiFind',
    'Find a specific AP in the scanned list by name.',
    Schema.object(
      properties: {
        'name': Schema.string(
          description: 'SSID to search for.',
          nullable: true,
        ),
      },
      requiredProperties: [],
    ),
  ),

  // 13. homeWifiConnect
  FunctionDeclaration(
    'homeWifiConnect',
    'Connect to a specific Wi-Fi AP. Only when Wi-Fi is already active.',
    Schema.object(
      properties: {
        'ap': Schema.string(
          description: 'SSID of the AP to connect to.',
          nullable: false,
        ),
      },
      requiredProperties: ['ap'],
    ),
  ),

  // 14. homeBluetoothList
  FunctionDeclaration(
    'homeBluetoothList',
    'Get list of nearby Bluetooth devices. Only when Bluetooth is already active.',
    Schema.object(properties: {}, requiredProperties: []),
  ),

  // 15. homeBluetoothFind
  FunctionDeclaration(
    'homeBluetoothFind',
    'Find a Bluetooth device in the scanned list by name.',
    Schema.object(
      properties: {
        'name': Schema.string(
          description: 'Device name to search for.',
          nullable: true,
        ),
      },
      requiredProperties: [],
    ),
  ),

  // 16. homeLive
  FunctionDeclaration(
    'homeLive',
    'Play live streaming for kids or entertainment. Ask a follow-up question.',
    Schema.object(
      properties: {
        'url': Schema.string(
          description: '"kids" or "entertainment".',
          nullable: false,
        ),
      },
      requiredProperties: ['url'],
    ),
  ),
];

/// Executes the device action corresponding to [name] with [args].
///
/// Returns `null` — the caller is responsible for using McpService or
/// ActionManager. UI rendering is handled by the AI's text response.
Future<void> executeFunctionCall(
  String name,
  Map<String, Object?> args, {
  required bool isEmulator,
}) async {
  final actionData = <String, dynamic>{'__K_ACTION_NAME': name, ...args};
  debugPrint('[FunctionCall] Executing: $name args=$args');

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
      debugPrint('[FunctionCall] Unknown function: $name');
      return;
  }

  // Dispatch through the existing action pipeline.
  if (isEmulator) {
    ActionManager.runAction(actionData);
  } else {
    await McpService.runTool(actionData);
  }
}
