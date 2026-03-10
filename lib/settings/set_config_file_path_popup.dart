import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/ai/ai_config_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';

class SetConfigFilePathPopup extends StatefulWidget {
  const SetConfigFilePathPopup({super.key});

  @override
  State<SetConfigFilePathPopup> createState() => _SetConfigFilePathPopupState();
}

class _SetConfigFilePathPopupState extends State<SetConfigFilePathPopup> {
  late TextEditingController _pathController;
  final FocusNode _pathFocusNode = FocusNode();
  final FocusNode _okFocusNode = FocusNode();
  final FocusNode _cancelFocusNode = FocusNode();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    final configProvider = Provider.of<AIConfigProvider>(
      context,
      listen: false,
    );
    _pathController = TextEditingController(
      text: configProvider.configFilePath,
    );
  }

  @override
  void dispose() {
    _pathController.dispose();
    _pathFocusNode.dispose();
    _okFocusNode.dispose();
    _cancelFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 2);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 2);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selected == 0) {
          _pathFocusNode.requestFocus();
        } else if (_selected == 1) {
          _handleOk();
        } else if (_selected == 2) {
          _handleCancel();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleCancel();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _updateFocus() {
    switch (_selected) {
      case 0:
        _pathFocusNode.requestFocus();
        break;
      case 1:
        _okFocusNode.requestFocus();
        break;
      case 2:
        _cancelFocusNode.requestFocus();
        break;
    }
  }

  void _handleOk() {
    final path = _pathController.text.trim();
    if (path.isEmpty) {
      _showErrorPopup(AppLocalizations.of(context).enterNetworkName);
      return;
    }

    final configProvider = Provider.of<AIConfigProvider>(
      context,
      listen: false,
    );
    configProvider.setConfigFilePath(path);
    Navigator.of(context).pop();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _showErrorPopup(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).ok),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _select(int index) {
    setState(() {
      _selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Container(
                      child: Text(
                        AppLocalizations.of(context).ai,
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ),
                    Container(
                      child: Text(
                        AppLocalizations.of(context).configFilePath,
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 120, 100, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 20,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            _selected == 0
                                ? Colors.white.withAlphaF(0.2)
                                : Colors.white.withAlphaF(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _selected == 0
                                  ? Color(0xF04285F4)
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 300,
                        height: 50,
                        child: TextField(
                          controller: _pathController,
                          focusNode: _pathFocusNode,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            hintText: AppLocalizations.of(context).networkSSID,
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    PopupButton(
                      focusNode: _okFocusNode,
                      text: AppLocalizations.of(context).ok,
                      isSelected: _selected == 1,
                      onPressed: () {
                        _select(1);
                        _handleOk();
                      },
                    ),
                    PopupButton(
                      focusNode: _cancelFocusNode,
                      text: AppLocalizations.of(context).cancel,
                      isSelected: _selected == 2,
                      onPressed: () {
                        _select(2);
                        _handleCancel();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    this.isSelected = false,
    required this.text,
    required this.onPressed,
    this.width = 280,
    this.height = 50,
    this.focusNode,
  });

  final bool isSelected;
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          height: height,
          child: AnimatedScale(
            scale: isSelected ? 1.1 : 1,
            duration: const Duration(milliseconds: 80),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
