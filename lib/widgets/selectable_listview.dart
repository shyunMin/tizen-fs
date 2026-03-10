import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tizen_fs/styles/app_style.dart';

class SelectableListView extends StatefulWidget {
  const SelectableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.onItemFocused,
    this.onItemSelected,
    this.alignment,
    this.scrollDirection,
    this.scrollOffset = 300,
    this.spacing = 0,
  });

  final int itemCount;
  final Widget Function(BuildContext, int index, int selectedIndex, Key key)
  itemBuilder;
  final EdgeInsets? padding;
  final double spacing;
  final double? alignment;
  final Axis? scrollDirection;
  final Function(int)? onItemFocused;
  final Function(int)? onItemSelected;
  final double scrollOffset;

  @override
  State<SelectableListView> createState() => SelectableListViewState();
}

class SelectableListViewState extends State<SelectableListView> {
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

    _itemKeys = List.generate(widget.itemCount, (index) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant SelectableListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _itemKeys = List.generate(widget.itemCount, (index) => GlobalKey());
    }
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

  int get itemCount => widget.itemCount;

  Future<int> _scrollToSelected(int duration, int fallbackSelection) async {
    if (_itemKeys[_selectedIndex].currentContext != null) {
      int current = _selectedIndex;
      final RenderBox box =
          _itemKeys[_selectedIndex].currentContext!.findRenderObject()
              as RenderBox;
      final Offset position = box.localToGlobal(Offset.zero);

      if (_scrollDirection == Axis.vertical) {
        if (position.dy.isNaN) return _selectedIndex;

        setState(() {});
        final double offset = widget.scrollOffset;

        widget.onItemFocused?.call(_selectedIndex);

        await _controller.animateTo(
          position.dy + _controller.offset - offset,
          duration: $style.times.med,
          curve: Curves.easeInOut,
        );
        return current;
      } else {
        if (position.dx.isNaN) return _selectedIndex;

        setState(() {});
        final double offset = widget.scrollOffset;

        widget.onItemFocused?.call(_selectedIndex);

        await _controller.animateTo(
          position.dx + _controller.offset - offset,
          duration: $style.times.med,
          curve: Curves.easeInOut,
        );
        return current;
      }
    } else {
      _selectedIndex = fallbackSelection; // restore previous selection
      return fallbackSelection;
    }
  }

  Future<int> selectTo(int index) {
    if (index < 0 || index >= widget.itemCount) {
      throw RangeError('Index out of range: $index');
    }
    final int previousIndex = _selectedIndex;
    _selectedIndex = index;
    return _scrollToSelected(100, previousIndex);
  }

  Future<int> next({bool fast = false}) async {
    if (_selectedIndex < widget.itemCount - 1) {
      final int previousIndex = _selectedIndex;
      _selectedIndex++;
      return await _scrollToSelected(fast ? 10 : 100, previousIndex);
    } else {
      return _selectedIndex;
    }
  }

  Future<int> previous({bool fast = false}) async {
    if (_selectedIndex > 0) {
      final int previousIndex = _selectedIndex;
      _selectedIndex--;
      return await _scrollToSelected(fast ? 10 : 100, previousIndex);
    } else {
      return _selectedIndex;
    }
  }

  Future<void> scrollToIndex(int index) async {
    if (index < 0 || index >= widget.itemCount) {
      throw RangeError('Index out of range: $index');
    }

    if (_itemKeys[index].currentContext != null) {
      final RenderBox box =
          _itemKeys[index].currentContext!.findRenderObject() as RenderBox;
      final Offset position = box.localToGlobal(Offset.zero);

      if (!position.dy.isNaN) {
        final double offset = widget.scrollOffset;

        await _controller.animateTo(
          position.dy + _controller.offset - offset,
          duration: $style.times.med,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void callItemSelected() {
    widget.onItemSelected?.call(_selectedIndex);
  }

  double _getScrollOffset(int index, double itemSize) {
    final box = context.findRenderObject() as RenderBox;
    double startOffset = 0;
    double spacing = ((index - 1) * widget.spacing);

    if (_scrollDirection == Axis.vertical) {
      final dy = box.localToGlobal(Offset.zero).dy;
      final padding = widget.padding?.bottom ?? 0;
      startOffset = dy + padding;
    } else {
      final dx = box.localToGlobal(Offset.zero).dx;
      final padding = widget.padding?.left ?? 0;
      startOffset = dx + padding;
    }

    final offset =
        startOffset + (index * itemSize) + spacing - widget.scrollOffset;

    final maxScrollExtend = _controller.position.maxScrollExtent;
    double safeOffset = offset.clamp(0, maxScrollExtend);

    return safeOffset;
  }

  void jumpTo(int index, double itemSize) {
    final offset = _getScrollOffset(index, itemSize);
    _controller.jumpTo(offset);
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> jumpToIndex(int index, double itemHeight) async {
    if (index < 0 || index >= widget.itemCount) {
      throw RangeError('Index out of range: $index');
    }
    if (_itemKeys[index].currentContext != null) {
      await selectTo(index);
    } else {
      double offset = ((index - 3) * itemHeight) - widget.scrollOffset;
      final maxScrollExtend = _controller.position.maxScrollExtent;
      double safeOffset = offset.clamp(0, maxScrollExtend);
      _controller.jumpTo(safeOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await selectTo(index);
      });
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
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: widget.padding,
        scrollDirection: _scrollDirection,
        // clipBehavior: Clip.none,
        controller: _controller,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return widget.itemBuilder(
            context,
            index,
            _selectedIndex,
            _itemKeys[index],
          );
        },
        separatorBuilder:
            (BuildContext context, int index) =>
                _scrollDirection == Axis.horizontal
                    ? SizedBox(width: widget.spacing)
                    : SizedBox(height: widget.spacing),
      ),
    );
  }
}
