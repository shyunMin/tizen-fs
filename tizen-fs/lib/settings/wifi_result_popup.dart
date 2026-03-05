import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';

class WifiResultPopup extends StatefulWidget {
  const WifiResultPopup({
    super.key,
    required this.ap,
    required this.resultType,
    required this.success,
  });

  final WifiAP ap;
  final String resultType;
  final bool success;

  @override
  State<WifiResultPopup> createState() => _WifiResultPopupState();
}

class _WifiResultPopupState extends State<WifiResultPopup> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
            child: Container(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Container(
                    child: Text(
                      'Wi-Fi',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${widget.ap.essid}',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  if (widget.resultType == 'connect')
                    Container(
                      child: Text(
                        widget.success
                            ? AppLocalizations.of(context).connectedSuccessfully
                            : AppLocalizations.of(context).connectionFailed,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.success ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  if (widget.resultType == 'disconnect')
                    Container(
                      child: Text(
                        widget.success
                            ? AppLocalizations.of(
                              context,
                            ).disconnectedSuccessfully
                            : AppLocalizations.of(context).disconnectionFailed,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.success ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  if (widget.resultType == 'forget')
                    Container(
                      child: Text(
                        widget.success
                            ? AppLocalizations.of(context).forgetSuccessfully
                            : AppLocalizations.of(context).forgetFailed,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.success ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  if (widget.resultType == 'search')
                    Container(
                      child: Text(
                        widget.success
                            ? AppLocalizations.of(context).searchSuccessfully
                            : AppLocalizations.of(context).searchFailed,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.success ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
