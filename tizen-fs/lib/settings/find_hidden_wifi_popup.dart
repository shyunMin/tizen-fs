import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/settings/wifi_result_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';

class FindHiddenWifiPopup extends StatefulWidget {
  const FindHiddenWifiPopup({super.key});

  @override
  State<FindHiddenWifiPopup> createState() => _FindHiddenWifiPopupState();
}

class _FindHiddenWifiPopupState extends State<FindHiddenWifiPopup> {
  final TextEditingController _ssidController = TextEditingController();
  final FocusNode _ssidFocusNode = FocusNode();
  final FocusNode _findFocusNode = FocusNode();
  final FocusNode _cancelFocusNode = FocusNode();
  int _selected = 0;
  bool _showProgress = false;
  Timer? _scanTimer;
  WifiProvider? _wifiProvider;
  VoidCallback? _scanListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanTimer = null;

    if (_wifiProvider != null && _scanListener != null) {
      _wifiProvider!.removeListener(_scanListener!);
    }
    _wifiProvider = null;
    _scanListener = null;

    _ssidController.dispose();
    _ssidFocusNode.dispose();
    _findFocusNode.dispose();
    _cancelFocusNode.dispose();

    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 2);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 2);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selected == 0) {
          _ssidFocusNode.requestFocus();
        } else if (_selected == 1) {
          _handleFind();
        } else if (_selected == 2) {
          Navigator.of(context).pop();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _updateFocus() {
    switch (_selected) {
      case 0:
        _ssidFocusNode.requestFocus();
        break;
      case 1:
        _findFocusNode.requestFocus();
        break;
      case 2:
        _cancelFocusNode.requestFocus();
        break;
    }
  }

  void _handleFind() {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      _showErrorPopup(AppLocalizations.of(context).enterNetworkName);
      return;
    }

    _showProgress = true;
    _wifiProvider = Provider.of<WifiProvider>(context, listen: false);

    _wifiProvider!.scanSpecificAP(ssid);
    _waitForScanResultAndShowPopup(ssid);
  }

  void _waitForScanResultAndShowPopup(String ssid) {
    if (_scanListener != null) {
      _wifiProvider!.removeListener(_scanListener!);
    }

    _scanListener = () {
      if (!mounted) return;

      if (!_wifiProvider!.isScanning) {
        _wifiProvider!.removeListener(_scanListener!);
        _scanListener = null;
        _scanTimer?.cancel();
        _scanTimer = null;
        _showProgress = false;
        final foundAp =
            _wifiProvider!.specificApList.isNotEmpty
                ? _wifiProvider!.specificApList.first
                : null;
        if (foundAp != null) {
          _showSearchResultPopup(foundAp, true);
        } else {
          _showSearchResultPopup(null, false);
        }
      }
    };

    _wifiProvider!.addListener(_scanListener!);

    _scanTimer?.cancel();
    _scanTimer = Timer(Duration(seconds: 10), () {
      if (!mounted) return;
      if (_scanListener != null) {
        _wifiProvider!.removeListener(_scanListener!);
        _scanListener = null;
      }
      _scanTimer = null;
      _showProgress = false;
      _showErrorPopup(AppLocalizations.of(context).hiddenNetworkScanError);
    });
  }

  void _showSearchResultPopup(WifiAP? ap, bool success) {
    if (!mounted) return;

    _showProgress = false;
    Navigator.of(context).pop();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return WifiResultPopup(
          ap:
              ap ??
              WifiAP(
                handle: nullptr,
                essid: _ssidController.text.trim(),
                state: 0,
                frequency: 0,
                rssi: 0,
              ),
          resultType: 'search',
          success: success,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _showErrorPopup(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).ok),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _select(int index) {
    setState(() {
      _selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Focus(
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Container(
                          child: Text(
                            AppLocalizations.of(context).wifi,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            AppLocalizations.of(context).findHiddenNetwork,
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 120, 100, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 20,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                _selected == 0
                                    ? Colors.white.withAlphaF(0.2)
                                    : Colors.white.withAlphaF(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _selected == 0
                                      ? Color(0xF04285F4)
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 280,
                            height: 50,
                            child: TextField(
                              controller: _ssidController,
                              focusNode: _ssidFocusNode,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                                hintText:
                                    AppLocalizations.of(context).networkSSID,
                                hintStyle: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        PopupButton(
                          focusNode: _findFocusNode,
                          text: AppLocalizations.of(context).search,
                          isSelected: _selected == 1,
                          onPressed: () {
                            _select(1);
                            _handleFind();
                          },
                        ),
                        PopupButton(
                          focusNode: _cancelFocusNode,
                          text: AppLocalizations.of(context).cancel,
                          isSelected: _selected == 2,
                          onPressed: () {
                            _select(2);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showProgress)
            Container(
              color: Colors.black.withAlphaF(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    this.isSelected = false,
    required this.text,
    required this.onPressed,
    this.width = 280,
    this.height = 50,
    this.focusNode,
  });

  final bool isSelected;
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          height: height,
          child: AnimatedScale(
            scale: isSelected ? 1.1 : 1,
            duration: const Duration(milliseconds: 80),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
