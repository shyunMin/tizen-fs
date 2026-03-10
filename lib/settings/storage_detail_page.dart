import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/models/storage_model.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/items_view.dart';

enum StorageListType { internal, external }

class StorageDetailPage extends StatefulWidget {
  const StorageDetailPage({
    super.key,
    required this.node,
    required this.listType,
    required this.isEnabled,
    required this.onSelectionChanged,
    required this.onItemFocused,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final StorageListType listType;
  final bool isEnabled;
  final Function(int)? onSelectionChanged;
  final Function(int)? onItemFocused;
  final Function(int)? onRequestGoBack;

  @override
  State<StorageDetailPage> createState() => StorageDetailPageState();
}

class StorageDetailPageState extends State<StorageDetailPage> {
  GlobalKey<ItemsViewState> _listKey = GlobalKey<ItemsViewState>();

  @override
  void initState() {
    super.initState();

    context.read<StorageDataModel>().initStorages();
    _loadData();
  }

  void _loadData() async {
    await context.read<StorageDataModel>().loadStorage();

    if (mounted) {
      await context.read<StorageDataModel>().loadAppSize();
    }

    if (mounted) {
      await context.read<StorageDataModel>().loadMediaSize();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(StorageDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleFontSize = 35;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(fontSize: titleFontSize),
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
              child: Selector<StorageDataModel, List<StorageData>>(
                selector: _getSelector,
                builder: (context, Storages, child) {
                  return ItemsView<StorageData>(
                    key: _listKey,
                    items: Storages,
                    onListChanged: () {
                      // widget.onRequestGoBack?.call(1);
                    },
                    onItemFocused: (focused) {
                      // context.read<StorageDataModel>().selectedStorage =
                      //     Storages[focused];
                      // widget.onItemFocused?.call(0);
                    },
                    onItemSelected: (selected) {
                      // context.read<StorageDataModel>().selectedStorage =
                      //     Storages[selected];
                      // widget.onSelectionChanged?.call(0);
                    },
                    onAction: (index) {
                      // context.read<StorageDataModel>().selectedStorage =
                      //     Storages[index];
                      // widget.onSelectionChanged?.call(0);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @protected
  List<StorageData> _getSelector(BuildContext context, StorageDataModel model) {
    if (widget.listType == StorageListType.internal) {
      return model.internal;
    } else if (widget.listType == StorageListType.external) {
      return model.external;
    }
    return [];
  }
}
