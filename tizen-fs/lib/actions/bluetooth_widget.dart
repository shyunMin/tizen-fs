import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/bt_selectable_listview.dart';

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  @override
  State<BluetoothWidget> createState() => BluetoothWidgetState();
}

class BluetoothWidgetState extends State<BluetoothWidget> {
  // final GlobalKey<BtDeviceListViewState> _listKey =
  //     GlobalKey<BtDeviceListViewState>();

  @override
  void initState() {
    super.initState();
    getIt<BtModel>();
    // BtModel.init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activated = context.watch<BtModel>().isEnabled;

    return Container(
      // color: Colors.amber,
      child: SizedBox(
        width: 300,
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
              child: DeviceListMenuItem(
                name: "Bluetooth",
                isON: context.watch<BtModel>().isEnabled,
                isFocused: false,
                onStateChanged: (state) {
                  if (activated != state) {
                    context.read<BtModel>().toggle();
                  }
                },
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
