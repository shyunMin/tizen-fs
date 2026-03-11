import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:genui/genui.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final Widget? widget;
  final DateTime timestamp;

  /// If true, [content] holds a genui JSON payload to be rendered as a UI widget.
  final bool isGenUi;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.widget,
    this.isGenUi = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _enabled = false;

  Future<bool>? _connect;
  Future<String>? _sendMessage;

  bool get isConnecting => _isConnecting;
  set isConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }

  bool get isConnected => _isConnected;
  set isConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  bool _isThinking = false;
  bool get isThinking => _isThinking;
  set isThinking(bool value) {
    _isThinking = value;
    notifyListeners();
  }

  String _responseMessage = '';
  String get responseMessage => _responseMessage;
  set responseMessage(String value) {
    _responseMessage = value;
    notifyListeners();
  }

  String _userMessage = '';
  String get userMessage => _userMessage;
  set userMessage(String value) {
    _userMessage = value;
    notifyListeners();
  }

  List<ChatMessage> _messageHistory = [];
  List<ChatMessage> get messageHistory => List.unmodifiable(_messageHistory);

  final AIService _service;
  late final A2uiMessageProcessor a2uiProcessor;

  AIProvider(this._service) {
    a2uiProcessor = A2uiMessageProcessor(
      catalogs: [CoreCatalogItems.asCatalog()],
    );

    a2uiProcessor.surfaceUpdates.listen((update) {
      debugPrint('[AIProvider] Received surface update: ${update.toString()}');
      if (update is SurfaceAdded) {
        debugPrint(
          '[AIProvider] SurfaceAdded fired! Adding GenUiSurface to message history.',
        );
        // Render the newly added GenUI surface into the chat log
        addSystemMessageWithWidget(
          GenUiSurface(host: a2uiProcessor, surfaceId: update.surfaceId),
          GenUiSurface,
        );
      }
      // Note: SurfaceUpdated and SurfaceRemoved are handled natively by GenUiSurface rebuilds.
    });
  }

  void updateLastMessageWithWidget(Widget widget) {
    if (_messageHistory.isNotEmpty && !_messageHistory.last.isUser) {
      final lastMessage = _messageHistory.last;
      final updatedMessage = ChatMessage(
        content: lastMessage.content,
        isUser: lastMessage.isUser,
        widget: widget,
        isGenUi: lastMessage.isGenUi,
        timestamp: lastMessage.timestamp,
      );

      _messageHistory.removeLast();
      _messageHistory.add(updatedMessage);
      notifyListeners();
    }
  }

  void addSystemMessageWithWidget(Widget widget, dynamic widgetType) {
    // Create a system message that contains only the widget
    // This allows standalone widgets to scroll naturally with the message history
    final systemMessage = ChatMessage(
      content: '',
      isUser: false,
      widget: widget,
    );
    _messageHistory.add(systemMessage);
    notifyListeners();
  }

  Future<void> enable() async {
    if (isConnected) return;

    await connect();
    if (isConnected) {
      responseMessage = '**${_service.modelName}** has been connected.';
    } else {
      responseMessage = 'Failed to connect to model.';
    }
    _messageHistory.add(
      ChatMessage(
        content: responseMessage,
        isUser: false,
        // widget: responseWidget,
      ),
    );
    notifyListeners();
  }

  Future<void> disable() async {
    await disconnect();
    _userMessage = '';
    _responseMessage = '';
    _messageHistory.clear();
    notifyListeners();
  }

  Future<void> connect() async {
    _enabled = true;
    if (isConnected) return;

    isConnecting = true;
    _connect ??= _service.connect();
    isConnected = await _connect ?? false;
    _connect = null;
    isConnecting = false;
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    isConnected = false;
    _enabled = false;
  }

  Future<void> sendMessage(String message) async {
    if (!_enabled) return;

    if (!isConnected) return;

    isThinking = true;

    if (_sendMessage == null) {
      userMessage = message;
      responseMessage = '';

      // Add user message to history
      _messageHistory.add(ChatMessage(content: message, isUser: true));
      notifyListeners();
    }

    _sendMessage ??= _service.sendMessage(message);
    final response = await _sendMessage ?? '';
    _sendMessage = null;

    isThinking = false;

    // The AI's companion text is always returned as a normal response.
    // However, if the response is a raw JSON string (e.g. from Gauss or fallback legacy mode),
    // we should parse it, execute the action silently, and extract the text message.
    String finalResponseText = response;

    try {
      final decoded = jsonDecode(response);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message')) {
          finalResponseText = decoded['message'].toString();
        }
        if (decoded.containsKey('action')) {
          final actionInfo = decoded['action'];
          if (actionInfo is Map<String, dynamic>) {
            // Execute the action natively
            ActionManager.runAction(actionInfo);
          }
        }
      }
    } catch (_) {
      // Not a valid JSON string (expected case for direct text replies).
    }

    // UI rendering (SurfaceAdded) is handled independently via a2uiProcessor stream.
    responseMessage = finalResponseText;

    _messageHistory.add(
      ChatMessage(content: finalResponseText, isUser: false, isGenUi: false),
    );

    notifyListeners();
  }
}
