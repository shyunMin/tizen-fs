import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

class AdditonalFeaturePage extends StatefulWidget {
  const AdditonalFeaturePage({
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
  State<AdditonalFeaturePage> createState() => AdditonalFeaturePageState();
}

class AdditonalFeaturePageState extends State<AdditonalFeaturePage> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

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
  void didUpdateWidget(covariant AdditonalFeaturePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = context.read<AdditaionalFeatureProvider>().features;

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
              child: SimpleListView(
                key: _listKey,
                items: features,
                onItemFocused: (focused) {
                  widget.onFocusChanged?.call(focused);
                },
                onItemSelected: (selected) {
                  features[selected].toggle();
                },
                itemBuilder: (context, index, isFocused) {
                  return ListTile(
                    minTileHeight: 65,
                    onTap: () {
                      _listKey.currentState?.selectTo(index);
                    },
                    title: Text(
                      getLocalizedTextByKey(context, features[index].name),
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            isFocused
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(
                                  context,
                                ).textTheme.titleMedium?.color,
                      ),
                    ),
                    trailing: ChangeNotifierProvider<FeatureData>.value(
                      value: features[index],
                      child: Consumer<FeatureData>(
                        builder: (context, model, _) {
                          return Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(useMaterial3: false),
                            child: Switch(
                              value: model.isEnabled,
                              activeThumbColor: Colors.blue,
                              onChanged: (value) {
                                _listKey.currentState?.selectTo(index);
                                features[index].toggle();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
