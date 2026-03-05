import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/widgets/video_player_view.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/providers/backdrop_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/apps/app_list.dart';
import 'package:tizen_fs/widgets/immersive_carousel.dart';
import 'package:tizen_fs/models/immersive_carosel_model.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

enum HomePageState { none, headerFocused, carouselFocused, appListFocused }

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.scrollController,
    required this.register,
    required this.unregister,
  });

  final ScrollController scrollController;
  final void Function(int, Function(ScrollDirection, bool)) register;
  final void Function(int) unregister;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ImmersiveAreaState> _carouselKey =
      GlobalKey<ImmersiveAreaState>();
  final GlobalKey<AppListState> _applistKey = GlobalKey<AppListState>();
  final GlobalKey<FooterState> _footerKey = GlobalKey<FooterState>();

  final _pageState = ValueNotifier(HomePageState.headerFocused);

  @override
  void initState() {
    super.initState();

    widget.register(0, _onScrolEnd);
  }

  @override
  void dispose() {
    widget.unregister(0);
    super.dispose();
  }

  Future<void> _setState(HomePageState state) async {
    if (state == HomePageState.headerFocused) {
      Future.microtask(() async {
        _carouselKey.currentState?.collapse();
        _carouselKey.currentState?.restartAutoScroll();
        if (mounted) {
          Provider.of<TabBarProvider>(context, listen: false).requestFocus();
        }
        await widget.scrollController.animateTo(
          0,
          duration: $style.times.med,
          curve: Curves.easeOutCubic,
        );
        _footerKey.currentState?.show();
      });
      _pageState.value = HomePageState.headerFocused;
    } else if (state == HomePageState.carouselFocused) {
      _carouselKey.currentState?.restartAutoScroll();
      _footerKey.currentState?.show();
      _carouselKey.currentState?.requestFocus();
      Future.microtask(() async {
        _carouselKey.currentState?.expand();
        await widget.scrollController.animateTo(
          0,
          duration: $style.times.med,
          curve: Curves.easeOutCubic,
        );
      });
      _pageState.value = HomePageState.carouselFocused;
    } else if (state == HomePageState.appListFocused) {
      _carouselKey.currentState?.stopAutoScroll();
      Future.microtask(() async {
        _carouselKey.currentState?.collapse();
        await widget.scrollController.animateTo(
          360,
          duration: $style.times.med,
          curve: Curves.easeOutCubic,
        );
        _footerKey.currentState?.hide();
        _applistKey.currentState?.requestFocus();
      });
      _pageState.value = HomePageState.appListFocused;
    }
  }

  void _onScrolEnd(ScrollDirection direction, bool scrollEnd) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final offset =
        devicePixelRatio > 1
            ? widget.scrollController.offset
            : widget.scrollController.offset / devicePixelRatio;

    if (direction == ScrollDirection.reverse) {
      if (_pageState.value == HomePageState.headerFocused ||
          _pageState.value == HomePageState.carouselFocused) {
        if (offset < 70) {
          _setState(HomePageState.headerFocused);
        } else {
          _setState(HomePageState.appListFocused);
        }
      }
      if (_pageState.value == HomePageState.appListFocused) {
        if (offset < 360) {
          _setState(HomePageState.appListFocused);
        } else {
          //scroll free
        }
      }
    } else if (direction == ScrollDirection.forward) {
      if (_pageState.value == HomePageState.appListFocused) {
        if (offset < 300) {
          _setState(HomePageState.headerFocused);
        } else if (offset <= 500) {
          _setState(HomePageState.appListFocused);
        } else {
          //scroll free
        }
      } else if (_pageState.value == HomePageState.carouselFocused) {
        _setState(HomePageState.carouselFocused);
      } else if (_pageState.value == HomePageState.headerFocused) {
        _setState(HomePageState.headerFocused);
      }
    }
  }

  HomePageState _getNextState(HomePageState state) {
    switch (state) {
      case HomePageState.headerFocused:
        return HomePageState.carouselFocused;
      case HomePageState.carouselFocused:
        return HomePageState.appListFocused;
      case HomePageState.appListFocused:
        return HomePageState.none;
      default:
        return HomePageState.none;
    }
  }

  HomePageState _getPrevState(HomePageState state) {
    switch (state) {
      case HomePageState.appListFocused:
        return HomePageState.carouselFocused;
      case HomePageState.carouselFocused:
        return HomePageState.headerFocused;
      case HomePageState.headerFocused:
        return HomePageState.none;
      default:
        return HomePageState.none;
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final currentState = _pageState.value;
        if ((currentState == HomePageState.carouselFocused) &&
            context.read<AppDataModel>().displayedApps.isEmpty) {
          return KeyEventResult.handled;
        }
        final state = _getNextState(_pageState.value);
        _setState(state);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final state = _getPrevState(_pageState.value);
        _setState(state);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: Column(
        children: [
          ImmersiveArea(
            key: _carouselKey,
            onFocusChanged: (focus) {
              if (focus) {
                _setState(HomePageState.carouselFocused);
              } else {
                _carouselKey.currentState?.collapse();
              }
            },
          ),
          if (Provider.of<AppDataModel>(
            context,
            listen: false,
          ).displayedApps.isNotEmpty)
            AppList(
              key: _applistKey,
              scrollController: widget.scrollController,
              onFocusChanged: (focus) {
                if (focus) _setState(HomePageState.appListFocused);
              },
              onScrollup: () => _setState(HomePageState.headerFocused),
            ),
          if (Provider.of<AppDataModel>(
            context,
            listen: false,
          ).displayedApps.isNotEmpty)
            Footer(
              key: _footerKey,
              onTap: () {
                _applistKey.currentState?.requestFocus();
              },
            ),
        ],
      ),
    );
  }
}

class Footer extends StatefulWidget {
  const Footer({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<Footer> createState() => FooterState();
}

class FooterState extends State<Footer> {
  bool _isVisible = true;
  bool get isVisible => _isVisible;

  void show() {
    setState(() {
      _isVisible = true;
    });
  }

  void hide() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _isVisible ? 150 : 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Icon(Icons.keyboard_arrow_down, size: 30),
        ),
      ),
    );
  }
}

class ImmersiveArea extends StatefulWidget {
  const ImmersiveArea({super.key, this.onFocusChanged});

  final Function(bool)? onFocusChanged;

  @override
  State<ImmersiveArea> createState() => ImmersiveAreaState();
}

class ImmersiveAreaState extends State<ImmersiveArea>
    with SingleTickerProviderStateMixin {
  final _carouselKey = GlobalKey<ImmersiveCarouselState>();
  late final AnimationController _animationController;
  late final Animation<double> _heightAnimation;
  late final FocusNode _focusNode;

  bool _isExpanded = false;
  bool _isfocused = false;

  bool get hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: $style.times.fast,
    );

    _heightAnimation = Tween<double>(begin: 280, end: 350).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void stopAutoScroll() {
    _stopRepeating();
    context.read<BackdropProvider>().url = '';
    _carouselKey.currentState?.stopAutoScroll();
  }

  void restartAutoScroll() {
    _stopRepeating();
    _carouselKey.currentState?.resetAutoScroll();
    _carouselKey.currentState?.updateBackdrop();
  }

  void requestFocus() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  void expand() {
    setState(() {
      _isExpanded = true;
      _isfocused = true;
    });
    _animationController.forward();
  }

  void collapse() {
    setState(() {
      _isExpanded = false;
      _isfocused = false;
    });
    _animationController.reverse();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      onFocusChange: (hasFocus) {
        widget.onFocusChanged?.call(hasFocus);
      },
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! > 0) {
                  _carouselKey.currentState?.moveCarousel(-1);
                } else {
                  _carouselKey.currentState?.moveCarousel(1);
                }
              }
            },
            child: SizedBox(
              height: _heightAnimation.value,
              child: ImmersiveCarousel(
                key: _carouselKey,
                isExpanded: _isExpanded,
                isFocused: _isfocused,
                onTap: () {
                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                },
                onButtonPressed: () {
                  _openContent();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _stopRepeating() {
    _initialDelayTimer?.cancel();
    _repeatingTimer?.cancel();
    _initialDelayTimer = null;
    _repeatingTimer = null;
  }

  Timer? _initialDelayTimer;
  Timer? _repeatingTimer;
  void _startRepeating(VoidCallback action) {
    action();
    _initialDelayTimer?.cancel();
    _initialDelayTimer = Timer(const Duration(milliseconds: 300), () {
      _repeatingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        action();
      });
    });
  }

  Future<void> _openContent() async {
    final url =
        Provider.of<ImmersiveCarouselModel>(
          context,
          listen: false,
        ).getSelectedContent().url;

    if (url.isEmpty) return;

    final localizations = AppLocalizations.of(context);

    final title =
        Provider.of<ImmersiveCarouselModel>(
          context,
          listen: false,
        ).getSelectedContent().title;

    final isLocal = url.startsWith('/');

    if (isLocal) {
      try {
        final file = File(url);
        final isExists = await file.exists();

        if (isExists) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerView(title: title, url: url),
            ),
          );
        } else {
          _showSnackBar(localizations.fileDoesNotExist);
        }
      } catch (e) {
        debugPrint('$e');
      }
    } else {
      _showSnackBar(localizations.canNotOpenFile);
    }
  }

  void _showSnackBar(String message) {
    ToastMessage.show(context, message, const Duration(seconds: 1));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        _startRepeating(() {
          _carouselKey.currentState?.moveCarousel(1);
        });

        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _startRepeating(() {
          _carouselKey.currentState?.moveCarousel(-1);
        });

        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _openContent();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.tab ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _stopRepeating();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }
}
