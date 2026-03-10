import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/settings/wifi_password_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';

class WifiListView extends StatefulWidget {
  const WifiListView({
    super.key,
    required this.isEnabled,
    this.onFocusChanged,
    this.onSelectionChanged,
  });

  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;

  @override
  State<WifiListView> createState() => WifiListViewState();
}

class WifiListViewState extends State<WifiListView>
    with FocusSelectable<WifiListView> {
  int _selected = 0;

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

  void _showWifiPasswordPopup(WifiAP ap) {
    final wifiProvider = Provider.of<WifiProvider>(context, listen: false);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Theme.of(context).colorScheme.onPrimary,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return WifiPasswordPopup(
          ap: ap,
          onConnect: (password) async {
            await wifiProvider.connectToAp(ap.essid, password: password);
          },
          onDisconnect: () async {
            await wifiProvider.disconnectAp(ap);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        final wifiProvider = Provider.of<WifiProvider>(context, listen: false);
        if (_selected == 0) {
          if (wifiProvider.isSupported) {
            if (wifiProvider.isConnecting ||
                wifiProvider.isDisconnecting ||
                wifiProvider.isActivating ||
                wifiProvider.isDeactivating) {
            } else if (wifiProvider.isActivated) {
              wifiProvider.wifiOff();
            } else {
              wifiProvider.wifiOn();
            }
          }
        } else if (_selected == 1 && wifiProvider.isActivated) {
          _handleSelectionChanged();
        } else if (_selected > 1 && wifiProvider.isActivated) {
          final apIndex = _selected - 2;
          if (apIndex < wifiProvider.apList.length) {
            final selectedAp = wifiProvider.apList[apIndex];
            _showWifiPasswordPopup(selectedAp);
          }
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleSelectionChanged() {
    debugPrint("_handleSelectionChanged [${_selected}]");
    if (_selected == 1) widget.onSelectionChanged?.call(1);
  }

  void _handleFocusChanged() {
    debugPrint("_handleFocusChanged [${_selected}]");
    if (_selected == 1)
      widget.onFocusChanged?.call(1);
    else
      widget.onFocusChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WifiProvider>(
      builder: (context, wifiProvider, child) {
        if (wifiProvider.isActivated &&
            !wifiProvider.isActivating &&
            !wifiProvider.isDeactivating &&
            !wifiProvider.isScanning &&
            wifiProvider.apList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            wifiProvider.scanAndRefresh();
          });
        }
        final itemCount =
            1 +
            (wifiProvider.isActivated ? 1 : 0) +
            (wifiProvider.isActivated ? wifiProvider.apList.length : 0);
        return Focus(
          focusNode: focusNode,
          onFocusChange: (hasfocus) {
            if (hasfocus) {
              listKey.currentState?.selectTo(_selected);
            } else {
              _selected = listKey.currentState?.selectedIndex ?? 0;
            }
          },
          child: SelectableListView(
            scrollOffset: 260,
            key: listKey,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: 0.5,
            itemCount: itemCount,
            scrollDirection: Axis.vertical,
            onItemFocused: (selected) {
              _selected = selected;
              _handleFocusChanged();
            },
            itemBuilder: (context, index, selectedIndex, key) {
              return AnimatedScale(
                key: key,
                scale:
                    Focus.of(context).hasFocus && index == selectedIndex
                        ? 1.0
                        : .9,
                duration: $style.times.med,
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () {
                    listKey.currentState?.selectTo(index);
                    Focus.of(context).requestFocus();
                    if (index == 1 && wifiProvider.isActivated) {
                      _handleSelectionChanged();
                    } else if (index > 1 && wifiProvider.isActivated) {
                      final apIndex = index - 2;
                      if (apIndex < wifiProvider.apList.length) {
                        final selectedAp = wifiProvider.apList[apIndex];
                        _showWifiPasswordPopup(selectedAp);
                      }
                    }
                  },
                  child:
                      index == 0
                          ? WifiSwitchItem(
                            isFocused:
                                Focus.of(context).hasFocus &&
                                index == selectedIndex,
                            isEnabled: widget.isEnabled,
                            wifiProvider: wifiProvider,
                          )
                          : index == 1 && wifiProvider.isActivated
                          ? WifiAdvancedItem(
                            isFocused:
                                Focus.of(context).hasFocus &&
                                index == selectedIndex,
                            isEnabled: widget.isEnabled,
                          )
                          : WifiApItem(
                            isFocused:
                                Focus.of(context).hasFocus &&
                                index == selectedIndex,
                            isEnabled: widget.isEnabled,
                            wifiProvider: wifiProvider,
                            apIndex: index - 2,
                          ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class WifiSwitchItem extends StatelessWidget {
  const WifiSwitchItem({
    super.key,
    required this.isFocused,
    required this.isEnabled,
    required this.wifiProvider,
  });

  final bool isFocused;
  final bool isEnabled;
  final WifiProvider wifiProvider;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  String _getWifiStatusText(BuildContext context) {
    if (wifiProvider.isPluginInstalled == false) {
      return AppLocalizations.of(context).failedToEnableWifi;
    } else if (!wifiProvider.isSupported) {
      return AppLocalizations.of(context).notSupported;
    } else if (wifiProvider.isActivating) {
      return AppLocalizations.of(context).activating;
    } else if (wifiProvider.isDeactivating) {
      return AppLocalizations.of(context).deactivating;
    } else if (wifiProvider.isActivated) {
      return AppLocalizations.of(context).on;
    } else {
      return AppLocalizations.of(context).off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isFocused
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).wifi,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color:
                            isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      _getWifiStatusText(context),
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color:
                            isFocused
                                ? Theme.of(
                                  context,
                                ).colorScheme.onTertiary.withAlphaF(0.8)
                                : Theme.of(
                                  context,
                                ).colorScheme.tertiary.withAlphaF(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (wifiProvider.isSupported)
                if (wifiProvider.isConnecting ||
                    wifiProvider.isDisconnecting ||
                    wifiProvider.isActivating ||
                    wifiProvider.isDeactivating)
                  Padding(
                    padding:
                        isFocused
                            ? const EdgeInsets.only(right: 35)
                            : const EdgeInsets.only(right: 20),
                    child: Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xF04285F4),
                      ),
                    ),
                  )
                else
                  Theme(
                    data: Theme.of(context).copyWith(useMaterial3: false),
                    child: Padding(
                      padding:
                          isFocused
                              ? const EdgeInsets.only(right: 15)
                              : const EdgeInsets.only(right: 0),
                      child: Switch(
                        value: wifiProvider.isActivated,
                        onChanged: (value) async {
                          if (value) {
                            await wifiProvider.wifiOn();
                          } else {
                            await wifiProvider.wifiOff();
                          }
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class WifiApItem extends StatelessWidget {
  const WifiApItem({
    super.key,
    required this.isFocused,
    required this.isEnabled,
    required this.wifiProvider,
    required this.apIndex,
  });

  final bool isFocused;
  final bool isEnabled;
  final WifiProvider wifiProvider;
  final int apIndex;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    if (apIndex >= wifiProvider.apList.length) {
      return SizedBox.shrink();
    }

    final ap = wifiProvider.apList[apIndex];
    final isConnectedToThisAp = wifiProvider.connectedAp?.essid == ap.essid;

    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isFocused
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isFocused
                          ? Color(0xF04285F4).withAlphaF(0.2)
                          : Color(0xF0263041),
                ),
                child: Icon(
                  _getWifiIcon(ap.rssi),
                  size: iconSize,
                  color: isFocused ? Color(0xF04285F4) : Color(0xF0AEB2B9),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ap.essid,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color:
                            isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      _getApStateText(ap, context),
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color:
                            isFocused
                                ? Theme.of(
                                  context,
                                ).colorScheme.onTertiary.withAlphaF(0.8)
                                : Theme.of(
                                  context,
                                ).colorScheme.tertiary.withAlphaF(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnectedToThisAp)
                Padding(
                  padding:
                      isFocused
                          ? const EdgeInsets.only(right: 30)
                          : const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.check,
                    size: iconSize,
                    color: isFocused ? Color(0xF04285F4) : Color(0xF0AEB2B9),
                  ),
                )
              else if (wifiProvider.isConnecting ||
                  wifiProvider.isDisconnecting ||
                  wifiProvider.isScanning ||
                  wifiProvider.isActivating ||
                  wifiProvider.isDeactivating)
                Padding(
                  padding:
                      isFocused
                          ? const EdgeInsets.only(right: 35)
                          : const EdgeInsets.only(right: 20),
                  child: Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xF04285F4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getApStateText(WifiAP ap, BuildContext context) {
    final isConnectedToThisAp = wifiProvider.connectedAp?.handle == ap.handle;
    if (wifiProvider.isConnecting) {
      return AppLocalizations.of(context).connecting;
    } else if (wifiProvider.isDisconnecting && isConnectedToThisAp) {
      return AppLocalizations.of(context).disconnecting;
    } else if (isConnectedToThisAp || ap.state == 1) {
      return AppLocalizations.of(context).connected;
    } else if (ap.state == 2) {
      return AppLocalizations.of(context).authenticationFailed;
    } else if (ap.state == 3) {
      return AppLocalizations.of(context).associationFailed;
    } else {
      return AppLocalizations.of(context).available;
    }
  }

  IconData _getWifiIcon(int rssi) {
    if (rssi > -40) {
      return Icons.wifi;
    } else if (rssi > -60) {
      return Icons.wifi_2_bar;
    } else {
      return Icons.wifi_1_bar;
    }
  }
}

class WifiAdvancedItem extends StatelessWidget {
  const WifiAdvancedItem({
    super.key,
    required this.isFocused,
    required this.isEnabled,
  });

  final bool isFocused;
  final bool isEnabled;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double innerPadding = 20;
  final double itemHeight = 65;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isFocused
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).advanced,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color:
                            isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
