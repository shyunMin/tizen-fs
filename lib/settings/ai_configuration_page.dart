import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/ai/ai_config_provider.dart';
import 'package:tizen_fs/settings/set_config_file_path_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/items_view.dart';

class AIConfigurationPage extends StatefulWidget {
  final PageNode node;
  final bool isEnabled;

  const AIConfigurationPage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  @override
  State<AIConfigurationPage> createState() => AIConfigurationPageState();
}

class AIConfigurationPageState extends State<AIConfigurationPage> {
  final GlobalKey<ItemsViewState> _listKey = GlobalKey<ItemsViewState>();
  AIConfigProvider? _aiConfigProvider;

  @override
  void initState() {
    super.initState();
    _aiConfigProvider = Provider.of<AIConfigProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && _aiConfigProvider != null) {
        await _aiConfigProvider!.loadConfiguration();
        if (widget.isEnabled) {
          initFocus();
        }
      }
    });
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(covariant AIConfigurationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  void dispose() {
    _aiConfigProvider = null;
    super.dispose();
  }

  void _showConfigFilePathPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Close",
      barrierColor: Colors.transparent,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return const SetConfigFilePathPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        //title
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
                getLocalizedTextByKey(context, widget.node.title),
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
              child: Consumer<AIConfigProvider>(
                builder: (context, provider, child) {
                  return ItemsView<AIConfigProperty>(
                    key: _listKey,
                    items: provider.properties,
                    onItemFocused: (focused) {},
                    onItemSelected: (selected) => _selectItem(selected),
                    onAction: (selected) => _selectItem(selected),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectItem(int selected) {
    if (selected == 4) {
      // Check if configFilePath item (index 4) is selected
      _showConfigFilePathPopup();
    }
  }
}
