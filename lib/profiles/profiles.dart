import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/profiles/profile_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final int _itemCount = 2;
  int _selected = 0;
  int _lastSelected = -1;

  void _select(int index) {
    if (_selected != index) {
      setState(() {
        _selected = index;
      });
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _select((_selected > 0) ? (_selected - 1) : _selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _select((_selected < _itemCount - 1) ? (_selected + 1) : _selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _lastSelected = _lastSelected == -1 ? _selected : _lastSelected;
        setState(() {
          _selected = 2;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_lastSelected != -1) ? _lastSelected : _selected;
          _lastSelected = -1;
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        // if(_selected == 1) {
        //   _showFullScreenPopup(context);
        // }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _showFullScreenPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateProfilePopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tizen OS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withAlphaF(0.7),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Select a profile to sign in',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 30,
                  children: [
                    CircleItem(
                      icon: null,
                      text: 'Tizen',
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      unselectedColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlphaF(0.7),
                      isSelected: 0 == _selected,
                      onPressed: () {
                        _select(0);
                      },
                    ),
                    AddProfileCircleItem(
                      isSelected: 1 == _selected,
                      onPressed: () {
                        _select(1);
                        _showFullScreenPopup(context);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: FocusedButton(isSelected: 2 == _selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusedButton extends StatelessWidget {
  const FocusedButton({super.key, this.isSelected = false});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onTertiary,
        foregroundColor:
            isSelected
                ? Theme.of(context).colorScheme.onTertiary
                : Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {},
      child: Text('Manage app profile'),
    );
  }
}

class AddProfileCircleItem extends StatelessWidget {
  const AddProfileCircleItem({
    super.key,
    this.isSelected = false,
    this.onPressed,
  });

  final void Function()? onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: Column(
        spacing: 10,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onTertiary,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withAlphaF(0.7)
                        : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.person_add_alt,
                size: 35,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onTertiary
                        : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Text('+ Add profile', style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class CircleItem extends StatelessWidget {
  const CircleItem({
    super.key,
    this.icon,
    this.isSelected = false,
    this.text,
    this.selectedColor,
    this.unselectedColor,
    this.onPressed,
  });
  final bool isSelected;
  final Icon? icon;
  final String? text;
  final void Function()? onPressed;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: Column(
        spacing: 10,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : unselectedColor,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withAlphaF(0.7)
                        : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child:
                  (icon == null)
                      ? Text(
                        text!.substring(0, 1),
                        style: TextStyle(fontSize: 35),
                      )
                      : icon,
            ),
          ),
          Text(text!, style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
