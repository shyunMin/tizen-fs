import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/widgets/bt_selectable_listview.dart';
import 'package:tizen_fs/widgets/bt_focus_selectable.dart';

class BtDeviceListView extends StatefulWidget {
  const BtDeviceListView({super.key, this.onAction});

  final Function(int)? onAction;

  @override
  State<BtDeviceListView> createState() => BtDeviceListViewState();
}

class BtDeviceListViewState extends State<BtDeviceListView>
    with BtFocusSelectable<BtDeviceListView> {
  int _selected = 1;

  @override
  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowDown;
  }

  @override
  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowUp;
  }

  void initFocus() {
    focusNode.requestFocus();
  }

  void selectTo(int index) {
    listKey.currentState?.selectTo(index);
  }

  void forceScrollTo(int index) {
    listKey.currentState?.forceScrollTo(index);
  }

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (listKey.currentState != null) {
          widget.onAction?.call(listKey.currentState!.selectedIndex);
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget build(BuildContext context) {
    final data = Provider.of<BtModel>(context).data;

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasfocus) {
        if (hasfocus) {
          listKey.currentState?.selectTo(_selected);
        } else {
          _selected = listKey.currentState?.selectedIndex ?? 1;
        }
      },
      child: BtCategorySelectableListView(
        items: data,
        scrollOffset: 260,
        key: listKey,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: 0.5,
        scrollDirection: Axis.vertical,
        onAction: widget.onAction,
      ),
    );
  }
}
