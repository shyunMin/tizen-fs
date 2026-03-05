import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/actions/bluetooth_list_widget.dart';
import 'package:tizen_fs/actions/bluetooth_widget.dart';
import 'package:tizen_fs/actions/live_widget.dart';
import 'package:tizen_fs/actions/volume_widget.dart';
import 'package:tizen_fs/actions/wifi_list_widget.dart';
import 'package:tizen_fs/actions/wifi_widget.dart';
import 'package:tizen_fs/models/action_model.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/ai/ai_provider.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/ui_event.dart';
import 'package:tizen_fs/widgets/auto_suggestion_field.dart';
import 'package:tizen_fs/widgets/lottie_view.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  final GlobalKey<AutoSuggestFieldState> _textfieldkey =
      GlobalKey<AutoSuggestFieldState>();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _subscription;

  late AIProvider _aiProvider;
  bool isAiEnabled = false;
  Widget? _widget;
  DateTime? _widgetTimestamp;

  @override
  void initState() {
    super.initState();
    _init();

    isAiEnabled =
        context
            .read<AdditaionalFeatureProvider>()
            .getFeature('ai')
            ?.isEnabled ??
        false;

    _subscription = ActionManager.eventStream.listen(_onActionEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textfieldkey.currentState?.requestFocus();
        if (isAiEnabled) {
          _initChat();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _aiProvider = context.read<AIProvider>();
    isAiEnabled =
        context
            .read<AdditaionalFeatureProvider>()
            .getFeature('ai')
            ?.isEnabled ??
        false;
  }

  void _init() async {
    await context.read<ActionModel>().loadCommands();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void _initChat() async {
    final aiProvider = context.read<AIProvider>();
    await aiProvider.enable();

    // Only add connection status message if history is empty (first time initialization)
    // This prevents adding duplicate messages when page is popped and pushed again
    if (aiProvider.messageHistory.isEmpty) {
      if (aiProvider.isConnected && aiProvider.responseMessage.isNotEmpty) {
        aiProvider.addSystemMessageWithWidget(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: MarkdownBody(data: aiProvider.responseMessage),
          ),
          'connection_status',
        );
      } else if (!aiProvider.isConnected &&
          aiProvider.responseMessage.isNotEmpty) {
        aiProvider.addSystemMessageWithWidget(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              aiProvider.responseMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
          'connection_status',
        );
      }
    }

    // Scroll to bottom after initialization
    _scrollToBottom();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    // _aiProvider.disable();
    super.dispose();
  }

  void _onActionEvent(UiEvent event) {
    if (!mounted) return;

    if (event is ShowMessageEvent) {
      context.read<AIProvider>().responseMessage = event.message;
    }
    if (event is ShowWidgetEvent) {
      _generateWidget(event);
    }
  }

  void _generateWidget(ShowWidgetEvent event) {
    Widget? newWidget;
    if (event.widgetType == WidgetType.wifi) {
      newWidget = WifiWidget();
    } else if (event.widgetType == WidgetType.wifiList ||
        event.widgetType == WidgetType.wifiFind) {
      newWidget = WifiListWidget();
    } else if (event.widgetType == WidgetType.bluetooth) {
      newWidget = BluetoothWidget();
    } else if (event.widgetType == WidgetType.bluetoothList ||
        event.widgetType == WidgetType.bluetoothFind) {
      newWidget = BluetoothListWidget();
    } else if (event.widgetType == WidgetType.volume) {
      newWidget = VolumeWidget();
    } else if (event.widgetType == WidgetType.live) {
      newWidget = LiveWidget(url: event.param ?? '');
    }
    if (newWidget != null) {
      final aiProvider = context.read<AIProvider>();
      final history = aiProvider.messageHistory;

      _widget = newWidget;
      _widgetTimestamp = DateTime.now();

      if (history.isNotEmpty && !history.last.isUser) {
        // Attach to the last AI message (aiProvider.notifyListeners will trigger rebuild)
        aiProvider.updateLastMessageWithWidget(newWidget);
      } else {
        // Create a system message for standalone widgets so they scroll with messages
        // (aiProvider.notifyListeners will trigger rebuild)
        aiProvider.addSystemMessageWithWidget(newWidget, event.widgetType);
      }

      // No need to call setState() here as aiProvider.notifyListeners() will trigger rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnecting = context.watch<AIProvider>().isConnecting;
    final isThinking = context.watch<AIProvider>().isThinking;

    // // Auto-scroll to bottom whenever messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          if (isAiEnabled && isConnecting)
            const Center(child: CircularProgressIndicator()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 20, 35, 5),
                  child: Focus(
                    canRequestFocus: false,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent || event is KeyRepeatEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.goBack ||
                            event.logicalKey == LogicalKeyboardKey.escape ||
                            event.physicalKey == PhysicalKeyboardKey.escape) {
                          RouterService.instance.safePop();
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: AutoSuggestField(
                      key: _textfieldkey,
                      suggestions: context.read<ActionModel>().actions,
                      onSelected: (suggestion) async {
                        _runAction(suggestion);
                      },
                      onSubmitted: (suggestion) async {
                        _runAction(suggestion);
                      },
                    ),
                  ),
                ),
              ),
              if (!isConnecting)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(70, 0, 70, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display message history
                            ...context.watch<AIProvider>().messageHistory.map(
                              (chatMessage) => _buildMessageBubble(chatMessage),
                            ),
                            // Show thinking indicator if AI is processing
                            if (isThinking)
                              Row(
                                children: [
                                  LottieView(
                                    assetPath: 'assets/animation/ai_robot.json',
                                    width: 200,
                                    autoplay: true,
                                    loop: true,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }

  bool _isWidgetAttachedToMessage() {
    if (_widgetTimestamp == null) return false;

    final history = context.read<AIProvider>().messageHistory;
    if (history.isEmpty) return false;

    // Check if the last AI message was created after the widget
    final lastAiMessage = history.lastWhere(
      (msg) => !msg.isUser,
      orElse: () => history.first,
    );

    return lastAiMessage.widget != null &&
        lastAiMessage.timestamp.isAfter(_widgetTimestamp!);
  }

  Widget _buildMessageBubble(ChatMessage chatMessage) {
    if (chatMessage.isUser) {
      // User message bubble (right-aligned)
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
                topRight: Radius.zero,
              ),
              color: Colors.white.withAlphaF(0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                chatMessage.content,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      );
    } else {
      // AI message bubble (left-aligned)
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show text content if present
            if (chatMessage.content.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  // color: Colors.orange,
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    child: MarkdownBody(data: chatMessage.content),
                  ),
                ),
              ),
            // Display widget if attached to this message
            if (chatMessage.widget != null) chatMessage.widget!,
          ],
        ),
      );
    }
  }

  void _runAction(String message) async {
    debugPrint('message: $message');
    if (message.isEmpty) return;

    final actionData = await ActionManager.generateAction(message);

    if (isAiEnabled && actionData.isEmpty) {
      if (mounted) {
        context.read<AIProvider>().sendMessage(message);
      }
    } else {
      // Only clear widget if a direct action is being executed
      // Keep existing widget if it was attached to a message
      if (!_isWidgetAttachedToMessage()) {
        _widget = null;
        _widgetTimestamp = null;
      }

      await ActionManager.runAction(actionData);
    }
  }
}
