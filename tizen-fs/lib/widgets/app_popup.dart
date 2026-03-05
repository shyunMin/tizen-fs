import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_fs/widgets/app_tile.dart';

class AppPopup extends StatefulWidget {
  const AppPopup({
    super.key,
    required this.app,
    required this.message,
    required this.onConfirm,
  });

  final AppData app;
  final String message;
  final VoidCallback? onConfirm;
  @override
  State<AppPopup> createState() => _AppPopupState();
}

class _AppPopupState extends State<AppPopup> {
  int _selected = 0;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 1);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 1);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selected == 0) {
          widget.onConfirm?.call();
        }
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
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
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(150, 100, 0, 10),
                  child: Text(
                    // AppLocalizations.of(context).clearCacheMessage,
                    widget.message,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(150, 10, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 152 * 1.3,
                          height: 86 * 1.3,
                          child: AppTile(app: widget.app),
                        ),
                        Text(widget.app.name),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 100, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 20,
                        children: [
                          PopupButton(
                            text: AppLocalizations.of(context).ok,
                            isSelected: _selected == 0,
                            onPressed: () {
                              _select(0);
                              widget.onConfirm?.call();
                              Navigator.of(context).pop();
                            },
                          ),
                          PopupButton(
                            text: AppLocalizations.of(context).cancel,
                            isSelected: _selected == 1,
                            onPressed: () {
                              _select(1);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    this.width = 250,
    this.height = 50,
  });

  final bool isSelected;
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
    );
  }
}
