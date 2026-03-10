import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/bt_model.dart';
import 'package:tizen_fs/models/page_node.dart';
import 'package:tizen_fs/settings/bt_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/bt_list_view.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({
    super.key,
    required this.node,
    required this.isEnabled,
    required this.onSelectionChanged,
  });

  final PageNode? node;
  final bool isEnabled;
  final Function(int)? onSelectionChanged;

  @override
  State<BluetoothPage> createState() => BluetoothPageState();
}

class BluetoothPageState extends State<BluetoothPage> {
  GlobalKey<BtDeviceListViewState> _listKey =
      GlobalKey<BtDeviceListViewState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initFocus() {
    _listKey.currentState?.initFocus();
  }

  @override
  void didUpdateWidget(BluetoothPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled) {
      initFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleHeight = 100;
    double titleFontSize = 35;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        SizedBox(
          height: titleHeight,
          width: 400,
          child: AnimatedPadding(
            duration: $style.times.med,
            padding: // title up/left padding
                widget.isEnabled
                    ? EdgeInsets.fromLTRB(120, 60, 40, 0)
                    : EdgeInsets.fromLTRB(80, 60, 80, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                getLocalizedTextByKey(context, widget.node?.title ?? ''),
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 2,
                style: TextStyle(fontSize: titleFontSize),
              ),
            ),
          ),
        ),
        //list
        if (!widget.node!.children.isEmpty)
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedPadding(
                duration: $style.times.med,
                padding: // item left/right padding
                    widget.isEnabled
                        ? const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        )
                        : const EdgeInsets.symmetric(horizontal: 40),
                child: BtDeviceListView(
                  key: _listKey,
                  onAction: (index) {
                    if (index == 1) {
                      Provider.of<BtModel>(context, listen: false).toggle();
                    } else {
                      _showFullScreenPopup(context, index);
                    }
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenPopup(BuildContext context, int index) {
    final btDevice = Provider.of<BtModel>(
      context,
      listen: false,
    ).getDevice(index);
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
              scrollToItem(btDevice);
            },
            onConnect: () async {
              await getIt<BtModel>().connect(btDevice);
              Navigator.of(context).pop();
              scrollToItem(btDevice);
            },
            onDisConnect: () async {
              await getIt<BtModel>().disconnect(btDevice);
              Navigator.of(context).pop();
              scrollToItem(btDevice);
            },
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
  }

  void scrollToItem(BtDevice devcie) {
    final index = getIt<BtModel>().getDevcieIndex(devcie);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listKey.currentState?.forceScrollTo(index);
    });
  }
}
