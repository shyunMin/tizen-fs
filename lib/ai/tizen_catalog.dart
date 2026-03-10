import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

// ---------------------------------------------------------------------------
// Tizen TV Widget Catalog
//
// Each CatalogItem follows the genui pattern:
//   - itemContext.data: the JSON map from the AI
//   - itemContext.buildContext: the BuildContext for rendering
// ---------------------------------------------------------------------------

// ─── Helper ─────────────────────────────────────────────────────────────────

/// Resolves a map binding or literal to its `String` value.
/// genui passes data as {"literalString": "..."} or a data-model path binding.
String? _str(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value['literalString'] as String?;
  if (value is String) return value;
  return null;
}

/// Resolves a map binding to its `int` value.
int? _int(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) {
    final v = value['literalInt'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
  }
  if (value is int) return value;
  return null;
}

/// Resolves a map binding to its `bool` value.
bool? _bool(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) {
    final v = value['literalBool'];
    if (v is bool) return v;
  }
  if (value is bool) return value;
  return null;
}

/// Maps a string icon name to a Material [IconData].
IconData _resolveIcon(String? name) {
  switch (name?.toLowerCase()) {
    case 'wifi':
      return Icons.wifi;
    case 'bluetooth':
      return Icons.bluetooth;
    case 'volume_up':
    case 'volume':
      return Icons.volume_up;
    case 'settings':
      return Icons.settings;
    case 'headphones':
      return Icons.headphones;
    case 'speaker':
      return Icons.speaker;
    case 'phone':
      return Icons.phone_android;
    case 'language':
      return Icons.language;
    case 'device':
      return Icons.devices;
    case 'notification':
      return Icons.notifications;
    case 'live':
      return Icons.live_tv;
    case 'apps':
      return Icons.apps;
    case 'video':
      return Icons.play_circle_fill;
    default:
      return Icons.info_outline;
  }
}

// ─── Container style ────────────────────────────────────────────────────────

BoxDecoration _card() => BoxDecoration(
  color: Colors.white12,
  borderRadius: BorderRadius.circular(12),
);

// ---------------------------------------------------------------------------
// 1. StatusCard — generic action confirmation feedback
// ---------------------------------------------------------------------------

final _statusCardSchema = S.object(
  properties: {
    'title': S.string(description: 'Short title, e.g. "Wi-Fi On"'),
    'subtitle': S.string(description: 'Supporting confirmation message.'),
    'icon': S.string(
      description:
          'Material icon name: wifi | bluetooth | volume_up | settings | notification | language | device | apps | video | live',
    ),
  },
  required: ['title', 'subtitle'],
);

final statusCardItem = CatalogItem(
  name: 'StatusCard',
  dataSchema: _statusCardSchema,
  widgetBuilder: (ctx) {
    final data = ctx.data as JsonMap;
    final title = _str(data['title']) ?? '';
    final subtitle = _str(data['subtitle']) ?? '';
    final iconData = _resolveIcon(_str(data['icon']));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        children: [
          Icon(iconData, color: Colors.lightBlueAccent, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// 2. VolumeControl — visual volume level display
// ---------------------------------------------------------------------------

final _volumeControlSchema = S.object(
  properties: {
    'label': S.string(description: 'Label for the control, e.g. "Volume"'),
    'level': S.integer(description: 'Current volume level 0–100.'),
  },
  required: ['label', 'level'],
);

final volumeControlItem = CatalogItem(
  name: 'VolumeControl',
  dataSchema: _volumeControlSchema,
  widgetBuilder: (ctx) {
    final data = ctx.data as JsonMap;
    final label = _str(data['label']) ?? 'Volume';
    final level = (_int(data['level']) ?? 50).clamp(0, 100);
    final ratio = level / 100.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text('$level', style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.lightBlueAccent,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// 3. WifiList — nearby Wi-Fi access point list
// ---------------------------------------------------------------------------

final _wifiListSchema = S.object(
  properties: {
    'title': S.string(description: 'Section title, e.g. "Available Networks"'),
    'networks': S.list(
      items: S.object(
        properties: {
          'ssid': S.string(description: 'Wi-Fi SSID name.'),
          'strength': S.integer(description: 'Signal strength 0-4.'),
          'secured': S.boolean(description: 'Whether a password is required.'),
        },
        required: ['ssid'],
      ),
      description: 'List of Wi-Fi networks.',
    ),
  },
  required: ['title', 'networks'],
);

final wifiListItem = CatalogItem(
  name: 'WifiList',
  dataSchema: _wifiListSchema,
  widgetBuilder: (ctx) {
    final data = ctx.data as JsonMap;
    final title = _str(data['title']) ?? 'Networks';
    final rawNetworks = data['networks'];
    final networks = (rawNetworks is List ? rawNetworks : []).cast<dynamic>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...networks.map((n) {
            final net = n as Map<String, dynamic>? ?? {};
            final ssid = _str(net['ssid']) ?? '';
            final secured = _bool(net['secured']) ?? false;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ssid,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  if (secured)
                    const Icon(Icons.lock, size: 14, color: Colors.white38),
                ],
              ),
            );
          }),
        ],
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// 4. BluetoothList — nearby Bluetooth device list
// ---------------------------------------------------------------------------

final _bluetoothListSchema = S.object(
  properties: {
    'title': S.string(description: 'Section title, e.g. "Nearby Devices"'),
    'devices': S.list(
      items: S.object(
        properties: {
          'name': S.string(description: 'Device name.'),
          'type': S.string(
            description: 'Type hint: headphones | speaker | phone.',
          ),
        },
        required: ['name'],
      ),
      description: 'List of Bluetooth devices.',
    ),
  },
  required: ['title', 'devices'],
);

final bluetoothListItem = CatalogItem(
  name: 'BluetoothList',
  dataSchema: _bluetoothListSchema,
  widgetBuilder: (ctx) {
    final data = ctx.data as JsonMap;
    final title = _str(data['title']) ?? 'Devices';
    final rawDevices = data['devices'];
    final devices = (rawDevices is List ? rawDevices : []).cast<dynamic>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bluetooth, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...devices.map((d) {
            final dev = d as Map<String, dynamic>? ?? {};
            final name = _str(dev['name']) ?? '';
            final type = _str(dev['type']);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(_resolveIcon(type), size: 18, color: Colors.white38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// 5. ToggleResult — confirms on/off toggle result
// ---------------------------------------------------------------------------

final _toggleResultSchema = S.object(
  properties: {
    'feature': S.string(description: 'Feature name, e.g. "AI Mode", "Live TV"'),
    'enabled': S.boolean(
      description: 'True if turned on, false if turned off.',
    ),
    'message': S.string(description: 'Human-readable confirmation message.'),
  },
  required: ['feature', 'enabled', 'message'],
);

final toggleResultItem = CatalogItem(
  name: 'ToggleResult',
  dataSchema: _toggleResultSchema,
  widgetBuilder: (ctx) {
    final data = ctx.data as JsonMap;
    final feature = _str(data['feature']) ?? '';
    final enabled = _bool(data['enabled']) ?? false;
    final message = _str(data['message']) ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.greenAccent : Colors.redAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// Catalog assembly
// ---------------------------------------------------------------------------

/// All custom Tizen TV CatalogItems merged with the built-in CoreCatalogItems.
Catalog buildTizenCatalog() {
  return CoreCatalogItems.asCatalog().copyWith([
    statusCardItem,
    volumeControlItem,
    wifiListItem,
    bluetoothListItem,
    toggleResultItem,
  ]);
}

// ---------------------------------------------------------------------------
// AI System Instruction
// ---------------------------------------------------------------------------

/// Documents the available Tizen widget catalog to the AI.
///
/// Append this to the Gemini system instruction so the model knows the exact
/// JSON schema to produce in [uiJsonPayload].
const String kTizenCatalogInstruction = r'''
[Available UI Widget Catalog]
When populating `uiJsonPayload`, produce a JSON *array* of component objects.
Each component follows the genui A2UI protocol:
  [
    {
      "id": "root",
      "component": { "<WidgetName>": { <properties> } }
    }
  ]

Property values use the genui literal notation:
  - String:  {"literalString": "your text here"}
  - Integer: {"literalInt": 42}
  - Boolean: {"literalBool": true}

Use ONLY the widget names listed below. Do NOT invent names.

---

StatusCard — generic action confirmation (use for most tool results)
Properties:
  title    (required, string) — short title, e.g. "Wi-Fi On"
  subtitle (required, string) — confirmation message
  icon     (optional, string) — one of: wifi | bluetooth | volume_up | settings | notification | language | device | apps | video | live

Example:
[{"id":"root","component":{"StatusCard":{"title":{"literalString":"Wi-Fi Enabled"},"subtitle":{"literalString":"Wi-Fi has been turned on."},"icon":{"literalString":"wifi"}}}}]

---

VolumeControl — use for homeVolume
Properties:
  label (required, string)  — e.g. "Volume"
  level (required, integer) — 0–100

Example:
[{"id":"root","component":{"VolumeControl":{"label":{"literalString":"Volume"},"level":{"literalInt":35}}}}]

---

WifiList — use for homeWifiList / homeWifiFind
Properties:
  title    (required, string) — e.g. "Available Networks"
  networks (required, array)  — each item: {ssid(string,req), strength(int,0-4,opt), secured(bool,opt)}

Example:
[{"id":"root","component":{"WifiList":{"title":{"literalString":"Available Networks"},"networks":[{"ssid":{"literalString":"HomeNetwork"},"strength":{"literalInt":4},"secured":{"literalBool":true}}]}}}]

---

BluetoothList — use for homeBluetoothList / homeBluetoothFind
Properties:
  title   (required, string) — e.g. "Nearby Devices"
  devices (required, array)  — each item: {name(string,req), type(string,opt: headphones|speaker|phone)}

Example:
[{"id":"root","component":{"BluetoothList":{"title":{"literalString":"Nearby Devices"},"devices":[{"name":{"literalString":"Galaxy Buds"},"type":{"literalString":"headphones"}}]}}}]

---

ToggleResult — use for homeAdditionalFeature, homeBluetooth, homeWifi on/off
Properties:
  feature (required, string)  — e.g. "Wi-Fi"
  enabled (required, boolean) — true if on, false if off
  message (required, string)  — human-readable result

Example:
[{"id":"root","component":{"ToggleResult":{"feature":{"literalString":"Wi-Fi"},"enabled":{"literalBool":false},"message":{"literalString":"Wi-Fi has been turned off."}}}}]

---

Text (built-in) — simple text line
[{"id":"root","component":{"Text":{"text":{"literalString":"Your message"},"hint":"body1"}}}]

---

RULE: The value of `uiJsonPayload` MUST be a valid JSON array string (as shown above).
''';
