import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/models/immersive_carosel_model.dart';
import 'package:tizen_fs/providers/backdrop_provider.dart';
import 'package:tizen_fs/providers/tapbar_provider.dart';
import 'package:tizen_fs/screen/home_page.dart';
import 'package:tizen_fs/live/live_screen.dart';
import 'package:tizen_fs/media/media_page.dart';
import 'package:tizen_fs/styles/app_style.dart';

class MainContentView extends StatefulWidget {
  const MainContentView({
    super.key,
    required this.pageController,
    required this.scrollController,
    required this.register,
    required this.unregister,
  });

  final PageController pageController;
  final ScrollController scrollController;
  final void Function(int, Function(ScrollDirection, bool)) register;
  final void Function(int) unregister;

  @override
  State<MainContentView> createState() => _MainContentViewState();
}

class _MainContentViewState extends State<MainContentView> {
  late final PageController _controller;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.pageController;
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? _controller.initialPage.toDouble();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final backdrop = context.read<ImmersiveCarouselModel>().backdrop;
        context.read<BackdropProvider>().url = backdrop;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<TabBarProvider>().tabs;

    return ExpandablePageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: _onPageChanged,
      children: [..._buildTabPages(tabs)],
    );
  }

  List<Widget> _buildTabPages(List<String> tabs) {
    List<Widget> tabPages = [];
    int index = 0;

    for (var tab in tabs) {
      switch (tab) {
        case "home":
          tabPages.add(
            _buildFadingPage(
              index: index,
              child: HomePage(
                scrollController: widget.scrollController,
                register: widget.register,
                unregister: widget.unregister,
              ),
            ),
          );
          break;
        case "media":
          tabPages.add(_buildFadingPage(index: index, child: MediaPage()));
          break;
        case "live":
          tabPages.add(_buildFadingPage(index: index, child: LiveScreen()));
          break;
        default:
          tabPages.add(_buildFadingPage(index: index, child: Container()));
      }
      index++;
    }

    return tabPages;
  }

  Widget _buildFadingPage({required int index, required Widget child}) {
    double opacity = 1.0 - min((_currentPage - index).abs(), 1.0);

    return AnimatedOpacity(
      duration: $style.times.fast,
      opacity: opacity,
      child: child,
    );
  }

  void _onPageChanged(int page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (page == 0) {
          final backdrop =
              context
                  .read<ImmersiveCarouselModel>()
                  .getSelectedContent()
                  .backdrop;
          context.read<BackdropProvider>().url = backdrop;
        } else {
          context.read<BackdropProvider>().url = '';
        }
      }
    });
  }
}
