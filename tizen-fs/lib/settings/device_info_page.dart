import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/device_info_provider.dart';
import 'package:tizen_fs/settings/rename_device_popup.dart';
import 'package:tizen_fs/widgets/items_view.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onFocusChanged,
    required this.onSelectionChanged,
  });

  final PageNode node;
  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;

  @override
  State<DeviceInfoPage> createState() => DeviceInfoPageState();
}

class DeviceInfoPageState extends State<DeviceInfoPage> {
  final GlobalKey<ItemsViewState> _listKey = GlobalKey<ItemsViewState>();
  DeviceInfoProvider? _deviceInfoProvider;

  @override
  void initState() {
    super.initState();
    _deviceInfoProvider = Provider.of<DeviceInfoProvider>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && _deviceInfoProvider != null) {
        await _deviceInfoProvider!.loadDeviceInfo();
        if (widget.isEnabled) {
          initFocus();
        }
      }
    });
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(covariant DeviceInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  void dispose() {
    _deviceInfoProvider = null;
    super.dispose();
  }

  void _showRenameDevicePopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return const RenameDevicePopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return Consumer<DeviceInfoProvider>(
      builder: (context, deviceInfoProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            // Title
            SizedBox(
              width: widget.isEnabled ? 600 : 400,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding:
                    widget.isEnabled
                        ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                        : EdgeInsets.fromLTRB(80, 60, 80, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getLocalizedTextByKey(context, widget.node.title),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: TextStyle(fontSize: 35),
                  ),
                ),
              ),
            ),
            // ItemsView for device info
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      widget.isEnabled
                          ? const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 10,
                          )
                          : const EdgeInsets.symmetric(horizontal: 40),
                  child: ItemsView<DeviceInfoItem>(
                    key: _listKey,
                    items: deviceInfoProvider.deviceInfoItems,
                    onItemFocused: (focused) {
                      widget.onFocusChanged?.call(0);
                    },
                    onItemSelected: (selected) => _showRenameDevicePopup(),
                    onAction: (selected) => _showRenameDevicePopup(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
