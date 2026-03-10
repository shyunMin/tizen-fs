import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/item_view.dart';

import 'package:tizen_fs/widgets/selectable_listview.dart';

class ItemsView<T extends ItemDisplayInterface> extends StatefulWidget {
  const ItemsView({
    super.key,
    required this.items,
    this.onAction,
    this.onItemFocused,
    this.onItemSelected,
    this.onListChanged,
  });

  final List<T> items;
  final Function(int)? onAction;
  final Function(int)? onItemFocused;
  final Function(int)? onItemSelected;
  final VoidCallback? onListChanged;

  @override
  State<ItemsView> createState() => ItemsViewState<T>();
}

class ItemsViewState<T extends ItemDisplayInterface> extends State<ItemsView>
    with FocusSelectable<ItemsView> {
  int _selected = 0;
  bool _isInitialLoad = true;

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
    _selected = index;
    _scrollToItem(index);
    listKey.currentState?.selectTo(index);
  }

  /// Scroll to ensure the item at the given index is visible
  void _scrollToItem(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listKey.currentState?.scrollToIndex(index);
    });
  }

  @override
  void didUpdateWidget(covariant ItemsView oldWidget) {
    if (_isInitialLoad) {
      if (widget.items.isNotEmpty) {
        _isInitialLoad = false;
      }
      return;
    }

    if (oldWidget.items.length != widget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // listKey.currentState?.selectTo(0);
        widget.onListChanged?.call();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final nextIndex = _findNextSelectableIndex(_selected, 1);
        if (nextIndex != _selected) {
          _selected = nextIndex;
          _scrollToItem(nextIndex);
          listKey.currentState?.selectTo(nextIndex);
          // Note: onItemFocused is already called by SelectableListView.selectTo()
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final nextIndex = _findNextSelectableIndex(_selected, -1);
        if (nextIndex != _selected) {
          _selected = nextIndex;
          _scrollToItem(nextIndex);
          listKey.currentState?.selectTo(nextIndex);
          // Note: onItemFocused is already called by SelectableListView.selectTo()
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        final selectedIndex = _selected;
        final selectedItem = widget.items[selectedIndex];
        if (selectedItem.isSelectable) {
          widget.onAction?.call(selectedIndex);
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Find the next selectable index in the specified direction
  /// Stops at boundaries (does not wrap around)
  /// Returns the current index if at boundary or no selectable items found
  int _findNextSelectableIndex(int currentIndex, int direction) {
    if (widget.items.isEmpty) {
      return 0;
    }

    int index = currentIndex;

    // Search in the specified direction
    while (true) {
      index += direction;

      // Check if we've reached the boundary
      if (index >= widget.items.length || index < 0) {
        return currentIndex; // Stop at boundary, return current index
      }

      // Check if this item is selectable
      if (widget.items[index].isSelectable) {
        return index;
      }
    }
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
        itemCount: widget.items.length,
        scrollOffset: 260,
        key: listKey,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        scrollDirection: Axis.vertical,
        onItemFocused: widget.onItemFocused,
        onItemSelected: widget.onItemSelected,
        itemBuilder: (context, index, selectedIndex, key) {
          final item = widget.items[index];
          final isItemSelectable = item.isSelectable;

          return AnimatedScale(
            key: key,
            scale:
                Focus.of(context).hasFocus &&
                        index == selectedIndex &&
                        isItemSelectable
                    ? 1.0
                    : .9,
            duration: $style.times.med,
            curve: Curves.easeInOut,
            child: ChangeNotifierProvider<ChangeNotifier>.value(
              value: widget.items[index] as ChangeNotifier,
              child: Consumer<ChangeNotifier>(
                builder: (context, item, child) {
                  return ItemView<ItemDisplayInterface>(
                    item: widget.items[index],
                    isFocused:
                        Focus.of(context).hasFocus &&
                        index == selectedIndex &&
                        isItemSelectable,
                    onTap: () {
                      if (isItemSelectable) {
                        _selected = index;
                        listKey.currentState?.selectedIndex = index;
                        widget.onItemSelected?.call(index);
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
