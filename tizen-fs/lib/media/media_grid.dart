import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/media_card.dart';

class MediaGridView<T extends MediaContentInfo> extends StatefulWidget {
  const MediaGridView({super.key, required this.items, this.onItemSelected});

  final List<MediaContentInfo> items;
  final Function(int)? onItemSelected;

  @override
  State<MediaGridView> createState() => _MediaGridViewState();
}

class _MediaGridViewState extends State<MediaGridView> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late List<GlobalKey> _itemKeys;
  int _selectedIndex = 0;
  int _lastSelected = -1;

  double _width = 960;
  set width(double value) {
    _width = value;
  }

  int _itemCount = 30;
  final _hpadding = 58.0;
  final _itemWidth = 150.0;
  final _spacing = 10.0;
  final _itemRatio = 16 / 11.0;

  int get columnCount {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth < _itemWidth)
        ? 1
        : (screenWidth - (_hpadding * 2)) ~/ (_itemWidth + _spacing);
  }

  @override
  void initState() {
    super.initState();

    _itemCount = widget.items.length;
    _itemKeys = List.generate(_itemCount, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      onFocusChange: _onFocusChanged,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 58, vertical: 30),
        physics: const ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          childAspectRatio: _itemRatio,
        ),
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          return SizedBox(
            key: _itemKeys[index],
            width: (_width < _itemWidth) ? _width : _itemWidth,
            child: Center(
              child: MediaCard(
                ratio: MediaCardRatio.wide,
                width: (_width < _itemWidth) ? _width : _itemWidth,
                imageUrl: widget.items[index].thumbnailPath,
                title: widget.items[index].name,
                content:
                    (widget.items[index].thumbnailPath.isEmpty)
                        ? _createIconContent(context, widget.items[index])
                        : null,
                isSelected: index == _selectedIndex,
                onRequestSelect: () {
                  _selectTo(index);
                  Future.microtask(() {
                    widget.onItemSelected?.call(index);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _createIconContent(BuildContext context, MediaContentInfo item) {
    IconData iconData;

    if (item.type == MediaType.image) {
      iconData = Icons.image_outlined;
    } else if (item.type == MediaType.video) {
      iconData = Icons.video_library_outlined;
    } else {
      iconData = Icons.file_copy_outlined;
    }

    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [Icon(iconData, size: 30)],
        ),
      ),
    );
  }

  void _selectTo(int index) async {
    if (index >= 0 && index < _itemCount) {
      int current = await _scrollToSelected(index);
      setState(() {
        if (_selectedIndex != current) _selectedIndex = current;
      });
    }
  }

  Future<int> _scrollToSelected(var index) async {
    final context = _itemKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 1,
        duration: $style.times.fast,
        curve: Curves.easeInOut,
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
          _selectTo(_selectedIndex - columnCount);
          return KeyEventResult.handled;
        } else {}
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_selectedIndex + columnCount < _itemCount) {
          _selectTo(_selectedIndex + columnCount);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (col < columnCount - 1 && _selectedIndex + 1 < _itemCount) {
          _selectTo(_selectedIndex + 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (col > 0) {
          _selectTo(_selectedIndex - 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.tab) {
        _selectTo(_selectedIndex + 1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        widget.onItemSelected?.call(_selectedIndex);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _onFocusChanged(bool hasFocus) {
    if (hasFocus) {
      if (_lastSelected != -1) {
        setState(() {
          _selectedIndex = _lastSelected;
        });
      }
    } else {
      _lastSelected = _selectedIndex;
      setState(() {
        _selectedIndex = -1;
      });
    }
  }
}
