import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class SimpleListView extends StatefulWidget {
  const SimpleListView({
    super.key,
    required this.items,
    this.selected = 0,
    this.onItemFocused,
    this.onItemSelected,
    this.onItemTapped,
    required this.itemBuilder,
  });

  final List<Object> items;
  final int selected;
  final Function(int)? onItemFocused;
  final Function(int)? onItemSelected;
  final Function(int)? onItemTapped;
  final Widget Function(BuildContext, int index, bool isFocused) itemBuilder;

  @override
  State<SimpleListView> createState() => SimpleListViewState();
}

class SimpleListViewState extends State<SimpleListView>
    with FocusSelectable<SimpleListView> {
  final double titleFontSize = 15;
  final double itemHeight = 65;
  int _selected = 0;

  @override
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowDown;
  }

  @override
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowUp;
  }

  void updateIndex(int value) {
    _selected = value;
  }

  void initFocus() {
    focusNode.requestFocus();
  }

  void selectTo(int index) {
    listKey.currentState?.selectTo(index);
  }

  void jumpTo(int index) {
    listKey.currentState?.jumpTo(index, itemHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != widget.selected) {
      _selected = widget.selected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        jumpTo(_selected);
      });
    }

    return Focus(
      focusNode: focusNode,
      child: SelectableListView(
        scrollOffset: 260,
        key: listKey,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        itemCount: widget.items.length,
        scrollDirection: Axis.vertical,
        onItemFocused: (focused) {
          widget.onItemFocused?.call(focused);
        },
        onItemSelected: (selected) {
          widget.onItemSelected?.call(selected);
        },
        itemBuilder: (context, index, focused, key) {
          final isFocused = Focus.of(context).hasFocus && index == focused;
          return AnimatedScale(
            key: key,
            scale: isFocused ? 1.0 : .9,
            duration: $style.times.med,
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    isFocused
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.transparent,
              ),
              child: widget.itemBuilder(context, index, isFocused),
            ),
          );
        },
      ),
    );
  }
}
