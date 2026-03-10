import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/date_time_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/locale_utils.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class DateTimeListView extends StatefulWidget {
  const DateTimeListView({
    super.key,
    this.node,
    this.onFocusChanged,
    this.onSelectionChanged,
    this.onRequestGoBack,
  });

  final PageNode? node;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;
  final Function(int)? onRequestGoBack;

  @override
  State<DateTimeListView> createState() => DateTimeListViewState();
}

class DateTimeListViewState extends State<DateTimeListView>
    with FocusSelectable<DateTimeListView> {
  int _selected = 0;

  final List<String> _menuTitles = [
    'Auto update',
    'Set date',
    'Set time',
    'Timezone',
    '24-hour clock',
  ];

  void initFocus() {
    focusNode.requestFocus();
  }

  @override
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowDown;
  }

  @override
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowUp;
  }

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _handleItemSelection(_selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _handleArrowUp();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _handleArrowDown();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleArrowUp() {
    int newItemIndex = (_selected - 1).clamp(0, _menuTitles.length - 1);
    if (DateTimeManager.isAutoUpdated &&
        (newItemIndex == 1 || newItemIndex == 2 || newItemIndex == 3)) {
      newItemIndex = 0;
    }
    _selectItem(newItemIndex);
  }

  void _handleArrowDown() {
    int newItemIndex = (_selected + 1).clamp(0, _menuTitles.length - 1);
    if (DateTimeManager.isAutoUpdated &&
        (newItemIndex == 1 || newItemIndex == 2 || newItemIndex == 3)) {
      newItemIndex = 4;
    }
    _selectItem(newItemIndex);
  }

  void _selectItem(int index) {
    if (index != _selected) {
      listKey.currentState?.selectTo(index);
      _selected = index;
      widget.onFocusChanged?.call(index);
    }
  }

  void _handleItemSelection(int index) {
    switch (index) {
      case 0:
        DateTimeManager.setAutoUpdate(!DateTimeManager.isAutoUpdated);
        setState(() {});
        break;
      case 4:
        DateTimeManager.setTimeFormat(!DateTimeManager.is24HourFormat);
        setState(() {});
        break;
      default:
        widget.onSelectionChanged?.call(index);
        break;
    }
  }

  @override
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        itemCount: widget.node?.children.length ?? _menuTitles.length,
        scrollDirection: Axis.vertical,
        onItemFocused: (focused) {
          _selected = focused;
          widget.onFocusChanged?.call(focused);
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
                if (DateTimeManager.isAutoUpdated && index > 0 && index != 4) {
                  return;
                }
                listKey.currentState?.selectTo(index);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _handleItemSelection(index);
                  }
                });
              },
              child: DateTimeMenuItem(
                title: widget.node?.children[index].title ?? _menuTitles[index],
                index: index,
                isFocused: Focus.of(context).hasFocus && index == selectedIndex,
              ),
            ),
          );
        },
      ),
    );
  }
}

class DateTimeMenuItem extends StatelessWidget {
  const DateTimeMenuItem({
    super.key,
    required this.title,
    required this.index,
    required this.isFocused,
  });

  final String title;
  final int index;
  final bool isFocused;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;

  String _getStatusText(BuildContext context) {
    switch (index) {
      case 0:
        if (!DateTimeManager.isSupported) {
          return AppLocalizations.of(context).notSupported;
        } else if (DateTimeManager.isAutoUpdated) {
          return AppLocalizations.of(context).on;
        } else {
          return AppLocalizations.of(context).off;
        }
      case 1:
        return DateTimeManager.formatDate(DateTimeManager.currentDateTime);
      case 2:
        return DateTimeManager.formatTime(DateTimeManager.currentDateTime);
      case 3:
        return LocaleUtils.getTimezoneDisplayName(
          context,
          DateTimeManager.currentTimezone,
        );
      case 4:
        return DateTimeManager.is24HourFormat
            ? AppLocalizations.of(context).on
            : AppLocalizations.of(context).off;
      default:
        return '';
    }
  }

  bool get isItemEnabled {
    if (DateTimeManager.isAutoUpdated && index > 0 && index != 4) {
      return false;
    }
    return true;
  }

  Color _getTextColor(BuildContext context) {
    if (!isItemEnabled) {
      return Colors.grey.withAlphaF(0.5);
    }
    return isFocused
        ? Theme.of(context).colorScheme.onTertiary
        : Theme.of(context).colorScheme.tertiary;
  }

  Color _getContainerColor(BuildContext context) {
    return isFocused
        ? Theme.of(context).colorScheme.tertiary
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _getContainerColor(context),
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
                      getLocalizedTextByKey(context, title),
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: _getTextColor(context),
                      ),
                    ),
                    Text(
                      _getStatusText(context),
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: _getTextColor(context).withAlphaF(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (index == 0)
                Theme(
                  data: Theme.of(context).copyWith(useMaterial3: false),
                  child: Padding(
                    padding:
                        isFocused
                            ? const EdgeInsets.only(right: 15)
                            : const EdgeInsets.only(right: 0),
                    child: IgnorePointer(
                      child: Switch(
                        value: DateTimeManager.isAutoUpdated,
                        onChanged: (value) {},
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              if (index == 4)
                Theme(
                  data: Theme.of(context).copyWith(useMaterial3: false),
                  child: Padding(
                    padding:
                        isFocused
                            ? const EdgeInsets.only(right: 15)
                            : const EdgeInsets.only(right: 0),
                    child: IgnorePointer(
                      child: Switch(
                        value: DateTimeManager.is24HourFormat,
                        onChanged: (value) {},
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
