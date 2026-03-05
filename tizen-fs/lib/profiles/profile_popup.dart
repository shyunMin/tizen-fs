import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/styles/app_style.dart';

class CreateProfilePopup extends StatefulWidget {
  const CreateProfilePopup({super.key});

  @override
  State<CreateProfilePopup> createState() => _CreateProfilePopupState();
}

class _CreateProfilePopupState extends State<CreateProfilePopup> {
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
          decoration: BoxDecoration(
            gradient: $style.gradients.generateLinearGradient(
              Colors.black,
              Colors.blue.shade900,
            ),
          ),
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
                      Container(
                        child: Text('Tizen OS', style: TextStyle(fontSize: 15)),
                      ),
                      Container(
                        child: Text(
                          'Create new profile',
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Create a seperate viewing experience for\nkids, with parental controls and screen time\nlimits.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      Container(
                        child: Text(
                          'You can manage profiles in Settings ->\nApp Profiles',
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
                      ItemView(
                        text: 'Create new profile',
                        isSelected: _selected == 0,
                        onPressed: () => _select(0),
                      ),
                      ItemView(
                        text: 'Create new profile for kid',
                        isSelected: _selected == 1,
                        onPressed: () => _select(1),
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
