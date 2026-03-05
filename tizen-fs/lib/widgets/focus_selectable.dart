import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

mixin FocusSelectable<T extends StatefulWidget> on State<T> {
  final GlobalKey<SelectableListViewState> _listState =
      GlobalKey<SelectableListViewState>();
  final FocusNode _focusNode = FocusNode();

  GlobalKey<SelectableListViewState> get listKey => _listState;
  FocusNode get focusNode => _focusNode;
  int get selectedIndex => _listState.currentState?.selectedIndex ?? 0;

  LogicalKeyboardKey get nextKey => getNextKey();

  LogicalKeyboardKey get prevKey => getPrevKey();

  LogicalKeyboardKey get selectKey => getSelectKey();

  @protected
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowRight;
  }

  @protected
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowLeft;
  }

  @protected
  LogicalKeyboardKey getSelectKey() {
    return LogicalKeyboardKey.enter;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _onKeyEvent;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @protected
  Future<void> onNext(bool fast) async {
    await _listState.currentState?.next(fast: fast);
  }

  @protected
  Future<void> onPrev(bool fast) async {
    await _listState.currentState?.previous(fast: fast);
  }

  @protected
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    return KeyEventResult.ignored;
  }

  KeyEventResult _onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (onKeyEvent(focusNode, event) == KeyEventResult.handled) {
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == prevKey) {
        onPrev(event is KeyRepeatEvent);
        return KeyEventResult.handled;
      } else if (event.logicalKey == nextKey ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        onNext(event is KeyRepeatEvent);
        return KeyEventResult.handled;
      } else if (event.logicalKey == selectKey ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _listState.currentState?.callItemSelected();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
