import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/ai/gauss_service.dart';
import 'package:tizen_fs/ai/gemini_tools.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/locator.dart';

/// System instruction documenting the genui built-in widget catalog.
///
/// This tells the AI which widgets it can reference in its text response
/// so that the UI layer can optionally render them. Since we only use
/// genui built-in widgets, no custom catalog is registered.
const String _kGenUiBuiltinInstruction = '''
[GenUI Built-in Widget Reference]
When your text response includes a structured UI result (e.g. a list, a status),
you MAY produce a genui component array embedded in a <gen_ui>...</gen_ui> tag
using ONLY the following built-in widgets:

Text   — {"Text": {"text": {"literalString": "..."}, "hint": "body1"}}
Image  — {"Image": {"url": {"literalString": "https://..."}, "hint": "mediumFeature"}}
Column — {"Column": {"children": ["<childId1>", "<childId2>"]}}
Row    — {"Row": {"children": ["<childId1>", "<childId2>"]}}
Card   — {"Card": {"child": "<childId>"}}

Format: a JSON array where each object has "id" and "component" keys.
One object MUST have "id": "root".
Example:
<gen_ui>[{"id":"root","component":{"Text":{"text":{"literalString":"Wi-Fi is now ON."},"hint":"body1"}}}]</gen_ui>

Only include a <gen_ui> block when it genuinely improves the UX.
For simple confirmations, plain text is preferred.
''';

class GeminiService implements AIService {
  bool _isInitialized = false;
  String _apiKey = '';
  final String _modelName = 'gemini-2.5-flash';
  String _systemPrompt = '';
  bool _isEmulator = false;

  GenerativeModel? _model;
  ChatSession? _chat;
  final _promptManager = SystemPromptManager();

  @override
  String get modelName => _modelName;

  Future<void> _init() async {
    if (_isInitialized) return;

    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _isEmulator = await getIt<DeviceInfoProvider>().isEmulator();
    await _promptManager.initialize();
    _isInitialized = true;
  }

  @override
  Future<void> disconnect() async {
    _chat = null;
    _model = null;
  }

  @override
  Future<bool> connect() async {
    await _init();
    if (!_isInitialized) return false;

    // Combine the base system prompt with function calling rules (logic_flow + output_rules)
    // and the genui built-in widget reference.
    _systemPrompt =
        _promptManager.generateFullPrompt() +
        '\n\n$kFunctionCallingSystemInstruction' +
        '\n\n$_kGenUiBuiltinInstruction';

    try {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        // Register all 16 Tizen device tools for function calling.
        tools: [Tool(functionDeclarations: tizenFunctionDeclarations)],
      );
      _chat = _model!.startChat();
      return true;
    } catch (e) {
      debugPrint('[GeminiService] Connect error: $e');
      return false;
    }
  }

  @override
  Future<String> sendMessage(String message) async {
    if (_chat == null) {
      final connected = await connect();
      if (!connected) return 'Connection Failed';
    }

    try {
      final response = await _chat!.sendMessage(Content.text(message));

      // Handle function call + companion text in the same response turn.
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isNotEmpty) {
        final call = functionCalls.first;
        debugPrint(
          '[GeminiService] Function call: ${call.name}, args: ${call.args}',
        );

        // Execute the device action via ActionManager / McpService.
        await executeFunctionCall(
          call.name,
          call.args,
          isEmulator: _isEmulator,
        );

        // Return the companion text the AI provided alongside the function call.
        // If the model gave no text (some models omit it), give a sensible fallback.
        final companionText = response.text;
        if (companionText != null && companionText.trim().isNotEmpty) {
          return companionText;
        }
        return '✅ ${call.name} has been executed.';
      }

      // Normal conversation response (MODE A — no tool invoked).
      return response.text ?? 'No response';
    } catch (e) {
      // On 404 (model not found), reconnect and retry once.
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        _chat = null;
        return sendMessage(message);
      }
      return 'Error: $e';
    }
  }
}
