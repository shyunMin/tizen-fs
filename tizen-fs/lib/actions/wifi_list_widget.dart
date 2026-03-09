import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/settings/wifi_password_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

// ignore: must_be_immutable
class WifiListWidget extends StatefulWidget {
  WifiListWidget({super.key, this.keyword});

  String? keyword;

  @override
  State<WifiListWidget> createState() => WifiListWidgetState();
}

class WifiListWidgetState extends State<WifiListWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<WifiProvider>(context, listen: false).init();
    Provider.of<WifiProvider>(context, listen: false).scanAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    List<WifiAP> aps = context.watch<WifiProvider>().apList;

    if (widget.key != null) {
      aps = aps.where((ap) => ap.essid.contains(widget.keyword!)).toList();
    }

    return Container(
      // color: Colors.amber,
      child: SizedBox(
        width: 500,
        height: (20 + (32 * aps.length)).toDouble(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,  
                child: SimpleListView(
                  items: aps,
                  itemBuilder: (context, index, isFocused) {
                    return ListTile(
                      leading: Icon(
                        _getWifiIcon(aps[index].rssi),
                        size: 15,
                        color: Color(0xF0AEB2B9),
                      ),
                      title: Text(
                        aps[index].essid,
                        style: const TextStyle(fontSize: 10),
                      ),
                      minTileHeight: 25,
                      onTap: () {
                        _showWifiPasswordPopup(aps[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Found ${aps.length} available APs, ${aps.length > 0 ? 'click AP name to connect.' : ''} ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWifiIcon(int rssi) {
    if (rssi > -40) {
      return Icons.wifi;
    } else if (rssi > -60) {
      return Icons.wifi_2_bar;
    } else {
      return Icons.wifi_1_bar;
    }
  }

  void _showWifiPasswordPopup(WifiAP ap) {
    if (!mounted) return;
    if (!context.read<WifiProvider>().isActivated) return;

    final wifiProvider = context.read<WifiProvider>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Theme.of(context).colorScheme.onPrimary,
      transitionDuration: $style.times.pageTransition,
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return WifiPasswordPopup(
          ap: ap,
          onConnect: (password) async {
            await wifiProvider.connectToAp(ap.essid, password: password);
          },
          onDisconnect: () async {
            await wifiProvider.disconnectAp(ap);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
