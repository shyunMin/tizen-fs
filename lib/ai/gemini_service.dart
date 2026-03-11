import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/ai/gauss_service.dart';
import 'package:tizen_fs/ai/gemini_tools.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/ai/ai_provider.dart';
import 'package:tizen_fs/ai/genui_adapter.dart';
import 'package:genui/genui.dart';

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
    _systemPrompt =
        _promptManager.generateFullPrompt() +
        '\n\n$kFunctionCallingSystemInstruction';

    try {
      final a2uiTools = <AiTool>[
        SurfaceUpdateTool(
          handleMessage: getIt<AIProvider>().a2uiProcessor.handleMessage,
          catalog: CoreCatalogItems.asCatalog(),
        ),
        DeleteSurfaceTool(
          handleMessage: getIt<AIProvider>().a2uiProcessor.handleMessage,
        ),
      ];

      final gaiA2uiTools =
          a2uiTools.map(convertGenuiToolToFunctionDeclaration).toList();

      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        // Register Tizen tools + GenUI tool(s)
        tools: [
          Tool(
            functionDeclarations: [
              ...tizenFunctionDeclarations,
              ...gaiA2uiTools,
            ],
          ),
        ],
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
      debugPrint(response.text);

      // Handle function call + companion text in the same response turn.
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isNotEmpty) {
        final a2uiTools = <AiTool>[
          SurfaceUpdateTool(
            handleMessage: getIt<AIProvider>().a2uiProcessor.handleMessage,
            catalog: CoreCatalogItems.asCatalog(),
          ),
          DeleteSurfaceTool(
            handleMessage: getIt<AIProvider>().a2uiProcessor.handleMessage,
          ),
        ];

        for (final call in functionCalls) {
          debugPrint(
            '[GeminiService] Function call: ${call.name}, args: ${call.args}',
          );

          var isA2ui = false;
          for (final tool in a2uiTools) {
            if (tool.name == call.name) {
              await tool.invoke(call.args);
              isA2ui = true;

              if (call.name == 'surfaceUpdate' ||
                  call.name == 'surface_update') {
                final surfaceId = call.args['surfaceId'] as String?;
                final components = call.args['components'] as List?;
                if (surfaceId != null &&
                    components != null &&
                    components.isNotEmpty) {
                  final String rootId = components.first['id'] as String;
                  getIt<AIProvider>().a2uiProcessor.handleMessage(
                    BeginRendering(surfaceId: surfaceId, root: rootId),
                  );
                }
              }

              break;
            }
          }

          if (!isA2ui) {
            // Execute the device action via ActionManager / McpService.
            await executeFunctionCall(
              call.name,
              call.args,
              isEmulator: _isEmulator,
            );
          }
        }

        // Return the companion text the AI provided alongside the function call.
        final companionText = response.text;
        if (companionText != null && companionText.trim().isNotEmpty) {
          return companionText;
        }

        // If no companion text was generated with the function calls,
        // send a success response back to Gemini to prompt a text follow-up!
        final functionResponses =
            functionCalls
                .map(
                  (call) => FunctionResponse(call.name, {'result': 'success'}),
                )
                .toList();

        final followUpResponse = await _chat!.sendMessage(
          Content.functionResponses(functionResponses),
        );

        final followUpText = followUpResponse.text;
        if (followUpText != null && followUpText.trim().isNotEmpty) {
          return followUpText;
        }

        return '';
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
