import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/settings/ai_configuration_page.dart';

class AdditionalFeatureAIPage extends StatefulWidget {
  final PageNode node;
  final bool isEnabled;

  const AdditionalFeatureAIPage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  @override
  State<AdditionalFeatureAIPage> createState() =>
      _AdditionalFeatureAIPageState();
}

class _AdditionalFeatureAIPageState extends State<AdditionalFeatureAIPage> {
  @override
  Widget build(BuildContext context) {
    return Selector<AdditaionalFeatureProvider, bool>(
      selector:
          (context, provider) => provider.getFeature('ai')?.isEnabled ?? false,
      builder: (context, isAIEnabled, child) {
        // If AI is enabled, return AIConfigurationPage
        if (isAIEnabled) {
          widget.node.isEnd = false;
          return AIConfigurationPage(
            node: widget.node,
            isEnabled: widget.isEnabled,
          );
        }

        // If AI is disabled, return enable message
        final aiEnable = AppLocalizations.of(context).aiEnable;
        final aiEnableMessage = AppLocalizations.of(context).aiEnableMessage;
        widget.node.isEnd = true;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              Spacer(),
              Text('ⓘ $aiEnable', style: TextStyle(fontSize: 14)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(aiEnableMessage, style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        );
      },
    );
  }
}
