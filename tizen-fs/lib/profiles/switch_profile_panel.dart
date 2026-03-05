import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/top_menu_avatar_item.dart';

class AccountPanel extends StatefulWidget {
  const AccountPanel({super.key});

  @override
  State<AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<AccountPanel> {
  bool _iconSelected = true;
  bool _buttonSelected = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withAlphaF(0.8),
        child: FocusScope(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.arrowRight) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            } else if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              // AppRouter.router.push(ScreenPasths.profile);
              return KeyEventResult.ignored;
            } else if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_iconSelected) {
                setState(() {
                  _iconSelected = false;
                  _buttonSelected = true;
                });
              }
              return KeyEventResult.handled;
            } else if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (_buttonSelected) {
                setState(() {
                  _iconSelected = true;
                  _buttonSelected = false;
                });
              }
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(59, 35, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopMenuAvatarItem(
                      imageUrl: null,
                      text: 'T',
                      isSelected: _iconSelected,
                      onPressed: () {},
                    ),
                    SizedBox(height: 15),
                    Text('Tizen', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(52, 0, 0, 0),
              //   child: TextButton (
              //     onPressed: () { AppRouter.router.push(ScreenPaths.profile); },
              //     style: TextButton.styleFrom(
              //       backgroundColor: _buttonSelected ? Colors.white : Colors.transparent,
              //       foregroundColor: _buttonSelected ? Colors.black : Colors.white,
              //       animationDuration: const Duration(milliseconds: 100),
              //     ),
              //     child: const Text(
              //       'Switch profiles',
              //       style: TextStyle(
              //         fontSize: 12,
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
