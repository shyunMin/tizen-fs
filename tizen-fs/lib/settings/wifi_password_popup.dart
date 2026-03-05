import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/settings/wifi_result_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';

class WifiPasswordPopup extends StatefulWidget {
  const WifiPasswordPopup({
    super.key,
    required this.ap,
    required this.onConnect,
    required this.onDisconnect,
  });

  final WifiAP ap;
  final Function(String password) onConnect;
  final Function() onDisconnect;

  @override
  State<WifiPasswordPopup> createState() => _WifiPasswordPopupState();
}

class _WifiPasswordPopupState extends State<WifiPasswordPopup> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _anonymousController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _identityFocusNode = FocusNode();
  final FocusNode _anonymousFocusNode = FocusNode();
  final FocusNode _connectFocusNode = FocusNode();
  final FocusNode _disconnectFocusNode = FocusNode();
  final FocusNode _forgetFocusNode = FocusNode();
  final FocusNode _cancelFocusNode = FocusNode();
  int _selected = 0;
  bool _showProgress = false;
  Timer? _connectionTimer;
  WifiProvider? _wifiProvider;
  VoidCallback? _connectionListener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _connectionTimer = null;

    if (_wifiProvider != null && _connectionListener != null) {
      _wifiProvider!.removeListener(_connectionListener!);
    }
    _wifiProvider = null;
    _connectionListener = null;

    _passwordController.dispose();
    _identityController.dispose();
    _anonymousController.dispose();
    _passwordFocusNode.dispose();
    _identityFocusNode.dispose();
    _anonymousFocusNode.dispose();
    _connectFocusNode.dispose();
    _disconnectFocusNode.dispose();
    _forgetFocusNode.dispose();
    _cancelFocusNode.dispose();

    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          final maxIndex = _getMaxIndex();
          _selected = (_selected + 1).clamp(0, maxIndex);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          final maxIndex = _getMaxIndex();
          _selected = (_selected - 1).clamp(0, maxIndex);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleEnterKey();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  int _getMaxIndex() {
    if (widget.ap.isEap) {
      return 5;
    } else {
      return 3;
    }
  }

  void _handleEnterKey() {
    final inputFieldCount = widget.ap.isEap ? 3 : 1;
    if (_selected < inputFieldCount) {
    } else if (_selected == inputFieldCount) {
      if (widget.ap.state == 3) {
        _handleDisconnect();
      } else {
        _handleConnect();
      }
    } else if (_selected == inputFieldCount + 1) {
      _handleForget();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _updateFocus() {
    final inputFieldCount = widget.ap.isEap ? 3 : 1;
    if (_selected < inputFieldCount) {
      if (widget.ap.isEap) {
        if (_selected == 0) _identityFocusNode.requestFocus();
        if (_selected == 1) _passwordFocusNode.requestFocus();
        if (_selected == 2) _anonymousFocusNode.requestFocus();
      } else {
        _passwordFocusNode.requestFocus();
      }
    } else if (_selected == inputFieldCount) {
      if (widget.ap.state == 3) {
        _disconnectFocusNode.requestFocus();
      } else {
        _connectFocusNode.requestFocus();
      }
    } else if (_selected == inputFieldCount + 1) {
      _forgetFocusNode.requestFocus();
    } else {
      _cancelFocusNode.requestFocus();
    }
  }

  void _handleConnect() {
    _showProgress = true;

    if (widget.ap.isEap) {
      final eapCredentials =
          '${_identityController.text}:${_passwordController.text}:${_anonymousController.text}';
      widget.onConnect(eapCredentials);
    } else {
      widget.onConnect(_passwordController.text);
    }

    _waitForConnectionResultAndShowPopup('connect');
  }

  void _handleDisconnect() {
    setState(() {
      _showProgress = true;
    });
    widget.onDisconnect();
    _waitForConnectionResultAndShowPopup('disconnect');
  }

  void _handleForget() {
    setState(() {
      _showProgress = true;
    });

    final wifiProvider = Provider.of<WifiProvider>(context, listen: false);
    wifiProvider.forgetNetwork(widget.ap.essid).then((_) {
      _waitForForgetResultAndShowPopup();
    });
  }

  void _waitForForgetResultAndShowPopup() {
    _wifiProvider = Provider.of<WifiProvider>(context, listen: false);

    if (_connectionListener != null) {
      _wifiProvider!.removeListener(_connectionListener!);
    }

    _connectionListener = () {
      if (!mounted) return;

      bool? result = _wifiProvider!.lastForgetResult;
      if (result != null) {
        _wifiProvider!.removeListener(_connectionListener!);
        _connectionListener = null;
        _connectionTimer?.cancel();
        _connectionTimer = null;
        _showResultPopup('forget', result);
      }
    };

    _wifiProvider!.addListener(_connectionListener!);

    _connectionTimer?.cancel();
    _connectionTimer = Timer(Duration(seconds: 5), () {
      if (!mounted) return;

      if (_connectionListener != null) {
        _wifiProvider!.removeListener(_connectionListener!);
        _connectionListener = null;
      }
      _connectionTimer = null;
      _showResultPopup('forget', false);
    });
  }

  void _waitForConnectionResultAndShowPopup(String resultType) {
    _wifiProvider = Provider.of<WifiProvider>(context, listen: false);

    if (_connectionListener != null) {
      _wifiProvider!.removeListener(_connectionListener!);
    }

    _connectionListener = () {
      if (!mounted) return;

      bool? result;
      if (resultType == 'connect') {
        result = _wifiProvider!.lastConnectionResult;
      } else {
        result = _wifiProvider!.lastDisconnectionResult;
      }
      if (result != null) {
        _wifiProvider!.removeListener(_connectionListener!);
        _connectionListener = null;
        _connectionTimer?.cancel();
        _connectionTimer = null;
        _showResultPopup(resultType, result);
      }
    };

    _wifiProvider!.addListener(_connectionListener!);

    _connectionTimer?.cancel();
    _connectionTimer = Timer(Duration(seconds: 5), () {
      if (!mounted) return;

      if (_connectionListener != null) {
        _wifiProvider!.removeListener(_connectionListener!);
        _connectionListener = null;
      }
      _connectionTimer = null;
      _showResultPopup(resultType, false);
    });
  }

  void _showResultPopup(String resultType, bool success) {
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
          ap: widget.ap,
          resultType: resultType,
          success: success,
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

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int selectedIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            _selected == selectedIndex
                ? Colors.white.withAlphaF(0.2)
                : Colors.white.withAlphaF(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              _selected == selectedIndex
                  ? Color(0xF04285F4)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        width: 280,
        height: 45,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onTap: () {
            setState(() {
            _selected = selectedIndex;
            });
          },
          obscureText: hintText == AppLocalizations.of(context).password,
          style: TextStyle(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required FocusNode focusNode,
    required int selectedIndex,
  }) {
    return PopupButton(
      focusNode: focusNode,
      text: text,
      isSelected: _selected == selectedIndex,
      onPressed: () {
        _select(selectedIndex);
        onPressed();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlphaF(0.8),
      body: Stack(
        children: [
          Focus(
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).wifi,
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.ap.essid,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 120, 100, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 10,
                      children: [
                        if (widget.ap.isEap) ...[
                          _buildInputField(
                            hintText: AppLocalizations.of(context).identity,
                            controller: _identityController,
                            focusNode: _identityFocusNode,
                            selectedIndex: 0,
                          ),
                          _buildInputField(
                            hintText: AppLocalizations.of(context).password,
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            selectedIndex: 1,
                          ),
                          _buildInputField(
                            hintText:
                                AppLocalizations.of(context).anonymousIdentity,
                            controller: _anonymousController,
                            focusNode: _anonymousFocusNode,
                            selectedIndex: 2,
                          ),
                        ] else ...[
                          _buildInputField(
                            hintText: AppLocalizations.of(context).password,
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            selectedIndex: 0,
                          ),
                        ],
                        ..._buildButtons(),
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

  List<Widget> _buildButtons() {
    final buttons = <Widget>[];
    int buttonIndex = widget.ap.isEap ? 3 : 1;
    if (widget.ap.state == 3) {
      buttons.add(
        _buildButton(
          text: AppLocalizations.of(context).disconnect,
          onPressed: _handleDisconnect,
          focusNode: _disconnectFocusNode,
          selectedIndex: buttonIndex,
        ),
      );
    } else {
      buttons.add(
        _buildButton(
          text: AppLocalizations.of(context).connect,
          onPressed: _handleConnect,
          focusNode: _connectFocusNode,
          selectedIndex: buttonIndex,
        ),
      );
    }
    buttons.add(
      _buildButton(
        text: AppLocalizations.of(context).forget,
        onPressed: _handleForget,
        focusNode: _forgetFocusNode,
        selectedIndex: buttonIndex + 1,
      ),
    );
    buttons.add(
      _buildButton(
        text: AppLocalizations.of(context).cancel,
        onPressed: () => Navigator.of(context).pop(),
        focusNode: _cancelFocusNode,
        selectedIndex: buttonIndex + 2,
      ),
    );
    return buttons;
  }
}

class PopupButton extends StatelessWidget {
  const PopupButton({
    super.key,
    this.isSelected = false,
    required this.text,
    required this.onPressed,
    this.width = 280,
    this.height = 45,
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
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
