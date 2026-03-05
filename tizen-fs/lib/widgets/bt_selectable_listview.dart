import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/styles/app_style.dart';

class BtCategorySelectableListView extends StatefulWidget {
  const BtCategorySelectableListView({
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
  State<BtCategorySelectableListView> createState() =>
      BtCategorySelectableListViewState();
}

class BtCategorySelectableListViewState
    extends State<BtCategorySelectableListView> {
  late final ScrollController _controller;
  late List<GlobalKey> _itemKeys;

  int _selectedIndex = 0;
  Axis _scrollDirection = Axis.horizontal;

  int _itemCount = 0;
  int get itemCount => _itemCount;

  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();

    if (widget.scrollDirection != null) {
      _scrollDirection = widget.scrollDirection!;
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

  Future<int> _scrollToSelected(int duration, int fallbackSelection) async {
    debugPrint(
      '_scrollToSelected, fallbackSelection=$fallbackSelection, _selectedIndex=$_selectedIndex, _itemKeys[_selectedIndex].currentContext==null?${_itemKeys[_selectedIndex].currentContext == null}',
    );
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
    if (index < 0 || index >= itemCount) {
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

  String _getLocalizedTitle(BuildContext context, String rawTitle) {
    final l10n = AppLocalizations.of(context);
    switch (rawTitle) {
      case 'Your device in currentrly visible to nearby devices.':
        return l10n.yourDeviceIsVisible;
      case 'Paired Devices':
        return l10n.pairedDevices;
      case 'Available Devices':
        return l10n.availableDevices;
      case 'Bluetooth':
        return l10n.bluetooth;
      default:
        return rawTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    // widget.items = Provider.of<BtModel>(context).data;

    _itemCount = widget.items.length;

    _itemKeys = List.generate(widget.items.length, (index) => GlobalKey());
    _isEnabled = Provider.of<BtModel>(context).isEnabled;

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
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          if (item.isKey) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 30),
              child: Text(
                _getLocalizedTitle(context, item.item as String),
                key: _itemKeys[index],
                style: TextStyle(
                  fontSize: 10,
                  color: Color.fromARGB(117, 151, 154, 160),
                ),
              ),
            );
          } else if (index == 1) {
            return AnimatedScale(
              key: _itemKeys[index],
              scale:
                  Focus.of(context).hasFocus && index == selectedIndex
                      ? 1.0
                      : .9,
              duration: $style.times.med,
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  // listKey.currentState?.selectTo(index);
                  selectTo(index);
                  Focus.of(context).requestFocus();
                },
                child: DeviceListMenuItem(
                  name: _getLocalizedTitle(
                    context,
                    widget.items[index].item as String,
                  ),
                  isON: _isEnabled,
                  isFocused:
                      Focus.of(context).hasFocus && index == selectedIndex,
                  onStateChanged: (state) {
                    if (_isEnabled != state) {
                      onAction(index);
                    }
                  },
                ),
              ),
            );
          } else {
            return AnimatedScale(
              key: _itemKeys[index],
              scale:
                  Focus.of(context).hasFocus && index == selectedIndex
                      ? 1.0
                      : .9,
              duration: $style.times.med,
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  // listKey.currentState?.selectTo(index);
                  selectTo(index);
                  Focus.of(context).requestFocus();
                  onAction(index);
                },
                child: DeviceListItem(
                  item: widget.items[index].item as BtDevice,
                  iconData:
                      Icons
                          .bluetooth, // isPaired ? Icons.bluetooth_connected : Icons.bluetooth
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

class DeviceListMenuItem extends StatefulWidget {
  const DeviceListMenuItem({
    super.key,
    this.name = '',
    required this.isON,
    required this.isFocused,
    this.onStateChanged,
  });

  final String name;
  final bool isON;
  final bool isFocused;
  final void Function(bool)? onStateChanged;

  @override
  State<DeviceListMenuItem> createState() => _DeviceListMenuItemState();
}

class _DeviceListMenuItemState extends State<DeviceListMenuItem> {
  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    final isOperationRunning = context.watch<BtModel>().isBusy;
    final isEnabled = context.watch<BtModel>().isEnabled;
    final isBtSupported = context.watch<BtModel>().isBtSupported;

    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              widget.isFocused
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color:
                            widget.isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      isBtSupported
                          ? (isEnabled
                              ? AppLocalizations.of(context).on
                              : AppLocalizations.of(context).off)
                          : AppLocalizations.of(context).notSupported,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color:
                            widget.isFocused
                                ? Theme.of(
                                  context,
                                ).colorScheme.onTertiary.withAlphaF(0.8)
                                : Theme.of(
                                  context,
                                ).colorScheme.tertiary.withAlphaF(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Theme(
                data: Theme.of(context).copyWith(useMaterial3: false),
                child: Stack(
                  children: [
                    if (isBtSupported)
                      isOperationRunning
                          ? SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Colors.blue.withAlphaF(0.5),
                            ),
                          )
                          : Switch(
                            value: widget.isON,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              widget.onStateChanged?.call(value);
                            },
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

class DeviceListItem extends StatelessWidget {
  const DeviceListItem({
    super.key,
    required this.item,
    this.iconData,
    required this.isFocused,
  });

  final BtDevice item;
  final IconData? iconData;
  final bool isFocused;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

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
          padding: // left padding of item inside
              EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15, //innerPadding * 0.75, // between icon-text spacing
            children: [
              Icon(
                iconData,
                size: iconSize,
                color: isFocused ? Color(0xF04285F4) : Color(0xF0AEB2B9),
              ),
              // item text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    item.remoteName,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color:
                          isFocused
                              ? Theme.of(context).colorScheme.onTertiary
                              : Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    item.isConnected
                        ? AppLocalizations.of(context).connected
                        : (item.isBonded
                            ? AppLocalizations.of(context).paired
                            : (item.remoteAddress)),
                    style: TextStyle(
                      fontSize: subtitleFontSize,
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
