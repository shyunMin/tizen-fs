import 'package:flutter/material.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';

class ProfileActivePage extends StatelessWidget {
  final PageNode node;
  final bool isEnabled;

  const ProfileActivePage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final profileActive = AppLocalizations.of(context).pofileActive;
    final profileActiveMessage =
        AppLocalizations.of(context).pofileActiveMessage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          Spacer(),
          Text('ⓘ $profileActive', style: TextStyle(fontSize: 14)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(profileActiveMessage, style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
