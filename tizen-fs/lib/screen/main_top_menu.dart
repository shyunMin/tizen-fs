import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:tizen_fs/providers/backdrop_provider.dart';
import 'package:tizen_fs/providers/setting_menu_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/router.dart';
import 'package:tizen_fs/notifications/notification_panel.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/ui_event.dart';
import 'package:tizen_fs/widgets/top_menu_avatar_item.dart';
import 'package:tizen_fs/widgets/top_menu_button_item.dart';
import 'package:tizen_fs/widgets/top_menu_icon_item.dart';
import 'package:tizen_fs/profiles/switch_profile_panel.dart';
import 'package:tizen_fs/widgets/top_menu_notification.dart';

class MainTopMenu extends StatefulWidget {
  const MainTopMenu({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<MainTopMenu> createState() => MainTopMenuState();
}

class MainTopMenuState extends State<MainTopMenu> {
  final FocusNode _focusNode = FocusNode();
  StreamSubscription? _subscription;
  int _itemCount = 0;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    context.read<TabBarProvider>().setFocusNode(_focusNode);
    context.read<TabBarProvider>().initIndex(1);
    context.read<TabBarProvider>().addListener(_onIndexChanged);

    _subscription = ActionManager.eventStream.listen(_onActionEvent);
  }

  void requestFocus() {
    _focusNode.requestFocus();
  }

  void _onIndexChanged() {
    final index = context.read<TabBarProvider>().currentIndex;
    if (index > 0 && index < (_itemCount - 3)) {
      _movePage(index - 1);
    } else if (index == 0) {
      _showAccountPanel();
    }
  }

  void _movePage(int pageIndex) {
    widget.pageController.animateToPage(
      pageIndex,
      duration: $style.times.fast,
      curve: Curves.easeInOut,
    );
  }

  void _setSelected(int index) {
    final selected = context.read<TabBarProvider>().currentIndex;

    if (selected != index) {
      context.read<TabBarProvider>().updateIndex(index);
    }
  }

  void _onActionEvent(UiEvent event) {
    if (!mounted) return;

    if (event is ShowDialogEvent) {
      if (event.type == PanelType.notification) _showNotificationPanel();
    }
  }

  void _showNotificationPanel() {
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
        return NotificationsPanel();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    ).then((_) {
      Provider.of<TabBarProvider>(
        context,
        listen: false,
      ).updateIndex(_itemCount - 2);
    });
  }

  void _showAccountPanel() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AccountPanel();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _onFocusChanged(bool hasFocus) {
    if (hasFocus) {
      final selected =
          Provider.of<TabBarProvider>(context, listen: false).currentIndex;
      if (selected == 0) {
        Provider.of<TabBarProvider>(context, listen: false).updateIndex(1);
      }
    }
    setState(() {
      _hasFocus = hasFocus;
    });
    context.read<BackdropProvider>().isZoomIn = hasFocus;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final selected = context.read<TabBarProvider>().currentIndex;
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _setSelected((selected > 0) ? (selected - 1) : selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        final next = (selected < _itemCount - 1) ? (selected + 1) : selected;
        if (selected == _itemCount - 2) {
          _showNotificationPanel();
        } else {
          _setSelected(next);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (selected == _itemCount - 3) {
          RouterService.instance.safePush(ScreenPaths.action);
        } else if (selected == _itemCount - 2) {
          context.read<SettingMenuProvider>().uri = '/settings';
          RouterService.instance.safePush(ScreenPaths.settings);
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    Provider.of<TabBarProvider>(context, listen: false).setFocusNode(null);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<TabBarProvider>().tabs;
    _itemCount = 0;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onFocusChange: _onFocusChanged,
      onKeyEvent: _onKeyEvent,
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(43, 20, 48, 0),
            child: Row(
              children: [
                createAvatarItem(),
                SizedBox(width: 15),
                for (var tab in tabs) _createTab(tab),
                const Spacer(),
                ...createIcons(),
                Text(
                  'TizenOS',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int getItemNum() {
    return _itemCount++;
  }

  Widget createAvatarItem() {
    final selected = context.read<TabBarProvider>().currentIndex;

    final itemNum = getItemNum();
    final widget = TopMenuAvatarItem(
      imageUrl: null,
      text: "Tizen",
      isSelected: itemNum == selected,
      onPressed: () {
        Focus.of(context).requestFocus();
        _setSelected(itemNum);
      },
    );

    return widget;
  }

  Widget _createTab(String tab) {
    final selected = context.read<TabBarProvider>().currentIndex;
    final itemNum = getItemNum();

    return TopMenuButtonItem(
      text: tab,
      isSelected: itemNum == selected,
      isFocused: _hasFocus,
      onPressed: () {
        Focus.of(context).requestFocus();
        _setSelected(itemNum);
      },
    );
  }

  List<Widget> createIcons() {
    final selected = context.read<TabBarProvider>().currentIndex;
    List<Widget> widgets = [];

    final actionIndex = getItemNum();
    widgets.add(
      TopMenuIconItem(
        icon: Icons.search_outlined,
        isSelected: actionIndex == selected,
        hasFocus: _hasFocus,
        onPressed: () {
          Focus.of(context).requestFocus();
          _setSelected(actionIndex);
          RouterService.instance.safePush(ScreenPaths.action);
        },
      ),
    );
    widgets.add(SizedBox(width: 10));

    final settingsIndex = getItemNum();
    widgets.add(
      TopMenuIconItem(
        icon: Icons.settings_outlined,
        isSelected: settingsIndex == selected,
        hasFocus: _hasFocus,
        onPressed: () {
          Focus.of(context).requestFocus();
          _setSelected(settingsIndex);
          context.read<SettingMenuProvider>().uri = '/settings';
          RouterService.instance.safePush(ScreenPaths.settings);
        },
      ),
    );
    widgets.add(SizedBox(width: 10));

    final notificationIndex = getItemNum();
    widgets.add(
      TopMenuNotification(
        icon: Icons.notifications_none_outlined,
        isSelected: notificationIndex == selected,
        hasFocus: _hasFocus,
        onPressed: () {
          Focus.of(context).requestFocus();
          _setSelected(notificationIndex);
          _showNotificationPanel();
        },
      ),
    );
    widgets.add(SizedBox(width: 10));

    return widgets;
  }
}
