import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tizen_bluetooth/tizen_bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _tizenBluetoothManager = TizenBluetoothManager();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  String targetRemoteAddress = 'none';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      debugPrint('call btInitialize()');
                      TizenBluetoothManager.btInitialize();
                      debugPrint('call btAdapterSetStateChangedCallback()');
                      TizenBluetoothManager.btAdapterSetStateChangedCallback((
                        int result,
                        int state,
                      ) {
                        debugPrint(
                          'btAdapterSetStateChangedCallback : result $result / state $state',
                        );
                      });
                    },
                    child: const Text('btInitialize'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btDeinitialize()');
                      TizenBluetoothManager.btDeinitialize();
                    },
                    child: const Text('btDeinitialize'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btAdapterEnable()');
                      TizenBluetoothManager.btAdapterEnable();
                    },
                    child: const Text('btAdapterEnable'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btAdapterDisable()');
                      TizenBluetoothManager.btAdapterDisable();
                    },
                    child: const Text('btAdapterDisable'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      debugPrint('call btAdapterStartDeviceDiscovery()');
                      TizenBluetoothManager.btAdapterStartDeviceDiscovery();
                    },
                    child: const Text('btAdapterStartDeviceDiscovery'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btAdapterStopDeviceDiscovery()');
                      TizenBluetoothManager.btAdapterStopDeviceDiscovery();
                    },
                    child: const Text('btAdapterStopDeviceDiscovery'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btAdapterForeachBondedDevice()');
                      TizenBluetoothManager.btAdapterForeachBondedDevice((
                        BluetoothDeviceInfo deviceInfo,
                      ) {
                        debugPrint(
                          'bonded device: ${deviceInfo.remoteName}(${deviceInfo.remoteAddress})',
                        ); //정상 동작
                      });
                    },
                    child: const Text('btAdapterForeachBondedDevice'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call btAdapterSetDeviceDiscoveryStateChangedCallback()',
                      );
                      TizenBluetoothManager.btAdapterSetDeviceDiscoveryStateChangedCallback((
                        int result,
                        int discoveryState,
                        DeviceDiscoveryInfo deviceDiscoveryInfo,
                      ) {
                        if (discoveryState == 2) {
                          debugPrint(
                            'Discovery => remoteName : ${deviceDiscoveryInfo.remoteName} / remoteAddress : ${deviceDiscoveryInfo.remoteAddress} / '
                            'btClass : ${deviceDiscoveryInfo.btClass.minorDeviceClass}.'
                            '${deviceDiscoveryInfo.btClass.majorDeviceClass}.'
                            '${deviceDiscoveryInfo.btClass.majorServiceClassMask} /'
                            'isBonded :${deviceDiscoveryInfo.isBonded} /'
                            'rssi :${deviceDiscoveryInfo.rssi} /'
                            'appearance :${deviceDiscoveryInfo.appearance} /'
                            'serviceUuid :${deviceDiscoveryInfo.serviceUuid} /'
                            'manufacturerData :${deviceDiscoveryInfo.manufacturerData} /'
                            'manufacturerDataLen :${deviceDiscoveryInfo.manufacturerDataLen} /',
                          );
                        }
                      });
                    },
                    child: const Text(
                      'btAdapterSetDeviceDiscoveryStateChangedCallback',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call btAdapterUnsetDeviceDiscoveryStateChangedCallback()',
                      );
                      TizenBluetoothManager.btAdapterUnsetDeviceDiscoveryStateChangedCallback();
                    },
                    child: const Text(
                      'btAdapterUnsetDeviceDiscoveryStateChangedCallback',
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () async {
                  //     TizenBluetoothManager.btAdapterSetStateChangedCallback((
                  //       int result,
                  //       int state,
                  //     ) {
                  //       debugPrint(
                  //         'btAdapterSetStateChangedCallback : result $result / state $state',
                  //       );
                  //     });
                  //   },
                  //   child: const Text('btAdapterSetStateChangedCallback'),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      debugPrint('call btInitialize()');
                      TizenBluetoothAudioManager.btInitialize();
                    },
                    child: const Text('btInitialize'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btDeinitialize()');
                      TizenBluetoothAudioManager.btDeinitialize();
                    },
                    child: const Text('btDeinitialize'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call btAudioSetConnectionStateChangedCallback()',
                      );
                      TizenBluetoothAudioManager.btAudioSetConnectionStateChangedCallback((
                        int result,
                        bool connected,
                        String remoteAddress,
                        BluetoothAudioProfileType type,
                      ) {
                        debugPrint(
                          'call on btAudioSetConnectionStateChangedCallback() result : $result /  connected : $connected / remoteAddress : $remoteAddress / type : $type',
                        );
                      });
                      debugPrint(
                        'call btAudioConnect(\'$targetRemoteAddress\', )',
                      );
                      TizenBluetoothAudioManager.btAudioConnect(
                        targetRemoteAddress,
                        BluetoothAudioProfileType.profileTypeAll,
                      );
                    },
                    child: Text(
                      'btAudioConnect(\'$targetRemoteAddress\', All)',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call btAudioDisconnect(\'$targetRemoteAddress\', )',
                      );
                      TizenBluetoothAudioManager.btAudioDisconnect(
                        targetRemoteAddress,
                        BluetoothAudioProfileType.profileTypeAll,
                      );
                    },
                    child: Text(
                      'btAudioDisconnect(\'$targetRemoteAddress\', All)',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call btAudioUnsetConnectionStateChangedCallback()',
                      );
                      TizenBluetoothAudioManager.btAudioUnsetConnectionStateChangedCallback();
                    },
                    child: Text('btAudioUnsetConnectionStateChangedCallback()'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      debugPrint('call btDeviceBondCreatedCallback()');
                      TizenBluetoothManager.btDeviceSetBondCreatedCallback((
                        int result,
                        BluetoothDeviceInfo deviceInfo,
                      ) {
                        debugPrint(
                          'btDeviceBondCreatedCallback: result : $result / ${deviceInfo.remoteName}(${deviceInfo.remoteAddress})',
                        );
                        setState(() {
                          targetRemoteAddress =
                              deviceInfo.remoteAddress; //정상 동작
                        });
                      });

                      debugPrint(
                        'call btDeviceCreateBond(\'$targetRemoteAddress\')',
                      );
                      TizenBluetoothManager.btDeviceCreateBond(
                        targetRemoteAddress,
                      );
                    },
                    child: Text('btDeviceCreateBond(\'$targetRemoteAddress\')'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btDeviceCancelBonding()');
                      TizenBluetoothManager.btDeviceCancelBonding();
                    },
                    child: const Text('btDeviceCancelBonding()'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint('call btDeviceSetBondDestroyedCallback()');
                      TizenBluetoothManager.btDeviceSetBondDestroyedCallback((
                        int result,
                        String remoteAddress,
                      ) {
                        debugPrint(
                          'btDeviceSetBondDestroyedCallback: result : $result / $remoteAddress)',
                        );
                      });

                      debugPrint(
                        'call btDeviceDestroyBond(\'$targetRemoteAddress\', )',
                      );
                      TizenBluetoothManager.btDeviceDestroyBond(
                        targetRemoteAddress,
                      );
                    },
                    child: Text(
                      'btDeviceDestroyBond(\'$targetRemoteAddress\')',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidHostManager.btInitialize()',
                      );
                      TizenBluetoothHidHostManager.btInitialize((
                        int result,
                        bool connected,
                        String remoteAddress,
                      ) {
                        debugPrint(
                          'call TizenBluetoothHidHostManager.btInitialize callback result : $result, connected : $connected, remoteAddress : $remoteAddress',
                        );
                      });
                    },
                    child: const Text(
                      'TizenBluetoothHidHostManager.btInitialize()',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidHostManager.btDeinitialize()',
                      );

                      TizenBluetoothHidHostManager.btDeinitialize();
                    },
                    child: const Text(
                      'TizenBluetoothHidHostManager.btDeinitialize',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidHostManager.btConnect(\'$targetRemoteAddress\')',
                      );
                      TizenBluetoothHidHostManager.btConnect(
                        targetRemoteAddress,
                      );
                    },
                    child: Text(
                      'TizenBluetoothHidHostManager.btConnect(\'$targetRemoteAddress\')',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidHostManager.btDisconnect(\'$targetRemoteAddress\')',
                      );

                      TizenBluetoothHidHostManager.btDisconnect(
                        targetRemoteAddress,
                      );
                    },
                    child: Text(
                      'TizenBluetoothHidHostManager.btDisconnect(\'$targetRemoteAddress\')',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btActivate()',
                      );
                      TizenBluetoothHidDeviceManager.btActivate((
                        int result,
                        bool connected,
                        String remoteAddress,
                      ) {
                        debugPrint(
                          'call TizenBluetoothHidDeviceManager.btActivate callback result : $result, connected : $connected, remoteAddress : $remoteAddress',
                        );
                      });
                    },
                    child: const Text(
                      'TizenBluetoothHidDeviceManager.btActivate()',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btDeactivate()',
                      );

                      TizenBluetoothHidDeviceManager.btDeactivate();
                    },
                    child: const Text(
                      'TizenBluetoothHidDeviceManager.btDeactivate',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btConnect(\'$targetRemoteAddress\')',
                      );
                      TizenBluetoothHidDeviceManager.btConnect(
                        targetRemoteAddress,
                      );
                    },
                    child: const Text(
                      'TizenBluetoothHidDeviceManager.btConnect(\'targetBondAdress\')',
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btDisconnect(\'$targetRemoteAddress\')',
                      );

                      TizenBluetoothHidDeviceManager.btDisconnect(
                        targetRemoteAddress,
                      );
                    },
                    child: Text(
                      'TizenBluetoothHidDeviceManager.btDisconnect(\'$targetRemoteAddress\')',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btDeviceSetAlias(\'5C:B4:7E:1D:AB:F4\', \'COMPANY-PC\',)',
                      );

                      TizenBluetoothManager.btDeviceSetAlias(
                        '5C:B4:7E:1D:AB:F4',
                        'COMPANY-PC',
                      );
                      setState(() {
                        targetRemoteAddress = 'COMPANY-PC';
                      });
                    },
                    child: const Text(
                      'TizenBluetoothHidDeviceManager.btDeviceSetAlias(\'5C:B4:7E:1D:AB:F4\', \'COMPANY-PC\',)',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                        'call TizenBluetoothHidDeviceManager.btDeviceSetAlias(\'54:10:4F:D2:74:4F\', \'Buds\',)',
                      );

                      TizenBluetoothManager.btDeviceSetAlias(
                        '54:10:4F:D2:74:4F',
                        'Buds',
                      );
                      setState(() {
                        targetRemoteAddress = 'Buds';
                      });
                    },
                    child: const Text(
                      'TizenBluetoothHidDeviceManager.btDeviceSetAlias(\'54:10:4F:D2:74:4F\', \'Buds\',)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        targetRemoteAddress = '5C:B4:7E:1D:AB:F4';
                      });
                    },
                    child: const Text(
                      'targetRemoteAddress \'5C:B4:7E:1D:AB:F4\' (COMPANY-PC)',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        targetRemoteAddress = '54:10:4F:D2:74:4F';
                      });
                    },
                    child: const Text(
                      'targetRemoteAddress \'54:10:4F:D2:74:4F\' (Buds)',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
