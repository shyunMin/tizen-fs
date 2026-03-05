import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_bluetooth/tizen_bluetooth.dart';
import 'package:tizen_interop/9.0/tizen.dart';

class BtServiceType {
  static const int none = 0;
  static const int a2dp = bt_service_class_t.BT_SC_A2DP_SERVICE_MASK;
  static const int hsp = bt_service_class_t.BT_SC_HSP_SERVICE_MASK;
  static const int hid = bt_service_class_t.BT_SC_HID_SERVICE_MASK;
  static const int all = bt_service_class_t.BT_SC_ALL_SERVICE_MASK;
}

class BtDevice {
  final String remoteName;
  final String remoteAddress;
  int rssi;
  bool isBonded;
  bool isConnected;
  late List<String> serviceUuid = [];
  final int serviceCount;
  bool get isAudioSupported =>
      ((serviceMask & BtServiceType.a2dp) == BtServiceType.a2dp ||
          ((serviceMask & BtServiceType.hsp) == BtServiceType.hsp));
  bool get isHidSupported =>
      ((serviceMask & BtServiceType.hid) == BtServiceType.hid);
  late int serviceMask;

  BtDevice({
    required this.remoteName,
    required this.remoteAddress,
    this.rssi = 0,
    this.isBonded = false,
    this.isConnected = false,
    required List<String> serviceUuid,
    required this.serviceCount,
  }) : serviceMask = getMaskFromUuid(serviceUuid, serviceCount, remoteName);

  static int getMaskFromUuid(
    List<String> serviceUuid,
    int serviceCount,
    String name,
  ) {
    return using((Arena arena) {
          final uuidsPtr = arena<Pointer<Char>>(serviceCount);

          for (int i = 0; i < serviceCount; i++) {
            final strPtr =
                serviceUuid[i].toNativeUtf8(allocator: arena).cast<Char>();
            uuidsPtr[i] = strPtr;
          }

          final serviceMask = arena<Int32>();
          tizen.bt_device_get_service_mask_from_uuid_list(
            uuidsPtr,
            serviceCount,
            serviceMask,
          );

          debugPrint('mask: ${serviceMask.value}');

          return serviceMask.value;
        }) ??
        0;
  }
}

class Item {
  final bool isKey;
  final dynamic item;
  Widget? icon;
  Widget? footer;

  Item({required this.isKey, required this.item, this.icon, this.footer});
}

class BtModel extends ChangeNotifier {
  Map<String, List> _data = {};

  List<Item> _flattened = [];
  List<Item> get data => _flattened;

  List get connectedDevices => _data['Paired Devices'] as List;
  List get foundDevices => _data['Available Devices'] as List;

  static final Map<String, Completer> _hidCallbackCompleter = {};

  bool _isInitialized = false;
  bool _hidInitialized = false;
  bool _audioInitialized = false;

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  bool _isScanning = false;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _isBtSuppported = true;
  bool get isBtSupported => _isBtSuppported;

  void _flattenData() {
    debugPrint('update _flatten');

    _flattened = <Item>[];

    _data.forEach((key, list) {
      if (list.isNotEmpty) {
        _flattened.add(Item(isKey: true, item: key));
        for (var item in list) {
          _flattened.add(Item(isKey: false, item: item));
        }
      }
    });

    notifyListeners();
  }

  BtDevice? getDevice(int index) {
    if (_flattened.length > index) return _flattened[index].item as BtDevice;

    return null;
  }

  int getDevcieIndex(BtDevice device) {
    for (int i = 0; i < _flattened.length; i++) {
      if (_flattened[i].item is BtDevice) {
        if ((_flattened[i].item as BtDevice).remoteAddress ==
            device.remoteAddress) {
          return i;
        }
      }
    }
    return 0;
  }

  BtModel.init() {
    if (_isInitialized) return;

    _data = {
      'Your device in currentrly visible to nearby devices.': ['Bluetooth'],
      'Paired Devices': [],
      'Available Devices': [],
    };

    debugPrint('BtModel.fromMock call: btInitialize');
    _initialize();
    _flattenData();
  }

  @override
  void dispose() {
    _unsetCallback();
    _deinitializeHid();
    _deinitialize();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    final ret = TizenBluetoothManager.btInitialize();
    if (ret == bt_error_e.BT_ERROR_NOT_SUPPORTED) {
      _isBtSuppported = false;
      return;
    }
    _setCallback();
    _isInitialized = true;
  }

  Future<void> _setCallback() async {
    debugPrint('set callback');

    TizenBluetoothManager.btAdapterSetStateChangedCallback(
      _onBtAdapterStateChanged,
    );
    TizenBluetoothManager.btAdapterSetDeviceDiscoveryStateChangedCallback(
      _onDeviceDiscoveryStateChanged,
    );
  }

  // 0 - disabled, 1-enabled
  void _onBtAdapterStateChanged(int result, int state) async {
    debugPrint('_onBtAdapterStateChanged: result=$result, state=$state');
    if (state == 1) {
      _isEnabled = true;
      notifyListeners();
      _updateConnectedDevices();
      _startDiscovery();
    } else {
      connectedDevices.clear();
      foundDevices.clear();
      _flattenData();
      _isEnabled = false;
      notifyListeners();
    }
    _isBusy = false;
    notifyListeners();
  }

  void _onDeviceDiscoveryStateChanged(
    int result,
    int discoveryState,
    DeviceDiscoveryInfo deviceInfo,
  ) {
    debugPrint(
      '_onDeviceDiscoveryStateChanged: resut=$result, state=$discoveryState',
    );

    // 0 - start, 1 - finished, 2- found
    if (discoveryState == 0) {
      _isScanning = true;
    } else if (discoveryState == 2) {
      foundDevices.add(
        BtDevice(
          remoteName: deviceInfo.remoteName,
          remoteAddress: deviceInfo.remoteAddress,
          serviceCount: deviceInfo.serviceCount,
          serviceUuid: deviceInfo.serviceUuid,
        ),
      );
      _flattenData();
    } else {
      _isScanning = false;
    }
  }

  Future<void> _unsetCallback() async {
    debugPrint('unset callback');
    if (!_isInitialized) return;

    TizenBluetoothManager.btAdapterUnsetStateChangedCallback();
    TizenBluetoothManager.btAdapterUnsetDeviceDiscoveryStateChangedCallback();
  }

  Future<void> _updateConnectedDevices() async {
    connectedDevices.clear();

    TizenBluetoothManager.btAdapterForeachBondedDevice((deviceInfo) {
      debugPrint(
        "get bonded device: ${deviceInfo.remoteName} : ${deviceInfo.remoteAddress}",
      );
      connectedDevices.add(
        BtDevice(
          remoteName: deviceInfo.remoteName,
          remoteAddress: deviceInfo.remoteAddress,
          isBonded: deviceInfo.isBonded,
          isConnected: deviceInfo.isConnected,
          serviceCount: deviceInfo.serviceCount,
          serviceUuid: deviceInfo.serviceUuid,
        ),
      );
    });

    _flattenData();
  }

  Future<void> toggle() async {
    if (!_isBtSuppported) return;

    if (_isEnabled) {
      disable();
    } else {
      enable();
    }
  }

  Future<bool> enable() async {
    debugPrint(
      'bt disable: _isInitialized=$_isInitialized, _isEnabled=$_isEnabled, _isBusy=$_isBusy',
    );
    if (_isBusy) {
      debugPrint(
        'Failed  to enable bluetooth adapter: Device or resource busy',
      );
      return false;
    }

    if (!_isInitialized) {
      _initialize();
    }

    final ret = TizenBluetoothManager.btAdapterEnable();
    if (ret == 0) {
      _isBusy = true;
      notifyListeners();
    } else if (ret == bt_error_e.BT_ERROR_ALREADY_DONE) {
      final state = TizenBluetoothManager.btGetState();
      debugPrint('already done? state=$state');
      if (state == 1) {
        _isBusy = false;
        _isEnabled = true;
        notifyListeners();
        _updateConnectedDevices();
        _startDiscovery();
      }
    } else {
      return false;
    }
    return true;
  }

  Future<void> _startDiscovery() async {
    if (_isEnabled) {
      foundDevices.clear();
      _isScanning = true;
      TizenBluetoothManager.btAdapterStartDeviceDiscovery();
    }
  }

  Future<void> _stopDiscovery() async {
    debugPrint('bt _stopDiscovery _isScanning=$_isScanning');
    if (_isScanning) {
      TizenBluetoothManager.btAdapterStopDeviceDiscovery();
      _isScanning = false;
    }
  }

  Future<bool> disable() async {
    debugPrint(
      'bt disable: _isInitialized=$_isInitialized, _isEnabled=$_isEnabled, _isBusy=$_isBusy',
    );
    if (_isBusy) {
      debugPrint(
        'Failed to disable bluetooth adapter: Device or resource busy',
      );
      return false;
    }

    await _stopDiscovery();

    final ret = TizenBluetoothManager.btAdapterDisable();
    if (ret == 0) {
      _isBusy = true;
      notifyListeners();
    } else if (ret == bt_error_e.BT_ERROR_ALREADY_DONE) {
      final state = TizenBluetoothManager.btGetState();
      debugPrint('already done? state=$state');
      if (state == 1) {
        _isBusy = false;
        _isEnabled = false;
        notifyListeners();
      }
    } else {
      return false;
    }
    return true;
  }

  Future<void> _deinitialize() async {
    if (!_isInitialized) return;

    TizenBluetoothManager.btDeinitialize();
    _unsetCallback();
    _isInitialized = false;
  }

  Future<bool> _pair(BtDevice device) async {
    final completer = Completer<bool>();
    // 0 - complete, 1 - failed
    TizenBluetoothManager.btDeviceSetBondCreatedCallback((result, deviceInfo) {
      debugPrint(
        'BondCreatedCallback: result : $result / ${deviceInfo.remoteName}(${deviceInfo.remoteAddress})',
      );

      TizenBluetoothManager.btDeviceUnsetBondCreatedCallback();
      if (result == 0) {
        final device =
            foundDevices
                .where(
                  (item) =>
                      (item as BtDevice).remoteAddress ==
                      deviceInfo.remoteAddress,
                )
                .first;
        device.isBonded = true;
        connectedDevices.add(device);
        foundDevices.remove(device);
        _flattenData();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    debugPrint('bond');
    TizenBluetoothManager.btDeviceCreateBond(device.remoteAddress);
    return completer.future;
  }

  Future<bool> connect(BtDevice device) async {
    if (!_isBtSuppported) return false;

    final completer = Completer<bool>();
    debugPrint(' connect to device : ${device.remoteName}');

    await _stopDiscovery();

    bool _paired = device.isBonded;
    if (!_paired) {
      _paired = await _pair(device);
    } else {
      debugPrint('device already _paired');
    }

    if (_paired) {
      if (device.isAudioSupported) {
        await _connectAudio(device);
      } else if (device.isHidSupported) {
        await _connectHid(device.remoteAddress);
      }

      completer.complete(true);
    } else {
      completer.complete(false);
    }

    return completer.future;
  }

  Future<bool> _connectAudio(BtDevice device) async {
    debugPrint('### connect to audio');
    final completer = Completer<bool>();
    if (!_audioInitialized) {
      TizenBluetoothAudioManager.btInitialize();
      _audioInitialized = true;
    }

    //All, hsp_hep, a2dp, ag
    TizenBluetoothAudioManager.btAudioSetConnectionStateChangedCallback((
      result,
      connected,
      remoteAddress,
      profileType,
    ) {
      debugPrint(
        'btAudioSetConnectionStateChangedCallback : result=$result, connected=$connected',
      );

      TizenBluetoothAudioManager.btAudioUnsetConnectionStateChangedCallback();
      if (result == 0) {
        device.isConnected = true;
        notifyListeners();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });

    TizenBluetoothAudioManager.btAudioConnect(
      device.remoteAddress,
      BluetoothAudioProfileType.profileTypeA2DP,
    );
    return completer.future;
  }

  Future<bool> _disconnectAudio(BtDevice device) async {
    debugPrint('### disconnect to audio');
    final completer = Completer<bool>();

    if (!_audioInitialized) {
      TizenBluetoothAudioManager.btInitialize();
      _audioInitialized = true;
    }

    //All, hsp_hep, a2dp, ag
    TizenBluetoothAudioManager.btAudioSetConnectionStateChangedCallback((
      result,
      connected,
      remoteAddress,
      profileType,
    ) {
      debugPrint(
        'btAudioSetConnectionStateChangedCallback : result=$result, connected=$connected',
      );

      TizenBluetoothAudioManager.btAudioUnsetConnectionStateChangedCallback();
      if (result == 0) {
        device.isConnected = false;
        notifyListeners();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });

    debugPrint('###### disconnect to audio call: device: ${device.remoteName}');
    TizenBluetoothAudioManager.btAudioDisconnect(
      device.remoteAddress,
      BluetoothAudioProfileType.profileTypeA2DP,
    );
    return completer.future;
  }

  static void _onHidConnectStateChanged(
    int result,
    bool connected,
    String remoteAddress,
  ) {
    debugPrint('hid host initialized');

    if (result == 0) {
      if (_hidCallbackCompleter.keys.contains(remoteAddress)) {
        _hidCallbackCompleter[remoteAddress]?.complete(true);
        _hidCallbackCompleter.remove(remoteAddress);
      }

      // completer.complete(true);
    } else {
      if (_hidCallbackCompleter.keys.contains(remoteAddress)) {
        _hidCallbackCompleter[remoteAddress]?.complete(false);
        _hidCallbackCompleter.remove(remoteAddress);
      }
      // completer.complete(false);
    }
  }

  Future<void> _initializeHid() async {
    debugPrint('### _initializeHid');
    if (_hidInitialized) return;

    TizenBluetoothHidHostManager.btInitialize(_onHidConnectStateChanged);
    _hidInitialized = true;
  }

  Future<bool> _connectHid(String remoteAddress) async {
    debugPrint('### connect to hid');
    final completer = Completer<bool>();

    if (!_hidInitialized) {
      await _initializeHid();
    }

    _hidCallbackCompleter[remoteAddress] = completer;

    TizenBluetoothHidHostManager.btConnect(remoteAddress);

    return completer.future;
  }

  void _deinitializeHid() {
    debugPrint('### _deinitializeHid _hidInitialized=$_hidInitialized');
    if (_hidInitialized) {
      TizenBluetoothHidHostManager.btDeinitialize();
      _hidInitialized = false;
    }
  }

  Future<bool> _disconnectHid(String remoteAddress) async {
    debugPrint('### disconnect to hid');
    final completer = Completer<bool>();

    if (!_hidInitialized) {
      await _initializeHid();
    }

    _hidCallbackCompleter[remoteAddress] = completer;

    TizenBluetoothHidHostManager.btDisconnect(remoteAddress);

    return completer.future;
  }

  Future<void> disconnect(BtDevice device) async {
    if (!_isBtSuppported) return;

    debugPrint(' disconnect to device : ${device.remoteName}');

    if (device.isAudioSupported) {
      await _disconnectAudio(device);
    } else if (device.isHidSupported) {
      final result = await _disconnectHid(device.remoteAddress);
      if (result) {
        device.isConnected = false;
      }
    }
  }

  Future<bool> unpair(BtDevice device) async {
    if (!_isBtSuppported) return false;

    if (!_isEnabled) return false;

    if (_isScanning) _stopDiscovery();

    final completer = Completer<bool>();
    debugPrint('unpair to device : ${device.remoteName}');

    TizenBluetoothManager.btDeviceSetBondDestroyedCallback((
      result,
      remoteaddress,
    ) {
      debugPrint(
        'BondDestroyedCallback: result : $result / address:$remoteaddress',
      );

      TizenBluetoothManager.btDeviceUnsetBondDestroyedCallback();
      if (result == 0) {
        final device =
            connectedDevices
                .where(
                  (item) => (item as BtDevice).remoteAddress == remoteaddress,
                )
                .first;
        device.isConnected = false;
        device.isBonded = false;
        foundDevices.insert(0, device);
        connectedDevices.remove(device);
        _flattenData();
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    debugPrint('bond destroy');
    TizenBluetoothManager.btDeviceDestroyBond(device.remoteAddress);
    return completer.future;
  }
}
