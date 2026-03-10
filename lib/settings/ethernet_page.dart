import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/theme/app_theme.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

class EthernetPage extends StatefulWidget {
  const EthernetPage({
    super.key,
    required this.node,
    required this.isEnabled,
    this.onFocusChanged,
    this.onSelectionChanged,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;

  @override
  State<EthernetPage> createState() => _EthernetPageState();
}

class _EthernetPageState extends State<EthernetPage> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(), // Focus node for connect button
  ];

  int _selected = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          initFocus();
        }
      });
    }
  }

  void initFocus() {
    _focusNodes[_selected].requestFocus();
  }

  @override
  void didUpdateWidget(covariant EthernetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }
  
  void _connect() {
    // TODO: [Device API] configure wired network settings with given IP, gateway, subnet, and DNS
    ToastMessage.show(context, AppLocalizations.of(context).applying, const Duration(seconds: 2));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.isEnabled) return KeyEventResult.ignored;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 4);
          _focusNodes[_selected].requestFocus();
        });
        widget.onFocusChanged?.call(_selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 4);
          _focusNodes[_selected].requestFocus();
        });
        widget.onFocusChanged?.call(_selected);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter && _selected == 4) {
         _connect();
         return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _buildField(int index, String label) {
    final isFocused = _selected == index;
    return Container(
      width: 400,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isFocused ? AppTheme.colors.unfocusedBackground : AppTheme.colors.darkBackground,
        borderRadius: AppTheme.dimens.borderRadiusSmall,
        border: Border.all(
          color: isFocused ? AppTheme.colors.focus : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onTap: () {
          setState(() {
            _selected = index;
            _focusNodes[index].requestFocus();
          });
        },
        style: const TextStyle(fontSize: 18, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    final isFocused = _selected == 4;
    return GestureDetector(
      onTap: _connect,
      child: Focus(
        focusNode: _focusNodes[4],
        child: AnimatedScale(
          scale: isFocused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: isFocused ? AppTheme.colors.focus : AppTheme.colors.iconInactive,
              borderRadius: AppTheme.dimens.borderRadiusLarge,
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context).connect,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: widget.isEnabled ? 600 : 400,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: widget.isEnabled
                  ? AppTheme.dimens.pagePaddingLarge
                  : AppTheme.dimens.pagePaddingNormal,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  getLocalizedTextByKey(context, widget.node?.title ?? ''),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: widget.isEnabled
                    ? EdgeInsets.symmetric(horizontal: AppTheme.dimens.paddingHorizontalLarge, vertical: 10)
                    : EdgeInsets.symmetric(horizontal: AppTheme.dimens.paddingHorizontalNormal),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(0, AppLocalizations.of(context).ipAddress),
                      _buildField(1, AppLocalizations.of(context).subnetMask),
                      _buildField(2, AppLocalizations.of(context).gateway),
                      _buildField(3, AppLocalizations.of(context).dns),
                      const SizedBox(height: 20),
                      _buildConnectButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
