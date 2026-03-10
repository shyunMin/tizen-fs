import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class WifiAdvancedListView extends StatefulWidget {
  const WifiAdvancedListView({
    super.key,
    required this.isEnabled,
    this.onFocusChanged,
    this.onSelectionChanged,
  });

  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;

  @override
  State<WifiAdvancedListView> createState() => WifiAdvancedListViewState();
}

class WifiAdvancedListViewState extends State<WifiAdvancedListView>
    with FocusSelectable<WifiAdvancedListView> {
  int _selected = 0;

  @override
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowDown;
  }

  @override
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowUp;
  }

  void initFocus() {
    focusNode.requestFocus();
  }

  void selectTo(int index) {
    listKey.currentState?.selectTo(index);
  }

  void _selectChanged() {
    widget.onSelectionChanged?.call(_selected);
  }

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (_selected == 0) {
          _selectChanged();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleFocusChanged() {
    debugPrint("_handleFocusChanged [${_selected}]");
    if (!mounted) return;
    widget.onFocusChanged?.call(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = 1;
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasfocus) {
        if (hasfocus) {
          listKey.currentState?.selectTo(_selected);
        } else {
          _selected = listKey.currentState?.selectedIndex ?? 0;
        }
      },
      child: SelectableListView(
        scrollOffset: 260,
        key: listKey,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        itemCount: itemCount,
        scrollDirection: Axis.vertical,
        onItemFocused: (selected) {
          _selected = selected;
          _handleFocusChanged();
        },
        itemBuilder: (context, index, selectedIndex, key) {
          return AnimatedScale(
            key: key,
            scale:
                Focus.of(context).hasFocus && index == selectedIndex ? 1.0 : .9,
            duration: $style.times.med,
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                listKey.currentState?.selectTo(index);
                Focus.of(context).requestFocus();
                if (index == 0) {
                  _selectChanged();
                }
              },
              child: WifiAdvancedMenuItem(
                isFocused: Focus.of(context).hasFocus && index == selectedIndex,
                isEnabled: widget.isEnabled,
                title: AppLocalizations.of(context).findHiddenNetwork,
              ),
            ),
          );
        },
      ),
    );
  }
}

class WifiAdvancedMenuItem extends StatelessWidget {
  const WifiAdvancedMenuItem({
    super.key,
    required this.isFocused,
    required this.isEnabled,
    required this.title,
  });

  final bool isFocused;
  final bool isEnabled;
  final String title;

  final double titleFontSize = 15;
  final double innerPadding = 20;
  final double itemHeight = 65;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isFocused
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color:
                            isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
