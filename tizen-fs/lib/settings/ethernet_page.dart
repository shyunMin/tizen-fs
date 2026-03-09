import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/native/ethernet_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';

class EthernetPage extends StatefulWidget {
  const EthernetPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onFocusChanged,
    required this.onSelectionChanged,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;

  @override
  State<EthernetPage> createState() => EthernetPageState();
}

class EthernetPageState extends State<EthernetPage> {
  final EthernetManager _ethernetManager = EthernetManagerImpl();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
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
    if (_focusNodes.isNotEmpty && widget.isEnabled) {
      _focusNodes[_selected].requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant EthernetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
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

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.isEnabled) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selected = (_selected + 1).clamp(0, 4);
          _focusNodes[_selected].requestFocus();
          widget.onFocusChanged?.call(_selected);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selected = (_selected - 1).clamp(0, 4);
          _focusNodes[_selected].requestFocus();
          widget.onFocusChanged?.call(_selected);
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
          _selected == 4) {
        widget.onSelectionChanged?.call(_selected);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _buildTextField(int index, String labelKey) {
    final bool isSelected = _selected == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLocalizedTextByKey(context, labelKey),
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected && widget.isEnabled
                        ? const Color(0xF04285F4)
                        : Colors.transparent,
                width: 2,
              ),
            ),
            width: 400,
            height: 50,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                hintText: getLocalizedTextByKey(context, labelKey),
                hintStyle: const TextStyle(color: Colors.white30),
              ),
              onTap: () {
                if (!widget.isEnabled) return;
                setState(() {
                  _selected = index;
                  _focusNodes[index].requestFocus();
                  widget.onFocusChanged?.call(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton() {
    final bool isSelected = _selected == 4;
    return GestureDetector(
      onTap: () async {
        if (!widget.isEnabled) return;
        setState(() {
          _selected = 4;
          widget.onSelectionChanged?.call(4);
        });

        final ip = _controllers[0].text;
        final subnet = _controllers[1].text;
        final gw = _controllers[2].text;
        final dns = _controllers[3].text;

        final success = await _ethernetManager.connectWithStaticIp(
          ipAddress: ip,
          subnetMask: subnet,
          gateway: gw,
          dns: dns,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Wired Network Connected (Mock)'
                    : 'Connection Failed',
              ),
            ),
          );
        }
      },
      child: Focus(
        focusNode: _focusNodes[4],
        child: AnimatedScale(
          scale: isSelected && widget.isEnabled ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color:
                  isSelected && widget.isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            alignment: Alignment.center,
            child: Text(
              getLocalizedTextByKey(context, 'connect'),
              style: TextStyle(
                fontSize: 16,
                color:
                    isSelected && widget.isEnabled
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
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
      autofocus: widget.isEnabled,
      onKeyEvent: _onKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          SizedBox(
            width: widget.isEnabled ? 600 : 400,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding:
                  widget.isEnabled
                      ? const EdgeInsets.fromLTRB(120, 60, 40, 0)
                      : const EdgeInsets.fromLTRB(80, 60, 80, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  getLocalizedTextByKey(
                    context,
                    widget.node?.title ?? 'ethernet',
                  ),
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedPadding(
                duration: $style.times.med,
                padding:
                    widget.isEnabled
                        ? const EdgeInsets.fromLTRB(120, 40, 80, 10)
                        : const EdgeInsets.fromLTRB(80, 40, 40, 10),
                child: AbsorbPointer(
                  absorbing: !widget.isEnabled,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(0, 'ipAddress'),
                        _buildTextField(1, 'subnetMask'),
                        _buildTextField(2, 'gateway'),
                        _buildTextField(3, 'dns'),
                        const SizedBox(height: 20),
                        _buildConnectButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
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
