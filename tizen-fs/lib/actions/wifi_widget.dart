import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/providers/wifi_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/wifi_list_view.dart';

class WifiWidget extends StatefulWidget {
  const WifiWidget({super.key});

  @override
  State<WifiWidget> createState() => WifiWidgetState();
}

class WifiWidgetState extends State<WifiWidget> {
  // final GlobalKey<WifiListViewState> _listKey = GlobalKey<WifiListViewState>();

  @override
  void initState() {
    super.initState();
    Provider.of<WifiProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    // final activated = context.watch<WifiProvider>().isActivated;
    return Container(
      // color: Colors.amber,
      child: SizedBox(
        width: 200,
        height: 65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  bottomLeft: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
                color: Colors.blueGrey.withAlphaF(0.1),
              ),
              child: WifiSwitchItem(
                isFocused: false,
                isEnabled: true,
                wifiProvider: context.watch<WifiProvider>(),
              ),
            ),
            // Expanded(
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: AnimatedPadding(
            //       duration: $style.times.med,
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 10,
            //       ),
            //       child: WifiListView(key: _listKey, isEnabled: true),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
