import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/settings/open_source_license_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/setting_list_view.dart';

class AboutDevicePage extends StatefulWidget {
  const AboutDevicePage({
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
  State<AboutDevicePage> createState() => AboutDevicePageState();
}

class AboutDevicePageState extends State<AboutDevicePage> {
  final GlobalKey<SettingListViewState> _listKey =
      GlobalKey<SettingListViewState>();

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
  void didUpdateWidget(covariant AboutDevicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        //title
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
        if (widget.node!.children.isNotEmpty)
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedPadding(
                duration: $style.times.med,
                padding: // item left/right padding
                    widget.isEnabled
                        ? const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        )
                        : const EdgeInsets.symmetric(horizontal: 40),
                child: SettingListView(
                  key: _listKey,
                  node: widget.node!,
                  onItemFocused: (focused) {
                    widget.onFocusChanged?.call(focused);
                  },
                  onItemSelected: (selected) {
                    if (widget.node?.children[selected].id ==
                        "about_device_opensource_license") {
                      _showFullScreenPopup(context, OpenSourceLicensePopup());
                    }
                    widget.onSelectionChanged?.call(selected);
                  },
                  onItemTapped: (selected) {
                    if (widget.node?.children[selected].id ==
                        "about_device_opensource_license") {
                      _showFullScreenPopup(context, OpenSourceLicensePopup());
                    }
                    widget.onSelectionChanged?.call(selected);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenPopup(BuildContext context, Widget widget) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (context, animation, secondaryAnimation) {
        return widget;
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
