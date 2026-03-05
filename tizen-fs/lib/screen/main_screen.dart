import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/native/action_manager.dart';
import 'package:tizen_fs/native/app_manager.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/ui_event.dart';
import 'package:tizen_fs/widgets/backdrop_scaffold.dart';
import 'package:tizen_fs/widgets/toast_message.dart';
import 'main_top_menu.dart';
import 'main_content_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(child: const MainContent());
  }
}

class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<MainTopMenuState> _tabbarKey = GlobalKey<MainTopMenuState>();

  final Map<int, Function(ScrollDirection, bool)> _childCallbacks = {};

  double _lastPixel = 0;
  double _scrollOffset = 0;
  ScrollDirection _scrollDirection = ScrollDirection.idle;
  StreamSubscription? _subscription;

  final taskbarAppId = 'org.tizen.systemui';
  final actionService = 'org.tizen.action-framework.service';

  @override
  void initState() {
    super.initState();

    _subscription = ActionManager.eventStream.listen(_onActionEvent);
    ApplicationManager.addAppControlCallback(_onAppControlReceived);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (_scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(_scrollOffset);
          });
        }
        break;
      case AppLifecycleState.inactive:
        if (_scrollController.hasClients) {
          _scrollOffset = _scrollController.offset;
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ApplicationManager.removeAppControlCallback(_onAppControlReceived);
    _subscription?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAppLaunching = context.watch<AppDataModel>().isAppLaunching;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if ((event.logicalKey == LogicalKeyboardKey.backspace) ||
              (event.physicalKey == PhysicalKeyboardKey.escape)) {
            _goFirstTab();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            if (notification is ScrollUpdateNotification) {
              final currentPixel = notification.metrics.pixels;
              if (currentPixel > _lastPixel) {
                _scrollDirection = ScrollDirection.reverse;
              } else if (currentPixel < _lastPixel) {
                _scrollDirection = ScrollDirection.forward;
              } else {
                _scrollDirection = ScrollDirection.idle;
              }
              _lastPixel = currentPixel;
            }

            if (notification is ScrollEndNotification) {
              if (_scrollDirection != ScrollDirection.idle) {
                _notifyChildren(_scrollDirection, true);
              }
            }
            return true;
          } else {
            return false;
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            _goFirstTab();
          },
          child: Stack(
            children: [
              CustomScrollView(
                scrollBehavior: ScrollBehavior().copyWith(
                  scrollbars: false,
                  overscroll: false,
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                  },
                ),
                controller: _scrollController,
                primary: false,
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    floating: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 80,
                    backgroundColor: Colors.transparent,
                    title: MainTopMenu(
                      key: _tabbarKey,
                      pageController: _pageController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: MainContentView(
                      pageController: _pageController,
                      scrollController: _scrollController,
                      register: registerChild,
                      unregister: unregisterChild,
                    ),
                  ),
                ],
              ),
              if (isAppLaunching) Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  void _onAppControlReceived(
    String caller,
    Map<String, dynamic> extraData,
  ) async {
    if (caller == taskbarAppId) {
      RouterService.instance.safePopUntil(context, (router) => router.isFirst);
      _goFirstTab();
    } else if (caller == actionService) {
      await ActionManager.runAction(extraData);
    }
  }

  void _onActionEvent(UiEvent event) {
    if (!mounted) return;

    if (event is ShowToastMessageEvent) {
      ToastMessage.show(
        context,
        getLocalizedTextByKey(context, event.message),
        Duration(milliseconds: 1500),
      );
    }
  }

  void registerChild(int index, Function(ScrollDirection, bool) callback) {
    _childCallbacks[index] = callback;
  }

  void unregisterChild(int index) {
    _childCallbacks.remove(index);
  }

  void _notifyChildren(ScrollDirection direction, bool scrollEnd) {
    for (var callback in _childCallbacks.values) {
      callback(direction, scrollEnd);
    }
  }

  Future<void> _goFirstTab() async {
    try {
      final currentIndex =
          Provider.of<TabBarProvider>(context, listen: false).currentIndex;

      if (currentIndex == 1) {
        await _scrollController.animateTo(
          0,
          duration: $style.times.fast,
          curve: Curves.easeIn,
        );
        _tabbarKey.currentState?.requestFocus();
      } else {
        Provider.of<TabBarProvider>(context, listen: false).updateIndex(1);
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
}
