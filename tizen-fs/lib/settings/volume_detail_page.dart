import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_audio_manager/tizen_audio_manager.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/providers/volume_provider.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

class VolumeDetailPage extends StatefulWidget {
  const VolumeDetailPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onRequestGoBack,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onRequestGoBack;

  @override
  State<VolumeDetailPage> createState() => _VolumeDetailPageState();
}

class _VolumeDetailPageState extends State<VolumeDetailPage> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

  late final AudioVolumeType _type;
  late final int _maxLevel;
  late final List<String> _levels;

  @override
  void initState() {
    super.initState();

    _type = context.read<VolumeProvider>().audioType;
    _maxLevel = context.read<VolumeProvider>().getMaxLevel(_type);
    _levels = List.generate(_maxLevel + 1, (i) => (i).toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VolumeDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  Future<void> _applySelection(int index) async {
    await context.read<VolumeProvider>().setLevel(_type, index);
  }

  @override
  Widget build(BuildContext context) {
    double titleFontSize = 35;

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        AnimatedContainer(
          width: widget.isEnabled ? 600 : 400,
          duration: $style.times.med,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding: // title up/left padding
                widget.isEnabled
                    ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                    : EdgeInsets.fromLTRB(80, 60, 80, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                getLocalizedTextByKey(
                  context,
                  context.read<VolumeProvider>().getText(_type),
                ),
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
              padding:
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
              child: ChangeNotifierProvider<VolumeData>.value(
                value: context.read<VolumeProvider>().getVolumeData(_type),
                child: Consumer<VolumeData>(
                  builder: (context, model, _) {
                    return SimpleListView(
                      key: _listKey,
                      items: _levels,
                      selected: model.level,
                      onItemSelected: (selected) {
                        _applySelection(selected);
                      },
                      itemBuilder: (context, index, isFocused) {
                        return ListTile(
                          minTileHeight: 65,
                          onTap: () {
                            _listKey.currentState?.selectTo(index);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _applySelection(index);
                            });
                          },
                          title: Text(
                            _levels[index],
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
                          trailing: Icon(
                            (index == model.level)
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                isFocused
                                    ? Theme.of(context).colorScheme.onTertiary
                                    : Theme.of(context).colorScheme.tertiary,
                            size: 20,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
