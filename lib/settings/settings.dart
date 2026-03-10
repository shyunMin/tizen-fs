import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/models/settings_menus.dart';
import 'package:tizen_fs/providers/setting_menu_provider.dart';
import 'package:tizen_fs/router_service.dart';
import 'package:tizen_fs/settings/setting_page_interface.dart';
import 'package:tizen_fs/settings/setting_page.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/extensions.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final FocusNode _focusNode = FocusNode();
  late final PageController _pageController;
  late PageNode _pageTree;

  late List<PageNode?> _pages;
  List<GlobalKey> _itemKeys = List.generate(3, (_) => GlobalKey());

  int _current = 0;
  double viewportFraction = 0.585;

  void move(int position) {
    if (_current == position) return;

    if (position > _current) {
      var targetPage = _pages[position];
      if (targetPage!.isEnd) {
        return;
      }
    }

    setState(() {
      _current = position;
    });

    _pageController.animateToPage(
      position,
      duration: $style.times.med,
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: viewportFraction,
      keepPage: false,
    );
    _pages = [null, null];
    _pageTree = SettingPages().getRoot();

    final uri = context.read<SettingMenuProvider>().uri;
    _pages[0] = _pageTree.find(uri);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        move((_current < _pages.length - 2) ? _current + 1 : _current);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        move((_current > 0) ? _current - 1 : _current);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
          event.physicalKey == PhysicalKeyboardKey.escape) {
        if (_current == 0) return KeyEventResult.ignored;
        move((_current > 0) ? _current - 1 : _current);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _selectTo(int index) {
    if (index == _pages.length - 1) return;

    move(index);
  }

  void _updatePages(PageNode? node, int selected) {
    _addNewPage(node, selected);
  }

  void _addNewPage(PageNode? node, int selected) {
    if (node == null) return;

    if (node.children.isEmpty ||
        selected < 0 ||
        selected >= node.children.length) {
      return;
    }

    if (_current + 1 >= _itemKeys.length) {
      return;
    }

    final state = _itemKeys[_current + 1].currentState;
    if (state is SettingPageInterface) {
      (state as SettingPageInterface).hidePage();
    }

    var current = _current;
    List newItems = [];

    final newItem = node.children.elementAt(selected);
    newItems = [newItem];
    final List newKeys = List.generate(1, (_) => GlobalKey());

    newItems.add(null);
    newKeys.add(GlobalKey());

    setState(() {
      if (current + 1 <= _pages.length) {
        _itemKeys = [..._itemKeys.sublist(0, current + 1), ...newKeys];
        _pages = [..._pages.sublist(0, current + 1), ...newItems];
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_current == 0) RouterService.instance.safePop();
        move((_current > 0) ? _current - 1 : _current);
      },
      child: Scaffold(
        body: Focus(
          focusNode: _focusNode,
          onKeyEvent: _onKeyEvent,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            scrollDirection: Axis.horizontal,
            itemCount: _pages.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (_pages[index] == null) {
                return Container(
                  color: Theme.of(context).colorScheme.onTertiary,
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    _selectTo(index);
                  },
                  child: SettingPage(
                    key: _itemKeys[index],
                    node: _pages[index]!,
                    isEnabled: index <= _current,
                    onRequestPageUpdate: (focused) {
                      _updatePages(_pages[index], focused);
                    },
                    onRequestPageMove: (selected) {
                      Future.microtask(() {
                        _selectTo(index + 1);
                      });
                    },
                    onRequestGoBack: (index) {
                      move(index);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
