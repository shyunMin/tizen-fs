import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/date_time_list_view.dart';

class DateTimePage extends StatefulWidget {
  const DateTimePage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onFocusChanged,
    required this.onSelectionChanged,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onFocusChanged;
  final Function(int)? onSelectionChanged;
  final Function(int)? onRequestGoBack;

  @override
  State<DateTimePage> createState() => DateTimePageState();
}

class DateTimePageState extends State<DateTimePage> {
  GlobalKey<DateTimeListViewState> _listKey =
      GlobalKey<DateTimeListViewState>();

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
  void didUpdateWidget(covariant DateTimePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
      setState(() {});
    }
  }

  void _handleFocusChanged(int index) {
    widget.onFocusChanged?.call(index);
  }

  void _handleSelectionChanged(int index) {
    widget.onSelectionChanged?.call(index);
  }

  void _handleGoBack(int index) {
    widget.onRequestGoBack?.call(index);
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
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding: // item left/right padding
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 40),
              child: DateTimeListView(
                key: _listKey,
                node: widget.node,
                onFocusChanged: _handleFocusChanged,
                onSelectionChanged: _handleSelectionChanged,
                onRequestGoBack: _handleGoBack,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
