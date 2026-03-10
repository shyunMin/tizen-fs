import 'package:flutter/material.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/native/mcp_service.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:tizen_fs/ai/ai_service.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';

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
  bool _isEmulator = false;

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
  AIProvider(this._service);

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

    _isEmulator = await getIt<DeviceInfoProvider>().isEmulator();
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
    _isEmulator = await getIt<DeviceInfoProvider>().isEmulator();
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

    Widget? responseWidget;
    bool isGenUi = false;

    // Detect GenUI response: <gen_ui>...</gen_ui> (A2UI function call result).
    final genUiMatch = RegExp(
      r'^<gen_ui>([\s\S]*)<\/gen_ui>$',
    ).firstMatch(response.trim());

    if (genUiMatch != null) {
      // Extract the raw genui JSON payload from the tag.
      final genUiPayload = genUiMatch.group(1) ?? '';
      responseMessage = genUiPayload;
      isGenUi = true;
    }
    // Handle legacy wrapped JSON format with message and action fields.
    else if (response.startsWith('{')) {
      try {
        final Map<String, dynamic> responseData = ActionManager.genActionData(
          response,
        );

        // Extract message field.
        if (responseData.containsKey('message')) {
          responseMessage = responseData['message'].toString();
        }

        // Extract and execute action field if present.
        if (responseData.containsKey('action')) {
          final actionData = responseData['action'];
          debugPrint('_isEmulator=$_isEmulator');
          if (actionData is Map<String, dynamic>) {
            if (_isEmulator) {
              ActionManager.runAction(actionData);
            } else {
              await McpService.runTool(actionData);
            }
          }
        }
      } catch (e) {
        // If JSON parsing fails, treat as plain text.
        responseMessage = response;
      }
    } else {
      responseMessage = response;
    }

    // Add AI response to history.
    _messageHistory.add(
      ChatMessage(
        content: responseMessage,
        isUser: false,
        isGenUi: isGenUi,
        widget: responseWidget,
      ),
    );
    notifyListeners();
  }
}
