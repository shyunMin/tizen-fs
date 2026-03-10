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

class SetTimePage extends StatefulWidget {
  const SetTimePage({super.key, required this.node, required this.isEnabled});

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetTimePage> createState() => _SetTimePageState();
}

enum _TimeComponent { hour, minute, period, select }

class _SetTimePageState extends State<SetTimePage>
    with FocusSelectable<SetTimePage> {
  late bool _is24HourFormat;
  late int _selectedHour24;
  late int _selectedMinute;
  late String _selectedPeriod;
  _TimeComponent _selectedComponent = _TimeComponent.hour;

  late FocusNode _hourFocusNode;
  late FocusNode _minuteFocusNode;
  late FocusNode _periodFocusNode;
  late FocusNode _selectFocusNode;

  late WheelPickerController _hourController;
  late WheelPickerController _minuteController;
  late WheelPickerController _periodController;

  @override
  void initState() {
    super.initState();
    _is24HourFormat = DateTimeManager.is24HourFormat;
    final now = DateTime.now();
    _selectedHour24 = now.hour;
    _selectedMinute = now.minute;
    _updatePeriodFromHour24(_selectedHour24);

    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();
    _periodFocusNode = FocusNode();
    _selectFocusNode = FocusNode();

    final List<int> hours =
        _is24HourFormat
            ? List.generate(24, (index) => index)
            : List.generate(12, (index) => index + 1);
    final List<int> minutes = List.generate(60, (index) => index);
    final List<String> periods = ["AM", "PM"];

    _hourController = WheelPickerController(
      itemCount: hours.length,
      initialIndex: hours.indexOf(
        _is24HourFormat ? _selectedHour24 : _selectedHour12,
      ),
    );
    _minuteController = WheelPickerController(
      itemCount: minutes.length,
      initialIndex: minutes.indexOf(_selectedMinute),
    );
    _periodController = WheelPickerController(
      itemCount: periods.length,
      initialIndex: periods.indexOf(_selectedPeriod),
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
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    _periodFocusNode.dispose();
    _selectFocusNode.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _updatePeriodFromHour24(int hour) {
    _selectedPeriod = hour >= 12 ? 'PM' : 'AM';
  }

  int get _selectedHour12 {
    int hour = _selectedHour24 % 12;
    return hour == 0 ? 12 : hour;
  }

  void initFocus() {
    _hourFocusNode.requestFocus();
    _selectedComponent = _TimeComponent.hour;
  }

  @override
  void didUpdateWidget(covariant SetTimePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  List<_TimeComponent> get _availableComponents {
    if (_is24HourFormat) {
      return _TimeComponent.values
          .where((c) => c != _TimeComponent.period)
          .toList();
    }
    return _TimeComponent.values;
  }

  FocusNode _getFocusNodeForComponent(_TimeComponent component) {
    switch (component) {
      case _TimeComponent.hour:
        return _hourFocusNode;
      case _TimeComponent.minute:
        return _minuteFocusNode;
      case _TimeComponent.period:
        return _periodFocusNode;
      default:
        return _selectFocusNode;
    }
  }

  void _focusComponent(_TimeComponent component) {
    if (component == _TimeComponent.select) {
      _getFocusNodeForComponent(_TimeComponent.hour).unfocus();
      _getFocusNodeForComponent(_TimeComponent.minute).unfocus();
      _getFocusNodeForComponent(_TimeComponent.period).unfocus();
    } else {
      _getFocusNodeForComponent(_TimeComponent.select).unfocus();
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
          if (_selectedComponent == _TimeComponent.hour) {
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
          _updateSystemTime();
          break;
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
        case _TimeComponent.hour:
          int newHour;
          if (_is24HourFormat) {
            newHour = _selectedHour24 + delta;
            if (newHour < 0) newHour = 23;
            if (newHour > 23) newHour = 0;
            _selectedHour24 = newHour;
            _hourController.shiftTo(newHour);
          } else {
            int newHour12 = _selectedHour12 + delta;
            if (newHour12 < 1) newHour12 = 12;
            if (newHour12 > 12) newHour12 = 1;
            if (_selectedPeriod == 'AM') {
              _selectedHour24 = newHour12 == 12 ? 0 : newHour12;
            } else {
              _selectedHour24 = newHour12 == 12 ? 12 : newHour12 + 12;
            }
            final List<int> hours = List.generate(12, (index) => index + 1);
            _hourController.shiftTo(hours.indexOf(newHour12));
          }
          break;
        case _TimeComponent.minute:
          int newMinute = _selectedMinute + delta;
          if (newMinute < 0) newMinute = 59;
          if (newMinute > 59) newMinute = 0;
          _selectedMinute = newMinute;
          _minuteController.shiftTo(newMinute);
          break;
        case _TimeComponent.period:
          if (!_is24HourFormat) {
            _selectedPeriod = _selectedPeriod == 'AM' ? 'PM' : 'AM';
            if (_selectedPeriod == 'AM') {
              if (_selectedHour24 >= 12) _selectedHour24 -= 12;
            } else {
              if (_selectedHour24 < 12) _selectedHour24 += 12;
            }
            _periodController.shiftTo(_selectedPeriod == 'AM' ? 0 : 1);
          }
          break;
        default:
          break;
      }
    });
  }

  void _updateSystemTime() {
    final now = DateTime.now();
    final currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedHour24,
      _selectedMinute,
    );
    if (DateTimeManager.isAutoUpdated) {
      ToastMessage.show(
        context,
        AppLocalizations.of(context).pleaseTurnOffAutoUpdate,
        const Duration(seconds: 1),
      );
    } else {
      DateTimeManager.setManualDateTime(currentTime);

      final message =
          _is24HourFormat
              ? _selectedMinute < 10
                  ? '${AppLocalizations.of(context).setTime} ${_selectedHour24}:0${_selectedMinute}'
                  : '${AppLocalizations.of(context).setTime} ${_selectedHour24}:${_selectedMinute}'
              : _selectedMinute < 10
              ? '${AppLocalizations.of(context).setTime} ${_selectedHour24}:0${_selectedMinute} ${_selectedPeriod}'
              : '${AppLocalizations.of(context).setTime} ${_selectedHour24}:${_selectedMinute} ${_selectedPeriod}';
      ToastMessage.show(context, message, const Duration(seconds: 1));
    }
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
    final List<int> hours =
        _is24HourFormat
            ? List.generate(24, (index) => index)
            : List.generate(12, (index) => index + 1);
    final List<int> minutes = List.generate(60, (index) => index);
    final List<String> periods = ["AM", "PM"];

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
                  widget.node?.title ?? AppLocalizations.of(context).setTime,
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
                      // hour
                      Focus(
                        focusNode: _hourFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus)
                            setState(
                              () => _selectedComponent = _TimeComponent.hour,
                            );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _focusComponent(_TimeComponent.hour);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 200,
                              child: WheelPicker(
                                controller: _hourController,
                                looping: false,
                                enableTap: false,
                                onIndexChanged: (index, _) {
                                  _selectedComponent = _TimeComponent.hour;
                                  setState(() {
                                    if (_is24HourFormat) {
                                      _selectedHour24 = hours[index];
                                    } else {
                                      if (_selectedPeriod == 'AM') {
                                        _selectedHour24 =
                                            hours[index] == 12
                                                ? 0
                                                : hours[index];
                                      } else {
                                        _selectedHour24 =
                                            hours[index] == 12
                                                ? 12
                                                : hours[index] + 12;
                                      }
                                    }
                                  });
                                },
                                builder: (context, index) {
                                  final isSelected =
                                      _selectedComponent ==
                                          _TimeComponent.hour &&
                                      index ==
                                          hours.indexOf(
                                            _is24HourFormat
                                                ? _selectedHour24
                                                : _selectedHour12,
                                          );
                                  return Center(
                                    child: Text(
                                      hours[index].toString().padLeft(2, '0'),
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
                      // min
                      Focus(
                        focusNode: _minuteFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus)
                            setState(
                              () => _selectedComponent = _TimeComponent.minute,
                            );
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _focusComponent(_TimeComponent.minute);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 200,
                              child: WheelPicker(
                                controller: _minuteController,
                                looping: false,
                                enableTap: false,
                                onIndexChanged: (index, _) {
                                  _selectedComponent = _TimeComponent.minute;
                                  setState(() {
                                    _selectedMinute = minutes[index];
                                  });
                                },
                                builder: (context, index) {
                                  final isSelected =
                                      _selectedComponent ==
                                          _TimeComponent.minute &&
                                      index == minutes.indexOf(_selectedMinute);
                                  return Center(
                                    child: Text(
                                      minutes[index].toString().padLeft(2, '0'),
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
                      // ampm
                      if (!_is24HourFormat)
                        Focus(
                          focusNode: _periodFocusNode,
                          onFocusChange: (hasFocus) {
                            if (hasFocus)
                              setState(
                                () =>
                                    _selectedComponent = _TimeComponent.period,
                              );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _focusComponent(_TimeComponent.period);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 80,
                                height: 200,
                                child: WheelPicker(
                                  controller: _periodController,
                                  looping: false,
                                  enableTap: false,
                                  onIndexChanged: (index, _) {
                                    _selectedComponent = _TimeComponent.period;
                                    setState(() {
                                      _selectedPeriod = periods[index];
                                      if (_selectedPeriod == 'AM') {
                                        if (_selectedHour24 >= 12)
                                          _selectedHour24 -= 12;
                                      } else {
                                        if (_selectedHour24 < 12)
                                          _selectedHour24 += 12;
                                      }
                                    });
                                  },
                                  builder: (context, index) {
                                    final isSelected =
                                        _selectedComponent ==
                                            _TimeComponent.period &&
                                        index ==
                                            periods.indexOf(_selectedPeriod);
                                    return Center(
                                      child: Text(
                                        periods[index],
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
                                    shiftAnimationStyle:
                                        WheelShiftAnimationStyle(
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
                              _focusComponent(_TimeComponent.hour);
                              _updateSystemTime();
                            },
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // For a circular button
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
