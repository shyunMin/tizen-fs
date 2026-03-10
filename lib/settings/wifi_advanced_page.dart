import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/settings/find_hidden_wifi_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/wifi_advanced_list_view.dart';

class WifiAdvancedPage extends StatefulWidget {
  const WifiAdvancedPage({
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
  State<WifiAdvancedPage> createState() => WifiAdvancedPageState();
}

class WifiAdvancedPageState extends State<WifiAdvancedPage> {
  final GlobalKey<WifiAdvancedListViewState> _listKey =
      GlobalKey<WifiAdvancedListViewState>();

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
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(covariant WifiAdvancedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  void _handleFocusChanged(int index) {
    widget.onFocusChanged?.call(index);
  }

  void _handleSelectionChanged(int index) {
    if (index == 0) {
      _showFindHiddenWifiPopup();
    }
    widget.onSelectionChanged?.call(index);
  }

  void _showFindHiddenWifiPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return const FindHiddenWifiPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        // title
        SizedBox(
          width: widget.isEnabled ? 600 : 400,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding: // title up/left padding
                widget.isEnabled
                    ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                    : EdgeInsets.fromLTRB(80, 60, 80, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                getLocalizedTextByKey(context, widget.node?.title ?? ''),
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 2,
                style: TextStyle(fontSize: 35),
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding: // item left/right padding
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 40),
              child: WifiAdvancedListView(
                key: _listKey,
                isEnabled: widget.isEnabled,
                onFocusChanged: _handleFocusChanged,
                onSelectionChanged: _handleSelectionChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
