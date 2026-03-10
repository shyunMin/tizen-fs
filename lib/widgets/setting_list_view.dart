import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/item_view.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class SettingListView extends StatefulWidget {
  const SettingListView({
    super.key,
    required this.node,
    this.onItemFocused,
    this.onItemSelected,
    this.onItemTapped,
  });

  final PageNode node;
  final Function(int)? onItemFocused;
  final Function(int)? onItemSelected;
  final Function(int)? onItemTapped;

  @override
  State<SettingListView> createState() => SettingListViewState();
}

class SettingListViewState extends State<SettingListView>
    with FocusSelectable<SettingListView> {
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

  Widget build(BuildContext context) {
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
        //between item and item
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        itemCount: widget.node.children.length,
        scrollDirection: Axis.vertical,
        onItemFocused: (focused) {
          widget.onItemFocused?.call(focused);
        },
        onItemSelected: (selected) {
          widget.onItemSelected?.call(selected);
        },
        itemBuilder: (context, index, selectedIndex, key) {
          return AnimatedScale(
            key: key,
            scale:
                Focus.of(context).hasFocus && index == selectedIndex ? 1.0 : .9,
            duration: $style.times.med,
            curve: Curves.easeInOut,
            child: ItemView<PageNode>(
              item: widget.node.children[index],
              isFocused: Focus.of(context).hasFocus && index == selectedIndex,
              onTap: () {
                widget.onItemTapped?.call(index);
                listKey.currentState?.selectedIndex = index;
              },
            ),
          );
        },
      ),
    );
  }
}
