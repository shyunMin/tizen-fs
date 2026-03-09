import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/toast_message.dart';
import 'package:tizen_fs/providers/network_status_provider.dart';
import 'package:provider/provider.dart';

class EthernetPage extends StatefulWidget {
  const EthernetPage({
    super.key,
    required this.node,
    required this.isEnabled,
    this.onFocusChanged,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onFocusChanged;

  @override
  State<EthernetPage> createState() => _EthernetPageState();
}

class _EthernetPageState extends State<EthernetPage>
    with FocusSelectable<EthernetPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _subnetController = TextEditingController();
  final TextEditingController _gatewayController = TextEditingController();
  final TextEditingController _dnsController = TextEditingController();

  final FocusNode _ipFocusNode = FocusNode();
  final FocusNode _subnetFocusNode = FocusNode();
  final FocusNode _gatewayFocusNode = FocusNode();
  final FocusNode _dnsFocusNode = FocusNode();
  final FocusNode _saveFocusNode = FocusNode();

  int _selected = 0;
  bool _showProgress = false;

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

    // Load initial values from NetworkStatusProvider if possible
    final provider = Provider.of<NetworkStatusProvider>(context, listen: false);
    _ipController.text = provider.ipAddress;
    _subnetController.text = provider.subnetMask;
    _gatewayController.text = provider.gateway;
    // Tizen connection manager may not expose DNS via NetworkStatusProvider as currently written
    // If there is no dns property, leave it blank or load empty string
  }

  @override
  void dispose() {
    _ipController.dispose();
    _subnetController.dispose();
    _gatewayController.dispose();
    _dnsController.dispose();
    _ipFocusNode.dispose();
    _subnetFocusNode.dispose();
    _gatewayFocusNode.dispose();
    _dnsFocusNode.dispose();
    _saveFocusNode.dispose();
    super.dispose();
  }

  void initFocus() {
    _ipFocusNode.requestFocus();
    _selected = 0;
  }

  @override
  void didUpdateWidget(covariant EthernetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      initFocus();
    }
  }

  @override
  LogicalKeyboardKey getNextKey() => LogicalKeyboardKey.arrowDown;

  @override
  LogicalKeyboardKey getPrevKey() => LogicalKeyboardKey.arrowUp;

  @override
  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 4);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 4);
          _updateFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selected == 4) {
          _handleSave();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void _updateFocus() {
    switch (_selected) {
      case 0:
        _ipFocusNode.requestFocus();
        widget.onFocusChanged?.call(0);
        break;
      case 1:
        _subnetFocusNode.requestFocus();
        widget.onFocusChanged?.call(1);
        break;
      case 2:
        _gatewayFocusNode.requestFocus();
        widget.onFocusChanged?.call(2);
        break;
      case 3:
        _dnsFocusNode.requestFocus();
        widget.onFocusChanged?.call(3);
        break;
      case 4:
        _saveFocusNode.requestFocus();
        widget.onFocusChanged?.call(4);
        break;
    }
  }

  void _handleSave() {
    setState(() {
      _showProgress = true;
    });

    final ip = _ipController.text.trim();
    // final subnet = _subnetController.text.trim();
    // final gateway = _gatewayController.text.trim();
    // final dns = _dnsController.text.trim();

    // Mock delay for applying settings (or replace with actual Tizen API call)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showProgress = false;
        });
        ToastMessage.show(
          context,
          '${AppLocalizations.of(context).save} IP: $ip',
          const Duration(seconds: 2),
        );
      }
    });
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    FocusNode node,
    int index,
  ) {
    final isSelected = _selected == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white.withAlphaF(0.2)
                  : Colors.white.withAlphaF(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: node,
                onTap: () {
                  setState(() {
                    _selected = index;
                  });
                },
                style: const TextStyle(fontSize: 18, color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final isSelected = _selected == 4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Focus(
        focusNode: _saveFocusNode,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selected = 4;
            });
            _handleSave();
          },
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).save,
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.isEnabled ? 600 : 400,
              child: AnimatedPadding(
                duration: $style.times.med,
                padding:
                    widget.isEnabled
                        ? const EdgeInsets.fromLTRB(120, 60, 40, 20)
                        : const EdgeInsets.fromLTRB(80, 60, 80, 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getLocalizedTextByKey(
                      context,
                      widget.node?.title ?? 'ethernet',
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 35),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedPadding(
                duration: $style.times.med,
                padding:
                    widget.isEnabled
                        ? const EdgeInsets.symmetric(horizontal: 100)
                        : const EdgeInsets.symmetric(horizontal: 40),
                child: Focus(
                  focusNode: focusNode,
                  canRequestFocus: false,
                  child: ListView(
                    children: [
                      _buildTextField(
                        AppLocalizations.of(context).ipAddress,
                        _ipController,
                        _ipFocusNode,
                        0,
                      ),
                      _buildTextField(
                        AppLocalizations.of(context).subnetMask,
                        _subnetController,
                        _subnetFocusNode,
                        1,
                      ),
                      _buildTextField(
                        AppLocalizations.of(context).gateway,
                        _gatewayController,
                        _gatewayFocusNode,
                        2,
                      ),
                      _buildTextField(
                        AppLocalizations.of(context).dns,
                        _dnsController,
                        _dnsFocusNode,
                        3,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSaveButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showProgress)
          Container(
            color: Colors.black.withAlphaF(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
