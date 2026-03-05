import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/widgets/app_popup.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/app_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/category_selectable_listview.dart';

class AppsDetailPage extends StatefulWidget {
  const AppsDetailPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onSelectionChanged,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onSelectionChanged;
  final Function(int)? onRequestGoBack;

  @override
  State<AppsDetailPage> createState() => AppsDetailPageState();
}

class AppsDetailPageState extends State<AppsDetailPage> {
  GlobalKey<CategoryListViewState> _listKey =
      GlobalKey<CategoryListViewState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(AppsDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  List<Item> _loadAppData(AppData app) {
    final details = <Item>[];

    details.add(Item(isKey: true, item: ['Version ${app.version}', app.appId]));

    if (app.isRunning && !app.isDefaultApp)
      details.add(
        Item(
          isKey: false,
          item: [AppLocalizations.of(context).forceStop, null, 'stop'],
        ),
      );

    if (!app.isPreloaded && !app.isDefaultApp)
      details.add(
        Item(
          isKey: false,
          item: [AppLocalizations.of(context).uninstall, null, 'uninstall'],
        ),
      );

    details.add(
      Item(
        isKey: false,
        item: [
          AppLocalizations.of(context).totalSize,
          app.size?.total ?? 0,
          null,
        ],
      ),
    );
    details.add(
      Item(
        isKey: false,
        item: [AppLocalizations.of(context).appsize, app.size?.app ?? 0, null],
      ),
    );
    details.add(
      Item(
        isKey: false,
        item: [
          AppLocalizations.of(context).userData,
          app.size?.userData ?? 0,
          null,
        ],
      ),
    );
    details.add(
      Item(
        isKey: false,
        item: [
          AppLocalizations.of(context).cache,
          app.size?.cache ?? 0,
          'cache',
        ],
      ),
    );

    return details;
  }

  @override
  Widget build(BuildContext context) {
    double titleFontSize = 35;

    final app = context.watch<AppDataModel>().selectedApp;
    final items = _loadAppData(app);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        SizedBox(
          // duration: $style.times.med,
          // curve: Curves.easeInOut,
          width: widget.isEnabled ? 600 : 400,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding: // title up/left padding
                widget.isEnabled
                    ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                    : EdgeInsets.fromLTRB(80, 60, 80, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                app.name,
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 2,
                style: TextStyle(fontSize: titleFontSize),
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding: // item left/right padding
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 40),
              child: CategoryListView(
                key: _listKey,
                items: items,
                onItemSelected: (selected) {
                  final value = items[selected].item[2];
                  if (value is String) {
                    _run(value, app);
                  }
                },
                onAction: (index) {
                  final value = items[index].item[2];
                  if (value is String) {
                    _run(value, app);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _run(String command, AppData app) {
    if (command == 'uninstall') {
      _showAppRemovePopup(app);
    } else if (command == 'stop') {
      _showAppStopPopup(app);
    } else if (command == 'cache') {
      _showClearCachePopup(app);
    }
  }

  void _forceStop(AppData app) {
    ApplicationManager.forceStop(app.appId);
    context.read<AppDataModel>().removeRunningApp(app);

    widget.onRequestGoBack?.call(1);
  }

  void _removeApp(AppData app) async {
    await ApplicationManager.uninstallPackage(app.packageId);
    widget.onRequestGoBack?.call(1);
  }

  void _clearCache(AppData app) async {
    await ApplicationManager.clearCache(app.packageId);

    Timer(const Duration(seconds: 1), () {
      Provider.of<AppDataModel>(context, listen: false).reloadAppSize(app);
    });
  }

  void _showAppStopPopup(AppData app) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AppPopup(
          app: app,
          message: AppLocalizations.of(context).forceStopMessage,
          onConfirm: () {
            _forceStop(app);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _showAppRemovePopup(AppData app) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AppPopup(
          app: app,
          message: AppLocalizations.of(context).uninstallMessage,
          onConfirm: () {
            _removeApp(app);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _showClearCachePopup(AppData app) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AppPopup(
          app: app,
          message: AppLocalizations.of(context).clearCacheMessage,
          onConfirm: () {
            _clearCache(app);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class CategoryListView extends StatefulWidget {
  const CategoryListView({
    super.key,
    required this.items,
    this.onItemFocused,
    this.onItemSelected,
    this.onAction,
  });

  final Function(int)? onAction;
  final Function(int)? onItemSelected;
  final Function(int)? onItemFocused;
  final List<Item> items;

  @override
  State<CategoryListView> createState() => CategoryListViewState();
}

class CategoryListViewState extends State<CategoryListView>
    with CategoryFocusSelectable<CategoryListView> {
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
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasfocus) {
        if (hasfocus) {
          listKey.currentState?.selectTo(_selected);
        } else {
          _selected = listKey.currentState?.selectedIndex ?? 1;
        }
      },
      child: CategorySelectableListView(
        items: widget.items,
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

mixin CategoryFocusSelectable<T extends StatefulWidget> on State<T> {
  final GlobalKey<CategorySelectableListViewState> _listState =
      GlobalKey<CategorySelectableListViewState>();
  final FocusNode _focusNode = FocusNode();

  GlobalKey<CategorySelectableListViewState> get listKey => _listState;
  FocusNode get focusNode => _focusNode;
  int get selectedIndex => _listState.currentState?.selectedIndex ?? 0;

  LogicalKeyboardKey get nextKey => getNextKey();

  LogicalKeyboardKey get prevKey => getPrevKey();

  LogicalKeyboardKey getNextKey() {
    return LogicalKeyboardKey.arrowRight;
  }

  LogicalKeyboardKey getPrevKey() {
    return LogicalKeyboardKey.arrowLeft;
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
      } else if (event.logicalKey == nextKey) {
        onNext(event is KeyRepeatEvent);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
