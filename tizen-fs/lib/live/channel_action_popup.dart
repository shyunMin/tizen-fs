import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/live/stream_channel.dart';
import 'package:tizen_fs/live/channel_add_popup.dart';

class ChannelActionPopup extends StatefulWidget {
  const ChannelActionPopup({
    required this.channel,
    required this.onPlay,
    required this.onDelete,
    required this.onEdit,
  });

  final StreamChannel channel;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final Function(StreamChannel) onEdit;

  @override
  State<ChannelActionPopup> createState() => _ChannelActionPopupState();
}

class _ChannelActionPopupState extends State<ChannelActionPopup> {
  final FocusNode _playFocusNode = FocusNode();
  final FocusNode _editFocusNode = FocusNode();
  final FocusNode _deleteFocusNode = FocusNode();
  int _selected = 0;

  @override
  void dispose() {
    _playFocusNode.dispose();
    _editFocusNode.dispose();
    _deleteFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1) % 3;
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1 + 3) % 3;
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
    if (_selected == 0) {
      _handlePlay();
    } else if (_selected == 1) {
      _handleEdit();
    } else {
      _handleDelete();
    }
  }

  void _updateFocus() {
    if (_selected == 0) {
      _playFocusNode.requestFocus();
    } else if (_selected == 1) {
      _editFocusNode.requestFocus();
    } else {
      _deleteFocusNode.requestFocus();
    }
  }

  void _handlePlay() {
    Navigator.of(context).pop();
    widget.onPlay();
  }

  void _handleEdit() {
    Navigator.of(context).pop();
    _showEditPopup();
  }

  void _handleDelete() {
    Navigator.of(context).pop();
    widget.onDelete();
  }

  void _showEditPopup() {
    final nameController = TextEditingController(text: widget.channel.name);
    final urlController = TextEditingController(text: widget.channel.url);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ChannelAddPopup(
          nameController: nameController,
          urlController: urlController,
          onAdd: (updatedChannel) {
            Navigator.of(context).pop();
            widget.onEdit(updatedChannel);
          },
        );
      },
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required FocusNode focusNode,
    required int selectedIndex,
    required IconData icon,
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
                      "${AppLocalizations.of(context).channel}",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.channel.name}",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${widget.channel.url}",
                      style: const TextStyle(fontSize: 13, color: Colors.white),
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
                    _buildButton(
                      text: AppLocalizations.of(context).play,
                      onPressed: _handlePlay,
                      focusNode: _playFocusNode,
                      selectedIndex: 0,
                      icon: Icons.play_arrow,
                    ),
                    _buildButton(
                      text: AppLocalizations.of(context).edit,
                      onPressed: _handleEdit,
                      focusNode: _editFocusNode,
                      selectedIndex: 1,
                      icon: Icons.edit,
                    ),
                    _buildButton(
                      text: AppLocalizations.of(context).delete,
                      onPressed: _handleDelete,
                      focusNode: _deleteFocusNode,
                      selectedIndex: 2,
                      icon: Icons.delete,
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
