import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/date_time_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/toast_message.dart';
import 'package:wheel_picker/wheel_picker.dart';

class SetDatePage extends StatefulWidget {
  const SetDatePage({super.key, required this.node, required this.isEnabled});

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetDatePage> createState() => _SetDatePageState();
}

enum _DateComponent { year, month, day, select }

class _SetDatePageState extends State<SetDatePage>
    with FocusSelectable<SetDatePage> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late FocusNode _yearFocusNode;
  late FocusNode _monthFocusNode;
  late FocusNode _dayFocusNode;
  late FocusNode _selectFocusNode;

  late WheelPickerController _yearController;
  late WheelPickerController _monthController;
  late WheelPickerController _dayController;

  _DateComponent _selectedComponent = _DateComponent.year;

  //TODO: check system available
  final int _maxYear = 2100;
  final int _minYear = 1970;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;

    _yearFocusNode = FocusNode();
    _monthFocusNode = FocusNode();
    _dayFocusNode = FocusNode();
    _selectFocusNode = FocusNode();

    final List<int> years = List.generate(
      _maxYear - _minYear + 1,
      (index) => _minYear + index,
    );
    final List<int> months = List.generate(12, (index) => index + 1);
    final List<int> days = List.generate(
      _getDaysInMonth(_selectedYear, _selectedMonth),
      (index) => index + 1,
    );

    _yearController = WheelPickerController(
      itemCount: years.length,
      initialIndex: years.indexOf(_selectedYear),
    );
    _monthController = WheelPickerController(
      itemCount: months.length,
      initialIndex: months.indexOf(_selectedMonth),
    );
    _dayController = WheelPickerController(
      itemCount: days.length,
      initialIndex: days.indexOf(_selectedDay),
    );

    if (widget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          initFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _yearFocusNode.dispose();
    _monthFocusNode.dispose();
    _dayFocusNode.dispose();
    _selectFocusNode.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void initFocus() {
    _yearFocusNode.requestFocus();
    _selectedComponent = _DateComponent.year;
  }

  @override
  void didUpdateWidget(covariant SetDatePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  List<_DateComponent> get _availableComponents {
    return _DateComponent.values;
  }

  FocusNode _getFocusNodeForComponent(_DateComponent component) {
    switch (component) {
      case _DateComponent.year:
        return _yearFocusNode;
      case _DateComponent.month:
        return _monthFocusNode;
      case _DateComponent.day:
        return _dayFocusNode;
      default:
        return _selectFocusNode;
    }
  }

  void _focusComponent(_DateComponent component) {
    if (component == _DateComponent.select) {
      _getFocusNodeForComponent(_DateComponent.year).unfocus();
      _getFocusNodeForComponent(_DateComponent.month).unfocus();
      _getFocusNodeForComponent(_DateComponent.day).unfocus();
    } else {
      _getFocusNodeForComponent(_DateComponent.select).unfocus();
    }

    _getFocusNodeForComponent(component).requestFocus();
    setState(() {
      _selectedComponent = component;
    });
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
      bool handled = true;
      final availableComps = _availableComponents;
      int currentIndex = availableComps.indexOf(_selectedComponent);
      if (currentIndex == -1) {
        _focusComponent(availableComps.first);
        return KeyEventResult.handled;
      }

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          if (_selectedComponent == _DateComponent.year) {
            handled = false;
          } else {
            int newIndex =
                (currentIndex - 1 + availableComps.length) %
                availableComps.length;
            _focusComponent(availableComps[newIndex]);
          }
          break;
        case LogicalKeyboardKey.arrowRight:
          int newIndex = (currentIndex + 1) % availableComps.length;
          _focusComponent(availableComps[newIndex]);
          break;
        case LogicalKeyboardKey.arrowDown:
          _verifySelectedComponent(1);
          break;
        case LogicalKeyboardKey.arrowUp:
          _verifySelectedComponent(-1);
          break;
        case LogicalKeyboardKey.enter:
          _updateSystemDate();
          handled = false;
          return KeyEventResult.ignored;
        default:
          handled = false;
          break;
      }

      if (handled) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _verifySelectedComponent(int delta) {
    setState(() {
      switch (_selectedComponent) {
        case _DateComponent.year:
          int newYear = _selectedYear + delta;
          if (newYear >= _minYear && newYear <= _maxYear) {
            _selectedYear = newYear;
            _yearController.shiftTo(newYear - _minYear);
            _verifyDayForMonthYear();
            _updateDayController();
          }
          break;
        case _DateComponent.month:
          int newMonth = _selectedMonth + delta;
          if (newMonth < 1) {
            newMonth = 12;
            if (_selectedYear > _minYear) _selectedYear--;
          } else if (newMonth > 12) {
            newMonth = 1;
            if (_selectedYear < _maxYear) _selectedYear++;
          }
          if (_selectedYear >= _minYear && _selectedYear <= _maxYear) {
            _selectedMonth = newMonth;
            _monthController.shiftTo(newMonth - 1);
            _verifyDayForMonthYear();
            _updateDayController();
          }
          break;
        case _DateComponent.day:
          int newDay = _selectedDay + delta;
          int daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
          if (newDay < 1) {
            newDay = daysInMonth;
          } else if (newDay > daysInMonth) {
            newDay = 1;
          } else {
            _selectedDay = newDay;
          }
          _dayController.shiftTo(newDay - 1);
          break;
        default:
          break;
      }
    });
  }

  void _updateDayController() {
    final int daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }
    _dayController.itemCount = daysInMonth;
    _dayController.shiftTo(_selectedDay - 1);
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _verifyDayForMonthYear() {
    int daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }
  }

  void _updateSystemDate() {
    if (DateTimeManager.isAutoUpdated) {
      ToastMessage.show(
        context,
        AppLocalizations.of(context).pleaseTurnOffAutoUpdate,
        const Duration(seconds: 1),
      );
      return;
    }

    _selectedYear = _selectedYear.clamp(_minYear, _maxYear);
    _selectedMonth = _selectedMonth.clamp(1, 12);
    _selectedDay = _selectedDay.clamp(1, 31);

    final now = DateTime.now();
    final currentTime = DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay,
      now.hour,
      now.minute,
    );
    DateTimeManager.setManualDateTime(currentTime);
    ToastMessage.show(
      context,
      '${AppLocalizations.of(context).setDate} ${_selectedYear}/${_selectedMonth}/${_selectedDay}',
      const Duration(seconds: 1),
    );
  }

  TextStyle _getSelectTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
      fontSize: 30,
    );
  }

  TextStyle _getUnSelectTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.grey,
      fontSize: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> years = List.generate(
      _maxYear - _minYear + 1,
      (index) => _minYear + index,
    );
    final List<int> months = List.generate(12, (index) => index + 1);
    final List<int> days = List.generate(
      _getDaysInMonth(_selectedYear, _selectedMonth),
      (index) => index + 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
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
                  widget.node?.title ?? AppLocalizations.of(context).setDate,
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
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
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
                child: Focus(
                  focusNode: focusNode,
                  canRequestFocus: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 20,
                    children: [
                      // year
                      Focus(
                        focusNode: _yearFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus)
                            setState(
                              () => _selectedComponent = _DateComponent.year,
                            );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _focusComponent(_DateComponent.year);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 100,
                              height: 200,
                              child: WheelPicker(
                                controller: _yearController,
                                looping: false,
                                enableTap: false,
                                onIndexChanged: (index, _) {
                                  _selectedComponent = _DateComponent.year;
                                  setState(() {
                                    _selectedYear = years[index];
                                    _verifyDayForMonthYear();
                                    _updateDayController();
                                  });
                                },
                                builder: (context, index) {
                                  final isSelected =
                                      _selectedComponent ==
                                          _DateComponent.year &&
                                      index == years.indexOf(_selectedYear);
                                  return Center(
                                    child: Text(
                                      years[index].toString(),
                                      style:
                                          isSelected
                                              ? widget.isEnabled
                                                  ? _getSelectTextStyle()
                                                  : _getUnSelectTextStyle()
                                              : _getUnSelectTextStyle(),
                                    ),
                                  );
                                },
                                style: WheelPickerStyle(
                                  squeeze: 1.2,
                                  itemExtent: 50,
                                  magnification: 1.2,
                                  surroundingOpacity:
                                      widget.isEnabled ? 0.6 : 0,
                                  shiftAnimationStyle: WheelShiftAnimationStyle(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // month
                      Focus(
                        focusNode: _monthFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus)
                            setState(
                              () => _selectedComponent = _DateComponent.month,
                            );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _focusComponent(_DateComponent.month);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 200,
                              child: WheelPicker(
                                controller: _monthController,
                                looping: false,
                                enableTap: false,
                                onIndexChanged: (index, _) {
                                  _selectedComponent = _DateComponent.month;
                                  setState(() {
                                    _selectedMonth = months[index];
                                    _verifyDayForMonthYear();
                                    _updateDayController();
                                  });
                                },
                                builder: (context, index) {
                                  final isSelected =
                                      _selectedComponent ==
                                          _DateComponent.month &&
                                      index == months.indexOf(_selectedMonth);
                                  return Center(
                                    child: Text(
                                      months[index].toString().padLeft(2, '0'),
                                      style:
                                          isSelected
                                              ? widget.isEnabled
                                                  ? _getSelectTextStyle()
                                                  : _getUnSelectTextStyle()
                                              : _getUnSelectTextStyle(),
                                    ),
                                  );
                                },
                                style: WheelPickerStyle(
                                  squeeze: 1.2,
                                  itemExtent: 50,
                                  magnification: 1.2,
                                  surroundingOpacity:
                                      widget.isEnabled ? 0.6 : 0,
                                  shiftAnimationStyle: WheelShiftAnimationStyle(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // day
                      Focus(
                        focusNode: _dayFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus)
                            setState(
                              () => _selectedComponent = _DateComponent.day,
                            );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _focusComponent(_DateComponent.day);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 200,
                              child: WheelPicker(
                                controller: _dayController,
                                looping: false,
                                enableTap: false,
                                onIndexChanged: (index, _) {
                                  _selectedComponent = _DateComponent.day;
                                  setState(() {
                                    _selectedDay = days[index];
                                  });
                                },
                                builder: (context, index) {
                                  final isSelected =
                                      _selectedComponent ==
                                          _DateComponent.day &&
                                      index == days.indexOf(_selectedDay);
                                  return Center(
                                    child: Text(
                                      days[index].toString().padLeft(2, '0'),
                                      style:
                                          isSelected
                                              ? widget.isEnabled
                                                  ? _getSelectTextStyle()
                                                  : _getUnSelectTextStyle()
                                              : _getUnSelectTextStyle(),
                                    ),
                                  );
                                },
                                style: WheelPickerStyle(
                                  squeeze: 1.2,
                                  itemExtent: 50,
                                  magnification: 1.2,
                                  surroundingOpacity:
                                      widget.isEnabled ? 0.6 : 0,
                                  shiftAnimationStyle: WheelShiftAnimationStyle(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // select button
                      Focus(
                        focusNode: _selectFocusNode,
                        onFocusChange: (hasFocus) {},
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTapUp: (detail) {
                              _focusComponent(_DateComponent.select);
                              _updateSystemDate();
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Center(
                                child: Transform.scale(
                                  scale: _selectFocusNode.hasFocus ? 1.5 : 1.0,
                                  child: Icon(
                                    Icons.subdirectory_arrow_left,
                                    color:
                                        _selectFocusNode.hasFocus
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
