import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectableGridView extends StatefulWidget {
  const SelectableGridView({
    super.key,
    required this.scrollController,
    required this.itemCount,
    required this.itemRatio,
    required this.itemBuilder,
    this.initialOffset,
    this.padding,
    this.onFocused,
    this.onUnfocused,
    this.onItemSelected,
    this.onItemLongPressed,
  });

  final int itemCount;
  final double itemRatio;
  final Widget Function(BuildContext, int index, int selectedIndex, Key key)
  itemBuilder;
  final double? initialOffset;
  final EdgeInsets? padding;
  final VoidCallback? onFocused;
  final VoidCallback? onUnfocused;
  final Function(int)? onItemSelected;
  final Function(int)? onItemLongPressed;
  final ScrollController scrollController;

  @override
  State<SelectableGridView> createState() => SelectableGridViewState();
}

class SelectableGridViewState extends State<SelectableGridView> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _gridKey = GlobalKey();
  late List<GlobalKey> _itemKeys;

  DateTime? _pressedAt;
  final Duration longPressThreshold = const Duration(milliseconds: 600);

  int _selectedIndex = 0;

  final double _width = 960;
  int get columnCount => (_width < 152) ? 1 : (_width - 116) ~/ 162;

  @override
  void initState() {
    super.initState();

    _itemKeys = List.generate(widget.itemCount, (indext) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant SelectableGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemKeys = List.generate(widget.itemCount, (indext) => GlobalKey());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      setState(() {});
    }
  }

  void selectTo(int index) async {
    if (index >= 0 && index < widget.itemCount) {
      int current = await scrollToSelected(index);
      setState(() {
        if (_selectedIndex != current) _selectedIndex = current;
      });
    }
  }

  Future<int> scrollToSelected(var index) async {
    final context = _itemKeys[index].currentContext;
    if (context != null) {
      final row = index ~/ columnCount;
      final offset = ((widget.initialOffset ?? 0) + (120 * row)).toDouble();

      widget.scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );

      return index;
    } else {
      return _selectedIndex;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      int col = _selectedIndex % columnCount;

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_selectedIndex - columnCount >= 0) {
          selectTo(_selectedIndex - columnCount);
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_selectedIndex + columnCount < widget.itemCount) {
          selectTo(_selectedIndex + columnCount);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (col < columnCount - 1 && _selectedIndex + 1 < widget.itemCount) {
          selectTo(_selectedIndex + 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.tab) {
        selectTo(_selectedIndex + 1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (col > 0) {
          selectTo(_selectedIndex - 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _pressedAt = DateTime.now();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (_pressedAt == null) return KeyEventResult.handled;

        final duration = DateTime.now().difference(_pressedAt!);
        if (duration >= longPressThreshold) {
          //longpress
          widget.onItemLongPressed?.call(_selectedIndex);
        } else {
          widget.onItemSelected?.call(_selectedIndex);
        }
        _pressedAt = null;
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _onFocusChanged(bool hasFocus) {
    if (hasFocus) {
      widget.onFocused?.call();
    } else {
      widget.onUnfocused?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      onFocusChange: _onFocusChanged,
      child: GridView.builder(
        key: _gridKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: widget.padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: 15,
          mainAxisSpacing: 30,
          childAspectRatio: widget.itemRatio,
        ),
        itemBuilder: (context, index) {
          return widget.itemBuilder(
            context,
            index,
            _selectedIndex,
            _itemKeys[index],
          );
        },
        itemCount: widget.itemCount,
      ),
    );
  }
}
