import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/ai/gauss_service.dart';

class GeminiService implements AIService {
  bool _isInitialized = false;
  String _apiKey = ''; // Replace with your actual key
  String _modelName = 'gemini-2.5-flash'; // Default value
  String _systemPrompt = '';

  GenerativeModel? _model;
  ChatSession? _chat;
  final _promptManager = SystemPromptManager();

  @override
  String get modelName => _modelName;

  Future<void> _init() async {
    if (_isInitialized) return;

    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    // Add initialization for _promptManager if needed
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

    _systemPrompt = _promptManager.generateFullPrompt();

    try {
      // 3. Connect to the selected model
      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );
      _chat = _model!.startChat();

      return true;
    } catch (e) {
      debugPrint('[GeminiService] Connect/ListModels Error: $e');
      // If the model list fails, retry with the default value
      try {
        return true;
      } catch (innerE) {
        return false;
      }
    }
  }

  @override
  Future<String> sendMessage(String message) async {
    if (_chat == null) {
      bool connected = await connect();
      if (!connected) return "Connection Failed";
    }

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? "No response";
    } catch (e) {
      // If a 404 error (model not found) occurs, try reconnecting
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        _chat = null;
        return sendMessage(message);
      }
      return "Error: $e";
    }
  }
}
