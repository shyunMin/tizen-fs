import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/providers/network_status_provider.dart';

class NetworkStatusPage extends StatefulWidget {
  final PageNode node;
  final bool isEnabled;

  const NetworkStatusPage({
    super.key,
    required this.node,
    required this.isEnabled,
  });

  @override
  State<NetworkStatusPage> createState() => NetworkStatusPageState();
}

class NetworkStatusPageState extends State<NetworkStatusPage> {
  @override
  void initState() {
    super.initState();
    // Defer the heavy lifting until after the first frame to keep UI snappy
    Future.microtask(() {
      if (mounted) {
        context.read<NetworkStatusProvider>().loadNetworkStatus();
      }
    });
  }

  Widget createKeyValue(String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: Color(0xFF979AA0)),
        ),
      ],
    );
  }

  String _getNetworkTypeText(BuildContext context, NetworkType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case NetworkType.wifi:
        return l10n.wifi;
      case NetworkType.ethernet:
        return l10n.ethernet;
      case NetworkType.none:
        return l10n.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padding =
        widget.isEnabled
            ? const EdgeInsets.fromLTRB(120, 60, 0, 0)
            : const EdgeInsets.fromLTRB(80, 60, 0, 0);

    return Consumer<NetworkStatusProvider>(
      builder: (context, provider, _) {
        // Shared header
        final List<Widget> children = [
          Text(l10n.networkStatus, style: const TextStyle(fontSize: 35)),
          const SizedBox(height: 5),
        ];

        if (provider.isLoading) {
          children.addAll([
            createKeyValue(l10n.ipAddress, l10n.loading),
            createKeyValue(l10n.subnetMask, l10n.loading),
            createKeyValue(l10n.gateway, l10n.loading),
            createKeyValue(l10n.networkType, l10n.loading),
            createKeyValue(l10n.connectionStatus, l10n.loading),
          ]);
        } else if (provider.error != null) {
          children.addAll([
            Text(
              l10n.errorLoadingNetworkStatus,
              style: const TextStyle(color: Colors.red),
            ),
            Text(provider.error!, style: const TextStyle(fontSize: 10)),
          ]);
        } else {
          children.addAll([
            createKeyValue(
              l10n.ipAddress,
              provider.ipAddress.isEmpty ? l10n.unknown : provider.ipAddress,
            ),
            createKeyValue(
              l10n.subnetMask,
              provider.subnetMask.isEmpty ? l10n.unknown : provider.subnetMask,
            ),
            createKeyValue(
              l10n.gateway,
              provider.gateway.isEmpty ? l10n.unknown : provider.gateway,
            ),
            createKeyValue(
              l10n.networkType,
              _getNetworkTypeText(context, provider.networkType),
            ),
            createKeyValue(
              l10n.connectionStatus,
              provider.isConnected ? l10n.connected : l10n.disconnected,
            ),
          ]);
        }

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                children
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: w,
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
