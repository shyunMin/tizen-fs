import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/focus_selectable.dart';
import 'package:tizen_fs/providers/tts_setting_provider.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

class SetTtsVoicePage extends StatefulWidget {
  const SetTtsVoicePage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetTtsVoicePage> createState() => _SetTtsVoicePageState();
}

class _SetTtsVoicePageState extends State<SetTtsVoicePage>
    with FocusSelectable<SetTtsVoicePage> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await context.read<TtsSettingProvider>().loadVoiceData();
  }

  @override
  void didUpdateWidget(covariant SetTtsVoicePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  Future<void> _applySelection(int index) async {
    final voice = context.read<TtsSettingProvider>().getVoice(index);
    await context.read<TtsSettingProvider>().setCurrentVoice(voice);
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
                      AppLocalizations.of(context).selectVoice,
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
              child: _buildVoiceListContent(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceListContent(BuildContext context) {
    return Consumer<TtsSettingProvider>(
      builder: (context, model, child) {
        if (model.voices.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context).noVoicesAvailable),
          );
        }

        final selected = model.currentVoice;
        final selectedIndex = model.getVoiceIndex(selected);

        return SimpleListView(
          key: _listKey,
          items: model.voices,
          selected: selectedIndex,
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
                getLocalizedTextByKey(context, model.voices[index].voiceId),
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isFocused
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              trailing: Icon(
                (model.voices[index].voiceId == selected.voiceId)
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
