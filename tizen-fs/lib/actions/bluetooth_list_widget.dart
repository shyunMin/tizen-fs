import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/settings/bt_popup.dart';
import 'package:tizen_fs/widgets/simple_list_view.dart';

// ignore: must_be_immutable
class BluetoothListWidget extends StatefulWidget {
  BluetoothListWidget({super.key, this.keyword});

  String? keyword;

  @override
  State<BluetoothListWidget> createState() => BluetoothListWidgetState();
}

class BluetoothListWidgetState extends State<BluetoothListWidget> {
  final GlobalKey<SimpleListViewState> _listKey =
      GlobalKey<SimpleListViewState>();

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
    final found = context.read<BtModel>().foundDevices.cast<BtDevice>();
    final paired = context.read<BtModel>().connectedDevices.cast<BtDevice>();
    List<BtDevice> devices = [...paired, ...found];

    if (widget.key != null) {
      devices =
          devices
              .where((device) => device.remoteName.contains(widget.keyword!))
              .toList();
    }

    return Container(
      // color: Colors.amber,
      child: SizedBox(
        width: 500,
        height: (20 + (32 * devices.length)).toDouble(),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: SimpleListView(
                  items: devices,
                  itemBuilder: (context, index, isFocused) {
                    return ListTile(
                      leading: Icon(
                        Icons.bluetooth,
                        size: 15,
                        color: Color(0xF0AEB2B9),
                      ),
                      title: Text(
                        devices[index].remoteName,
                        style: const TextStyle(fontSize: 10),
                      ),
                      minTileHeight: 25,
                      onTap: () {
                        _showFullScreenPopup(context, devices[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Found ${devices.length} available APs, ${devices.length > 0 ? 'click device name to connect.' : ''} ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenPopup(BuildContext context, BtDevice btDevice) {
    if (!mounted) return;
    if (!context.read<BtModel>().isEnabled) return;

    if (btDevice != null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 80),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BtConnectingPopup(
            device: btDevice,
            onUnpair: () async {
              await getIt<BtModel>().unpair(btDevice);
              Navigator.of(context).pop();
            },
            onConnect: () async {
              await getIt<BtModel>().connect(btDevice);
              Navigator.of(context).pop();
            },
            onDisConnect: () async {
              await getIt<BtModel>().disconnect(btDevice);
              Navigator.of(context).pop();
            },
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
  }
}
