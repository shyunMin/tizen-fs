import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/ai/gauss_service.dart';
import 'package:tizen_fs/ai/gemini_tools.dart';

class GeminiService implements AIService {
  bool _isInitialized = false;
  String _apiKey = '';
  String _modelName = 'gemini-2.5-flash';
  String _systemPrompt = '';

  GenerativeModel? _model;
  ChatSession? _chat;
  final _promptManager = SystemPromptManager();

  @override
  String get modelName => _modelName;

  Future<void> _init() async {
    if (_isInitialized) return;

    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
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

    // Combine the base system prompt with the Function Calling instruction rules.
    _systemPrompt =
        _promptManager.generateFullPrompt() +
        '\n\n$kFunctionCallingSystemInstruction';

    try {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        // Register all 16 tizen tools for function calling.
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

      // Handle function call responses (A2UI path).
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isNotEmpty) {
        final call = functionCalls.first;
        debugPrint(
          '[GeminiService] Function call: ${call.name}, args: ${call.args}',
        );
        return handleFunctionCall(call.name, call.args);
      }

      // Plain text response (normal conversation path).
      return response.text ?? 'No response';
    } catch (e) {
      // If a 404 error (model not found) occurs, try reconnecting.
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        _chat = null;
        return sendMessage(message);
      }
      return 'Error: $e';
    }
  }
}
