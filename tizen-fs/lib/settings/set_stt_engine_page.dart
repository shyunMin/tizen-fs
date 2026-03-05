import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/stt_setting_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

class SetSttEnginePage extends StatefulWidget {
  const SetSttEnginePage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetSttEnginePage> createState() => _SetSttEnginePageState();
}

class _SetSttEnginePageState extends State<SetSttEnginePage>
    with FocusSelectable<SetSttEnginePage> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await context.read<SttSettingProvider>().loadEngineData();
  }

  @override
  void didUpdateWidget(covariant SetSttEnginePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  Future<void> _applySelection(int index) async {
    final engineId = context.read<SttSettingProvider>().getEngineId(index);
    await context.read<SttSettingProvider>().setCurrentEngine(engineId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        // Title
        SizedBox(
          width: widget.isEnabled ? 600 : 400,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding:
                widget.isEnabled
                    ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                    : EdgeInsets.fromLTRB(80, 60, 80, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                getLocalizedTextByKey(
                  context,
                  widget.node?.title ??
                      AppLocalizations.of(context).selectEngine,
                ),
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
              padding:
                  widget.isEnabled
                      ? const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 40),
              child: _buildEngineListContent(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngineListContent(BuildContext context) {
    return Consumer<SttSettingProvider>(
      builder: (context, model, child) {
        if (model.error != null) {
          return Center(
            child: Text(
              'Error: ${model.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (model.engines.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context).noEnginesAvailable),
          );
        }

        final selected = model.currentEngine;

        return SimpleListView(
          key: _listKey,
          items: model.engines,
          selected: model.getEngineIndex(selected?.engineId ?? ''),
          onItemSelected: (index) {
            _applySelection(index);
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
                model.engines[index].engineName,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isFocused
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              subtitle: Text(
                model.engines[index].engineId,
                style: TextStyle(fontSize: 11, color: Color(0xFF979AA0)),
              ),
              trailing: Icon(
                (model.engines[index].engineId == selected?.engineId)
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
    );
  }
}
