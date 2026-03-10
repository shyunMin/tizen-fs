import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/extensions.dart';

class CategorySelectableListView extends StatefulWidget {
  const CategorySelectableListView({
    super.key,
    this.padding,
    this.onAction,
    this.alignment,
    this.scrollDirection,
    this.scrollOffset = 300,
    required this.items,
  });

  final EdgeInsets? padding;
  final double? alignment;
  final Axis? scrollDirection;
  final Function(int)? onAction;
  final double scrollOffset;
  final List<Item> items;

  @override
  State<CategorySelectableListView> createState() =>
      CategorySelectableListViewState();
}

class CategorySelectableListViewState
    extends State<CategorySelectableListView> {
  late final ScrollController _controller;
  late List<GlobalKey> _itemKeys;

  int _selectedIndex = 0;
  Axis _scrollDirection = Axis.horizontal;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();

    if (widget.scrollDirection != null) {
      _scrollDirection = widget.scrollDirection!;
    }

    _itemKeys = List.generate(widget.items.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int index) {
    final int previousIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });
    _scrollToSelected(_selectedIndex, previousIndex);
  }

  Future<int> _scrollToSelected(int duration, int fallbackSelection) async {
    if (_itemKeys[_selectedIndex].currentContext != null) {
      int current = _selectedIndex;
      final RenderBox box =
          _itemKeys[_selectedIndex].currentContext!.findRenderObject()
              as RenderBox;
      final Offset position = box.localToGlobal(Offset.zero);
      if (position.dy.isNaN) return _selectedIndex;

      setState(() {});
      final double offset = widget.scrollOffset;
      await _controller.animateTo(
        position.dy + _controller.offset - offset,
        duration: $style.times.med,
        curve: Curves.easeInOut,
      );
      return current;
    } else {
      _selectedIndex = fallbackSelection; // restore previous selection
      return fallbackSelection;
    }
  }

  void onAction(int index) {
    widget.onAction?.call(index);
  }

  void forceScrollTo(int index) {
    _controller.jumpTo((index - 3) * 65);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await selectTo(index);
    });
  }

  Future<int> selectTo(int index) {
    if (index < 0 || index >= widget.items.length) {
      throw RangeError('Index out of range: $index');
    }

    if (widget.items[index].isKey) {
      index++;
    }
    final int previousIndex = _selectedIndex;
    _selectedIndex = index;
    return _scrollToSelected(100, previousIndex);
  }

  Future<int> next({bool fast = false}) async {
    int end = widget.items.length - 1;
    if (widget.items[end].isKey) {
      end--;
    }
    if (_selectedIndex < end) {
      int previousIndex = _selectedIndex;
      _selectedIndex++;
      if (widget.items[_selectedIndex].isKey) {
        previousIndex = _selectedIndex;
        _selectedIndex++;
      }

      return await _scrollToSelected(fast ? 10 : 100, previousIndex);
    } else {
      return _selectedIndex;
    }
  }

  Future<int> previous({bool fast = false}) async {
    int start = 0;
    if (widget.items[start].isKey) {
      start++;
    }
    if (_selectedIndex > start) {
      int previousIndex = _selectedIndex;
      _selectedIndex--;
      if (widget.items[_selectedIndex].isKey) {
        previousIndex = _selectedIndex;
        _selectedIndex--;
      }

      return await _scrollToSelected(fast ? 10 : 100, previousIndex);
    } else {
      return _selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(
        scrollbars: false,
        overscroll: false,
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      child: ListView.builder(
        padding: widget.padding,
        scrollDirection: _scrollDirection,
        controller: _controller,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          if (item.isKey) {
            return Transform.scale(
              scale: .9,
              child: CategoryListHeader(item: (item.item as List)),
            );
          } else {
            return AnimatedScale(
              key: _itemKeys[index],
              scale:
                  Focus.of(context).hasFocus && index == selectedIndex
                      ? 1.0
                      : .9,
              duration: $style.times.slow,
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  // listKey.currentState?.selectTo(index);
                  selectTo(index);
                  Focus.of(context).requestFocus();
                  onAction(index);
                },
                child: CategoryListItem(
                  item: (item.item as List),
                  icon: item.icon,
                  footer: item.footer,
                  isFocused:
                      Focus.of(context).hasFocus && index == selectedIndex,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CategoryListHeader extends StatelessWidget {
  const CategoryListHeader({super.key, required this.item});

  final List<dynamic> item;

  final double titleFontSize = 12;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    final key = item.elementAtOrNull(0);
    final value = item.elementAtOrNull(1);

    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        child: Padding(
          padding: // left padding of item inside
              EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15, //innerPadding * 0.75, // between icon-text spacing
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    key.toString(),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: Color(0xFF979AA0),
                    ),
                  ),
                  if (value.toString().isNotEmpty)
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Color(0xFF979AA0),
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

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.item,
    this.icon,
    this.footer,
    required this.isFocused,
  });

  final List<dynamic> item;
  final Widget? icon;
  final Widget? footer;
  final bool isFocused;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    final key = item.elementAtOrNull(0);
    final value = item.elementAtOrNull(1);

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
          padding: // left padding of item inside
              EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15, //innerPadding * 0.75, // between icon-text spacing
            children: [
              if (icon != null) icon!,
              // item text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    key.toString(),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color:
                          isFocused
                              ? Theme.of(context).colorScheme.onTertiary
                              : Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  if (value is int)
                    Text(
                      // StringUtils.toSizeString(value),
                      value.toSizeString(),
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Color(0xFF979AA0),
                      ),
                    ),
                ],
              ),
              if (footer != null) Spacer(),
              if (footer != null) footer!,
            ],
          ),
        ),
      ),
    );
  }
}
