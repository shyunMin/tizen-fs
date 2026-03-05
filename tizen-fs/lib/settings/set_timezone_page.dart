import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/date_time_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/locale_utils.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

class SetTimezonePage extends StatefulWidget {
  const SetTimezonePage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetTimezonePage> createState() => _SetTimezonePageState();
}

class _SetTimezonePageState extends State<SetTimezonePage>
    with FocusSelectable<SetTimezonePage> {
  final GlobalKey<SelectableListViewState> _listKey =
      GlobalKey<SelectableListViewState>();
  int _focusedIndex = 0;
  int _selectedIndex = 0;

  late DateTimeManager _dateTimeManager;
  List<String> _timezones = [];

  @override
  void initState() {
    super.initState();
    _dateTimeManager = GetIt.instance<DateTimeManager>();
    _loadTimezones();
    if (widget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initFocus();
        _initializeSelection();
      });
    }
  }

  void _loadTimezones() {
    try {
      setState(() {
        _timezones = _dateTimeManager.getPopularTimezones();
      });
    } catch (e) {
      debugPrint("Error loading timezones: $e");
    }
  }

  void _initializeSelection() {
    if (_timezones.isEmpty) return;

    final currentTimezoneId = DateTimeManager.currentTimezone;
    if (currentTimezoneId.isNotEmpty) {
      for (int i = 0; i < _timezones.length; i++) {
        if (_timezones[i] == currentTimezoneId) {
          _focusedIndex = i;
          _selectedIndex = i;
          _listKey.currentState?.selectedIndex = _selectedIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _listKey.currentState?.jumpToIndex(_selectedIndex, 65);
            }
          });
          return;
        }
      }
    }
  }

  @override
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowDown;
  }

  @override
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowUp;
  }

  void initFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (!DateTimeManager.isAutoUpdated) {
          setState(() {
            _selectedIndex = _focusedIndex;
            _listKey.currentState?.selectedIndex = _selectedIndex;
          });
        }
        _handleTimezoneSelected(_selectedIndex);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        final totalItems = _timezones.length;
        if (_focusedIndex < totalItems - 1) {
          setState(() {
            _focusedIndex++;
          });
          _listKey.currentState?.scrollToIndex(_focusedIndex);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_focusedIndex > 0) {
          setState(() {
            _focusedIndex--;
          });
          _listKey.currentState?.scrollToIndex(_focusedIndex);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleTimezoneSelected(int index) {
    if (!widget.isEnabled) return;

    if (DateTimeManager.isAutoUpdated) {
      ToastMessage.show(
        context,
        AppLocalizations.of(context).pleaseTurnOffAutoUpdate,
        const Duration(seconds: 1),
      );
      return;
    }

    if (index >= 0 && index < _timezones.length) {
      final selectedTimezone = _timezones[index];

      if (selectedTimezone == DateTimeManager.currentTimezone) {
        return;
      }

      DateTimeManager.setTimezone(selectedTimezone);
    }
  }

  @override
  void didUpdateWidget(covariant SetTimezonePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          initFocus();
          _initializeSelection();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: onKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Title
          SizedBox(
            width: widget.isEnabled ? 600 : 400,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding:
                  widget.isEnabled
                      ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                      : EdgeInsets.fromLTRB(80, 60, 80, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  getLocalizedTextByKey(
                    context,
                    widget.node?.title ??
                        AppLocalizations.of(context).setTimezone,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedPadding(
                duration: $style.times.med,
                padding:
                    widget.isEnabled
                        ? const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        )
                        : const EdgeInsets.symmetric(horizontal: 40),
                child: _buildTimezoneListContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimezoneListContent() {
    if (_timezones.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).noTimezonesAvailable),
      );
    }

    return SelectableListView(
      key: _listKey,
      itemCount: _timezones.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index, selectedIndex, key) {
        return AnimatedScale(
          key: key,
          scale:
              Focus.of(context).hasFocus && index == _focusedIndex ? 1.0 : .9,
          duration: $style.times.med,
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
                _focusedIndex = index;
                _listKey.currentState?.selectedIndex = _selectedIndex;
              });
              Focus.of(context).requestFocus();
              _handleTimezoneSelected(index);
            },
            child: TimezoneMenuItem(
              title: LocaleUtils.getTimezoneDisplayName(
                context,
                _timezones[index],
              ),
              isSelected: index == _selectedIndex,
              isFocused: index == _focusedIndex,
              isEnabled: widget.isEnabled,
            ),
          ),
        );
      },
    );
  }
}

class TimezoneMenuItem extends StatelessWidget {
  const TimezoneMenuItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.isFocused,
    required this.isEnabled,
  });

  final String title;
  final bool isSelected;
  final bool isFocused;
  final bool isEnabled;

  static const double titleFontSize = 15;
  static const double innerPadding = 20;
  static const double itemHeight = 65;

  Color _getTextColor(BuildContext context) {
    if (!isEnabled) {
      return Theme.of(context).colorScheme.tertiary;
    }
    if (isFocused) {
      return Theme.of(context).colorScheme.onTertiary;
    } else {
      return Theme.of(context).colorScheme.tertiary;
    }
  }

  Color _getContainerColor(BuildContext context) {
    if (!isEnabled) {
      return Colors.transparent;
    }
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
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: _getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Radio
              Padding(
                padding:
                    isSelected
                        ? const EdgeInsets.only(right: 15)
                        : const EdgeInsets.only(right: 0),
                child: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _getTextColor(context),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
