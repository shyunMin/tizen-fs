import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/widgets/app_popup.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/native/app_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/app_tile.dart';
import 'package:tizen_fs/widgets/media_card.dart';
import 'package:tizen_fs/widgets/selectable_gridview.dart';

class AppList extends StatefulWidget {
  const AppList({
    super.key,
    this.onFocusChanged,
    this.onScrollup,
    this.scrollController,
  });

  final Function(bool)? onFocusChanged;
  final VoidCallback? onScrollup;
  final ScrollController? scrollController;

  @override
  State<AppList> createState() => AppListState();
}

class AppListState extends State<AppList> {
  final GlobalKey<SelectableGridViewState> _gridKey =
      GlobalKey<SelectableGridViewState>();

  final double _itemWidth = 150;
  final double _itemRatio = 16 / 11;
  final double _width = 960;

  final double _minimumHeight = 130;
  final double _vPadding = 10;
  final double _hPadding = 58;

  bool _isOpen = false;
  bool _isPopupOpened = false;
  int _itemCount = 0;
  double get itemHeight => _itemWidth / _itemRatio + 30;
  int get columnCount => (_width < 152) ? 1 : (_width - 116) ~/ 162;
  int get rowCount =>
      (_itemCount % columnCount) > 0
          ? (_itemCount ~/ columnCount) + 1
          : _itemCount ~/ columnCount;

  double _scrollOffset = 0;

  List<AppData> apps = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    apps = context.watch<AppDataModel>().displayedApps;
    final appListOrder =
        Provider.of<AppDataModel>(context, listen: false).order;

    _itemCount = apps.length;
    double height = (itemHeight + 30) * rowCount;
    height =
        height < MediaQuery.of(context).size.height
            ? MediaQuery.of(context).size.height
            : height;

    return SizedBox(
      height: _isOpen ? height : _minimumHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          SizedBox(
            height: _isOpen ? 120 : 25,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isOpen)
                    SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: widget.onScrollup,
                            child: Icon(Icons.keyboard_arrow_up, size: 30),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    AppLocalizations.of(context).yourApps,
                    style: TextStyle(fontSize: _isOpen ? 30 : 15),
                  ),
                  if (_isOpen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 35,
                          child: ElevatedButton(
                            autofocus: false,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              if (appListOrder == SortOrder.asc) {
                                Provider.of<AppDataModel>(
                                      context,
                                      listen: false,
                                    ).order =
                                    SortOrder.desc;
                              } else {
                                Provider.of<AppDataModel>(
                                      context,
                                      listen: false,
                                    ).order =
                                    SortOrder.asc;
                              }
                              Provider.of<AppDataModel>(
                                context,
                                listen: false,
                              ).updateDisplayedList();
                            },
                            child: Row(
                              children: [
                                Icon(
                                  appListOrder == SortOrder.asc
                                      ? Icons.south_rounded
                                      : Icons.north_rounded,
                                  size: 20,
                                ),
                                Icon(Icons.sort_by_alpha_sharp, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SelectableGridView(
              key: _gridKey,
              scrollController: widget.scrollController!,
              padding: EdgeInsets.symmetric(
                horizontal: _hPadding,
                vertical: _isOpen ? _vPadding : _vPadding,
              ),
              initialOffset: 360,
              itemCount:
                  _isOpen
                      ? apps.length
                      : apps.length < 5
                      ? apps.length
                      : 5,
              itemRatio: _itemRatio,
              onFocused: () {
                setState(() {
                  _isOpen = true;
                });
                widget.onFocusChanged?.call(true);
              },
              onUnfocused: () {
                if (!_isPopupOpened) {
                  setState(() {
                    _isOpen = false;
                  });
                  widget.onFocusChanged?.call(false);
                }
              },
              onItemSelected: (selected) async {
                await Provider.of<AppDataModel>(
                  context,
                  listen: false,
                ).launchApp(apps[selected].appId);
              },
              onItemLongPressed: (selected) {
                _showFullScreenPopup(context, apps[selected]);
              },
              itemBuilder: (context, index, selectedIndex, key) {
                return Center(
                  child: GestureDetector(
                    onLongPress:
                        () => _showFullScreenPopup(context, apps[index]),
                    child: MediaCard(
                      key: key,
                      width: _itemWidth,
                      imageUrl: '',
                      title: apps[index].name,
                      shadowColor: getAppColor(apps[index]),
                      content: AppTile(app: apps[index]),
                      isSelected:
                          Focus.of(context).hasFocus && index == selectedIndex,
                      onRequestSelect: () {
                        _gridKey.currentState?.selectTo(index);
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await Provider.of<AppDataModel>(
                            context,
                            listen: false,
                          ).launchApp(apps[index].appId);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color getAppColor(AppData app) {
    if (app.appType.toLowerCase().contains('dotnet')) {
      return $style.colors.dotnetApp;
    } else if (app.appType.toLowerCase().contains('capp')) {
      return $style.colors.cApp;
    } else if (app.appType.toLowerCase().contains('webapp')) {
      return $style.colors.webApp;
    }
    return $style.colors.defaulApp;
  }

  void requestFocus() {
    _gridKey.currentState?.requestFocus();
  }

  void _removeApp(AppData app) {
    ApplicationManager.uninstallPackage(app.packageId);
  }

  void _showFullScreenPopup(BuildContext context, AppData app) {
    _scrollOffset = widget.scrollController?.offset ?? 0;
    setState(() {
      _isPopupOpened = true;
    });
    showGeneralDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (context, animation, secondaryAnimation) {
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
    ).then((_) {
      setState(() {
        _isPopupOpened = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController?.jumpTo(_scrollOffset);
      });
    });
  }
}
