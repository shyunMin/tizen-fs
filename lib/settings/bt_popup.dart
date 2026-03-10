import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/styles/app_style.dart';

class BtConnectingPopup extends StatefulWidget {
  const BtConnectingPopup({
    super.key,
    required this.device,
    this.onUnpair,
    this.onConnect,
    this.onDisConnect,
  });

  final BtDevice device;
  final VoidCallback? onUnpair;
  final VoidCallback? onConnect;
  final VoidCallback? onDisConnect;

  @override
  State<BtConnectingPopup> createState() => _BtConnectingPopupState();
}

class _BtConnectingPopupState extends State<BtConnectingPopup> {
  int _selected = 1;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(widget.device.isBonded ? 0 : 1, 2);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(widget.device.isBonded ? 0 : 1, 2);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selected == 0) {
          widget.onUnpair?.call();
        } else if (_selected == 1) {
          widget.device.isConnected
              ? widget.onDisConnect?.call()
              : widget.onConnect?.call();
        } else {
          Navigator.of(context).pop();
        }
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
                child: Container(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      Icon(Icons.bluetooth, size: 30, color: Color(0xF0AEB2B9)),
                      Container(
                        child: Text(
                          widget.device.remoteName,
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      Container(
                        child: Text(
                          widget.device.remoteAddress,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      if (widget.device.isBonded)
                        ItemView(
                          text: 'Unpair',
                          isSelected: _selected == 0,
                          onPressed: () {
                            _select(0);
                            widget.onUnpair?.call();
                          },
                        ),
                      ItemView(
                        text:
                            widget.device.isConnected
                                ? 'Disconnect'
                                : 'Connect',
                        isSelected: _selected == 1,
                        onPressed: () {
                          _select(1);
                          widget.device.isConnected
                              ? widget.onDisConnect?.call()
                              : widget.onConnect?.call();
                        },
                      ),
                      ItemView(
                        text: 'Close',
                        isSelected: _selected == 2,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  const ItemView({
    super.key,
    this.isSelected = false,
    required this.text,
    this.onPressed,
  });

  final bool isSelected;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 300,
        height: 60,
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1,
          duration: $style.times.fast,
          child: AnimatedOpacity(
            opacity: isSelected ? 1 : 0.6,
            duration: $style.times.fast,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
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
                            color: Theme.of(context).colorScheme.onTertiary,
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
