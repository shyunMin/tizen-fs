import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/providers/locale_provider.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

class SetLanguagePage extends StatefulWidget {
  const SetLanguagePage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  final PageNode? node;
  final bool isEnabled;

  @override
  State<SetLanguagePage> createState() => _SetLanguagePageState();
}

class _SetLanguagePageState extends State<SetLanguagePage> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    context.read<LocaleProvider>().loadLanguages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SetLanguagePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  void _setLanguage(int index) {
    var locale = context.read<LocaleProvider>().getLocale(index);
    if (locale.isNotEmpty) {
      context.read<LocaleProvider>().setSystemLocale(
        locale,
        onComplete: _onLanguageSetComplete,
      );
    }
  }

  void _onLanguageSetComplete(bool success) {
    if (mounted) {
      if (success) {
        ToastMessage.show(
          context,
          AppLocalizations.of(context).languageChangedSuccessfully,
          const Duration(seconds: 2),
        );
        Navigator.pop(context);
      } else {
        ToastMessage.show(
          context,
          AppLocalizations.of(context).languageChangeFailed,
          const Duration(seconds: 2),
        );
      }
    }
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
                      AppLocalizations.of(context).setLanguage,
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
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Consumer<LocaleProvider>(
      builder: (context, model, child) {
        if (model.availableLanguages.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context).noLanguagesAvailable),
          );
        }

        final selected = model.getCurrentLocale();
        final selectedIndex = model.getCurrentLocaleIndex();

        return SimpleListView(
          key: _listKey,
          items: model.availableLanguages,
          selected: selectedIndex,
          onItemSelected: (index) {
            _setLanguage(index);
          },
          itemBuilder: (context, index, isFocused) {
            return ListTile(
              minTileHeight: 65,
              onTap: () {
                _listKey.currentState?.selectTo(index);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // _applySelection(index);
                });
              },
              title: Text(
                getLocalizedTextByKey(
                  context,
                  model.availableLanguages[index].locale,
                ),
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isFocused
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              trailing: Icon(
                (model.availableLanguages[index].getLocale() == selected)
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
