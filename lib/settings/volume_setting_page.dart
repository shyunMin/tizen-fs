import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/volume_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/items_view.dart';

class VolumeSettingPage extends StatefulWidget {
  const VolumeSettingPage({
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
  State<VolumeSettingPage> createState() => _VolumeSettingPageState();
}

class _VolumeSettingPageState extends State<VolumeSettingPage> {
  final GlobalKey<ItemsViewState> _listKey = GlobalKey<ItemsViewState>();

  final double _titleFontSize = 35;
  List<VolumeData> _volumes = [];

  @override
  void initState() {
    super.initState();
    _volumes = context.read<VolumeProvider>().volumes;

    _init();
  }

  Future<void> _init() async {
    await context.read<VolumeProvider>().loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(covariant VolumeSettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        SizedBox(
          width: 400,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding:
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
                style: TextStyle(fontSize: _titleFontSize),
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedPadding(
              duration: $style.times.med,
              padding:
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 40),
              child: ItemsView<VolumeData>(
                key: _listKey,
                items: _volumes,
                onItemFocused: (index) {
                  context.read<VolumeProvider>().audioType =
                      _volumes[index].type;
                  widget.onFocusChanged?.call(0);
                },
                onItemSelected: (index) {
                  widget.onSelectionChanged?.call(0);
                },
                onAction: (index) {
                  widget.onSelectionChanged?.call(0);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
