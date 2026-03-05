import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/items_view.dart';

enum AppListType { installed, running, all }

class AppsPage extends StatefulWidget {
  const AppsPage({
    super.key,
    required this.node,
    required this.listType,
    required this.isEnabled,
    required this.onSelectionChanged,
    required this.onItemFocused,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final AppListType listType;
  final bool isEnabled;
  final Function(int)? onSelectionChanged;
  final Function(int)? onItemFocused;
  final Function(int)? onRequestGoBack;

  @override
  State<AppsPage> createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> {
  GlobalKey<ItemsViewState> _listKey = GlobalKey<ItemsViewState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (mounted) {
      await context.read<AppDataModel>().loadPackageInfos();

      if (!mounted) return;
      await context.read<AppDataModel>().loadAppSize();

      if (!mounted) return;
      await context.read<AppDataModel>().loadRunningApps();
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
  void didUpdateWidget(AppsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleFontSize = 35;

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        SizedBox(
          // height: titleHeight,
          width: 400,
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
              child: Selector<AppDataModel, List<AppData>>(
                selector: _getSelector,
                builder: (context, apps, child) {
                  if (apps.length < 1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Text(AppLocalizations.of(context).noApp),
                    );
                  }
                  return ItemsView<AppData>(
                    key: _listKey,
                    items: apps,
                    onListChanged: () {
                      widget.onRequestGoBack?.call(1);
                    },
                    onItemFocused: (focused) {
                      context.read<AppDataModel>().selectedApp = apps[focused];
                      widget.onItemFocused?.call(0);
                    },
                    onItemSelected: (selected) {
                      context.read<AppDataModel>().selectedApp = apps[selected];
                      widget.onSelectionChanged?.call(0);
                    },
                    onAction: (index) {
                      context.read<AppDataModel>().selectedApp = apps[index];
                      widget.onSelectionChanged?.call(0);
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
  List<AppData> _getSelector(BuildContext context, AppDataModel model) {
    if (widget.listType == AppListType.installed) {
      return model.installedApps;
    } else if (widget.listType == AppListType.running) {
      return model.runningApps;
    } else {
      return model.allApps;
    }
  }
}
