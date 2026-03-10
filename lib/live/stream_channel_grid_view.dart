import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/live/stream_channel.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/media_card.dart';

class StreamChannelGridView extends StatefulWidget {
  const StreamChannelGridView({
    super.key,
    required this.items,
    this.onItemSelected,
  });

  final List<StreamChannel> items;
  final Function(int)? onItemSelected;

  @override
  State<StreamChannelGridView> createState() => _StreamChannelGridViewState();
}

class _StreamChannelGridViewState extends State<StreamChannelGridView> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late List<GlobalKey> _itemKeys;
  int _selectedIndex = -1;
  int _lastSelected = -1;
  bool hasFocused = false;

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
    _updateItemCount();
  }

  @override
  void didUpdateWidget(StreamChannelGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateItemCount();
  }

  void _updateItemCount() {
    final newItemCount = widget.items.length + 1;
    if (newItemCount != _itemCount) {
      setState(() {
        _itemCount = newItemCount;
        _itemKeys = List.generate(_itemCount, (index) => GlobalKey());
      });
    }
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
          StreamChannel item;

          if (index == 0) {
            item = StreamChannel(
              name: AppLocalizations.of(context).addChannel,
              url: '',
            );
          } else {
            final channelIndex = index - 1;
            item = widget.items[channelIndex];
          }

          return SizedBox(
            key: _itemKeys[index],
            width: (_width < _itemWidth) ? _width : _itemWidth,
            child: Center(
              child: MediaCard(
                ratio: MediaCardRatio.wide,
                width: (_width < _itemWidth) ? _width : _itemWidth,
                imageUrl: '',
                content: _createContent(context, item),
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

  Widget _createContent(BuildContext context, StreamChannel item) {
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            item.logo.isEmpty
            ? Icon(
              item.url.isEmpty ? Icons.add_outlined : Icons.tv_outlined,
              size: 30,
            )
            : CachedNetworkImage(
              imageUrl: item.logo,
              width: 30,
              height: 30,
              placeholder: (context, url) => Icon(
                Icons.tv_outlined,
                size: 30,
                color: Colors.white54,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.tv_outlined,
                size: 30,
                color: Colors.white54,
              ),
            ),
            if (item.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
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
    hasFocused = hasFocus;
    if (hasFocus) {
      setState(() {
        _selectedIndex = _lastSelected != -1 ? _lastSelected : 0;
      });
    } else {
      _lastSelected = _selectedIndex;
      setState(() {
        _selectedIndex = -1;
      });
    }
  }
}
