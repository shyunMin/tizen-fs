import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/live/stream_channel.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

class ChannelAddPopup extends StatefulWidget {
  const ChannelAddPopup({
    required this.nameController,
    required this.urlController,
    required this.onAdd,
    this.onShowRecommend,
  });

  final TextEditingController nameController;
  final TextEditingController urlController;
  final Function(StreamChannel) onAdd;
  final VoidCallback? onShowRecommend;

  @override
  State<ChannelAddPopup> createState() => _AddChannelPopupState();
}

class _AddChannelPopupState extends State<ChannelAddPopup> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _okFocusNode = FocusNode();
  final FocusNode _recommendFocusNode = FocusNode();
  int _selected = 0;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _urlFocusNode.dispose();
    _okFocusNode.dispose();
    _recommendFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 3);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 3);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleEnterKey();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleEnterKey() {
    if (_selected == 2) {
      _handleAdd();
    } else if (_selected == 3) {
      _handleShowRecommend();
    }
  }

  void _updateFocus() {
    if (_selected == 0) {
      _nameFocusNode.requestFocus();
    } else if (_selected == 1) {
      _urlFocusNode.requestFocus();
    } else if (_selected == 2) {
      _okFocusNode.requestFocus();
    } else {
      _recommendFocusNode.requestFocus();
    }
  }

  void _handleShowRecommend() {
    if (widget.onShowRecommend != null) {
      Navigator.of(context).pop();
      widget.onShowRecommend!();
    }
  }

  void _handleAdd() {
    if (widget.nameController.text.isEmpty) {
      ToastMessage.show(
        context,
        "${AppLocalizations.of(context).notAvailable} ${AppLocalizations.of(context).name}",
        const Duration(seconds: 2),
      );
      return;
    }
    if (widget.urlController.text.isEmpty) {
      ToastMessage.show(
        context,
        "${AppLocalizations.of(context).notAvailable} URL",
        const Duration(seconds: 2),
      );
      return;
    }

    if (widget.nameController.text.isNotEmpty &&
        widget.urlController.text.isNotEmpty) {
      widget.onAdd(
        StreamChannel(
          name: widget.nameController.text,
          url: widget.urlController.text,
        ),
      );
    }
  }

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int selectedIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            _selected == selectedIndex
                ? Colors.white.withAlphaF(0.2)
                : Colors.white.withAlphaF(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              _selected == selectedIndex
                  ? const Color(0xF04285F4)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        width: 280,
        height: 45,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onTap: () {
            setState(() {
            _selected = selectedIndex;
            });
          },
          style: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required FocusNode focusNode,
    required int selectedIndex,
  }) {
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selected = selectedIndex;
          });
          onPressed();
        },
        child: SizedBox(
          width: 280,
          height: 45,
          child: AnimatedScale(
            scale: _selected == selectedIndex ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                    _selected == selectedIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        _selected == selectedIndex
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context).addChannel}",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 120, 100, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 10,
                  children: [
                    _buildInputField(
                      hintText:
                          "${AppLocalizations.of(context).channel} ${AppLocalizations.of(context).name}",
                      controller: widget.nameController,
                      focusNode: _nameFocusNode,
                      selectedIndex: 0,
                    ),
                    _buildInputField(
                      hintText: "URL",
                      controller: widget.urlController,
                      focusNode: _urlFocusNode,
                      selectedIndex: 1,
                    ),
                    _buildButton(
                      text: AppLocalizations.of(context).ok,
                      onPressed: _handleAdd,
                      focusNode: _okFocusNode,
                      selectedIndex: 2,
                    ),
                    _buildButton(
                      text: "${AppLocalizations.of(context).recommended} ${AppLocalizations.of(context).channel}",
                      onPressed: _handleShowRecommend,
                      focusNode: _recommendFocusNode,
                      selectedIndex: 3,
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
