import 'dart:ffi';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tizen_fs/native/wifi.dart';
import 'package:tizen_interop/9.0/tizen.dart';

enum SecurityType { none, wep, wpaPsk, wpa2Psk, eap, unknown }

class WifiAP {
  final Pointer<Void> handle;
  final String essid;
  final int state;
  final int frequency;
  final int rssi;
  final SecurityType securityType;
  final bool isPassphraseRequired;
  final bool isWpsSupported;

  WifiAP({
    required this.handle,
    required this.essid,
    required this.state,
    required this.frequency,
    required this.rssi,
    this.securityType = SecurityType.unknown,
    this.isPassphraseRequired = false,
    this.isWpsSupported = false,
  });

  bool get isOpen => securityType == SecurityType.none;
  bool get isSecured => securityType != SecurityType.none;
  bool get isEap => securityType == SecurityType.eap;
  bool get hasWps => isWpsSupported;
}

class WifiProvider with ChangeNotifier {
  late WifiManager _wifiManager;
  bool _isDisposed = false;

  List<WifiAP> get apList => _wifiManager.apList;
  bool get isInitialized => _wifiManager.initialized;
  bool get isActivated => _wifiManager.isActivated();

  bool _isActivating = false;
  bool get isActivating => _isActivating;

  bool _isDeactivating = false;
  bool get isDeactivating => _isDeactivating;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isDisconnecting = false;
  bool get isDisconnecting => _isDisconnecting;

  WifiAP? _connectedAp = null;
  WifiAP? get connectedAp => _connectedAp;

  bool? _lastConnectionResult;
  bool? get lastConnectionResult => _lastConnectionResult;

  bool? _lastDisconnectionResult;
  bool? get lastDisconnectionResult => _lastDisconnectionResult;

  bool? _lastForgetResult;
  bool? get lastForgetResult => _lastForgetResult;

  bool? _isPluginInstalled;
  bool? get isPluginInstalled => _isPluginInstalled;

  WifiProvider() {
    _wifiManager = WifiManager();
    init();
  }

  void init() {
    if (isInitialized) return;

    _wifiManager.init();
    _setupCallbacks();
  }

  void _allConditionReset() {
    _connectedAp = null;
    _isActivating = false;
    _isConnecting = false;
    _isDisconnecting = false;
    _isDeactivating = false;
    _isScanning = false;
    _lastConnectionResult = null;
    _lastDisconnectionResult = null;
    _lastForgetResult = null;
  }

  void _notifyListenersSafe() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _setupCallbacks() {
    WifiManager.onActivated = (int result) async {
      if (_isDisposed) return;

      //debugPrint("@ onActivated[${result}]");
      _allConditionReset();
      _notifyListenersSafe();
      if (result == 0) {
        if (_isPluginInstalled == null) {
          _isPluginInstalled = true;
        }
        await scanAndRefresh();
      } else {
        if (_isPluginInstalled == null) {
          _isPluginInstalled = false;
        }
      }
    };

    WifiManager.onDeactivated = (int result) {
      if (_isDisposed) return;

      //debugPrint("@ onDeactivated[${result}]");
      _isDeactivating = false;
      _connectedAp = null;
      _notifyListenersSafe();
    };

    WifiManager.onScanFinished = (int result) async {
      if (_isDisposed) return;

      _isScanning = false;
      //debugPrint("onScanFinished[${result}]");
      _notifyListenersSafe();
      if (result == 0) {
        //debugPrint("onScanFinished success");
        _updateApListAndCurrentAp();
      }
    };

    WifiManager.onConnected = (int result) {
      if (_isDisposed) return;

      _isConnecting = false;
      _notifyListenersSafe();
      if (result == 0 || result == -30277629) {
        //debugPrint("onConnected success");
        _updateApListAndCurrentAp();
      }
    };

    WifiManager.onDisconnected = (int result) {
      if (_isDisposed) return;

      _isDisconnecting = false;
      _notifyListenersSafe();
      if (result == 0) {
        //debugPrint("onDisconnected success");
        _connectedAp = null;
        _updateApListAndCurrentAp();
      }
    };

    WifiManager.onBackgroundScan = (int result) async {
      if (_isDisposed) return;

      //debugPrint("onBackgroundScan [${result}]");
      if (result == 0) {
        _updateApListAndCurrentAp();
      }
    };

    WifiManager.onConnectionStateChanged = (int result) async {
      if (_isDisposed) return;

      //debugPrint("onConnectionStateChanged [${result}]");
      if (result ==
          wifi_manager_connection_state_e
              .WIFI_MANAGER_CONNECTION_STATE_CONNECTED) {
        //debugPrint("onConnectionStateChanged connect[${result}] //3");
        _isConnecting = false;
        _lastConnectionResult = true;
        _notifyListenersSafe();
        _updateApListAndCurrentAp();
      } else if (result ==
          wifi_manager_connection_state_e
              .WIFI_MANAGER_CONNECTION_STATE_DISCONNECTED) {
        //debugPrint("onConnectionStateChanged disconnect[${result}] //0");
        _isDisconnecting = false;
        _lastDisconnectionResult = true;
        _notifyListenersSafe();
        _updateApListAndCurrentAp();
      } else if (result ==
          wifi_manager_connection_state_e
              .WIFI_MANAGER_CONNECTION_STATE_ASSOCIATION) {
        //debugPrint("onConnectionStateChanged associateion[${result}]");
        _lastConnectionResult = true;
        _notifyListenersSafe();
      } else if (result ==
          wifi_manager_connection_state_e
              .WIFI_MANAGER_CONNECTION_STATE_CONFIGURATION) {
        //debugPrint("onConnectionStateChanged configuration[${result}]");
        _lastConnectionResult = true;
        _notifyListenersSafe();
      } else if (result ==
          wifi_manager_connection_state_e
              .WIFI_MANAGER_CONNECTION_STATE_FAILURE) {
        //debugPrint("onConnectionStateChanged fail[${result}]");
        _lastDisconnectionResult = false;
        _lastConnectionResult = false;
        _notifyListenersSafe();
      }
    };
  }

  @override
  void dispose() {
    _isDisposed = true;

    WifiManager.onActivated = null;
    WifiManager.onDeactivated = null;
    WifiManager.onScanFinished = null;
    WifiManager.onConnected = null;
    WifiManager.onDisconnected = null;
    WifiManager.onBackgroundScan = null;
    WifiManager.onConnectionStateChanged = null;

    _wifiManager.dispose();
    _allConditionReset();
    _connectedAp = null;
    _isPluginInstalled = null;

    super.dispose();
  }

  bool get isSupported => _wifiManager.isSupported;

  Future<bool> wifiOn() async {
    if (_isDisposed) {
      return false;
    }
    if (!isInitialized) {
      init();
    }
    if (_isActivating == true) {
      debugPrint("wifiOn _isActivating true");
      return false;
    }

    if (isActivated == true) {
      debugPrint("wifi is already activated!");
      return true;
    }

    try {
      //debugPrint("wifiOn scanAndRefresh before");
      scanAndRefresh();
      //debugPrint("wifiOn scanAndRefresh after");

      _isActivating = true;
      _notifyListenersSafe();

      //debugPrint("wifiOn activate await");
      await _wifiManager.activate();
      //debugPrint("wifiOn activate wake up");

      return true;
    } catch (e) {
      //debugPrint("wifiOn err");
      _isActivating = false;
      _notifyListenersSafe();
      return false;
    }
  }

  Future<bool> wifiOff() async {
    if (_isDisposed || isInitialized == false) {
      //debugPrint("wifiOff isDisposed or isInitialized false");
      return false;
    }
    if (isActivated == false) {
      //debugPrint("wifiOff isActivated false");
      return true;
    }
    if (_isDeactivating == true) {
      //debugPrint("wifiOff _isDeactivating true");
      return false;
    }

    try {
      _isDeactivating = true;
      _notifyListenersSafe();

      //debugPrint("wifiOff deactivate await");
      await _wifiManager.deactivate();
      //debugPrint("wifiOff deactivate wake up");
      return true;
    } catch (e) {
      //debugPrint("wifiOff err");
      _isDeactivating = false;
      _notifyListenersSafe();
      return false;
    }
  }

  Future<void> scanAndRefresh() async {
    if (_isDisposed || isInitialized == false) {
      //debugPrint("scanAndRefresh  _isDisposed or isInitialized false");
      return;
    }
    if (isActivated == false) {
      //debugPrint("scanAndRefresh  isActivated false");
      return;
    }
    if (_isScanning) {
      //debugPrint("scanAndRefresh  _isScanning true");
      return;
    }

    try {
      _isScanning = true;
      // _notifyListenersSafe();

      _wifiManager.scan();
      //debugPrint("scanAndRefresh scan called");
    } catch (e) {
      //debugPrint("scanAndRefresh err");
      _isScanning = false;
      _notifyListenersSafe();
    }
  }

  void getCurrentAp() {
    if (_isDisposed) return;

    final connectedApHandle = _wifiManager.getConnectedApHandle();
    //debugPrint("getCurrentAp getConnectedApHandle called");

    var id = _wifiManager.findIdByHandle(connectedApHandle);
    //debugPrint("getCurrentAp findIdByHandle called");

    if (connectedApHandle != nullptr) {
      for (var ap in apList) {
        if (ap.essid == id) {
          _connectedAp = ap;
          _notifyListenersSafe();
          //debugPrint("getCurrentAp ap found");
          return;
        }
      }
    }
    //debugPrint("getCurrentAp ap found not");
    _connectedAp = null;
    _notifyListenersSafe();
  }

  void _updateApListAndCurrentAp() {
    if (_isDisposed) return;

    _wifiManager.updateApList();

    getCurrentAp();
    _notifyListenersSafe();
  }

  Future<void> connectToAp(String essid, {String? password = ""}) async {
    if (_isDisposed) return;

    if (_isConnecting) {
      //debugPrint("connectToAp _isConnecting true");
      return; //already connecting
    }
    if (_connectedAp?.essid == essid) {
      //debugPrint("connectToAp essid same");
      return; //already connecting
    }

    try {
      _isConnecting = true;
      _notifyListenersSafe();

      var apHandle = _wifiManager.findHandleByName(essid);
      if (apHandle == nullptr) {
        _isConnecting = false;
        //debugPrint("connectToAp apHandle not found");
        return; //not found
      }

      if (_wifiManager.passphraseRequired(apHandle)) {
        if (password == null || password.isEmpty) {
          _isConnecting = false;
          //debugPrint("connectToAp passphraseRequired but empty");
          return;
        }
        if (!_wifiManager.setPassphrase(apHandle, password)) {
          _isConnecting = false;
          //debugPrint("connectToAp setPassphrase not matched");
          return; //cannot match password
        }
      }

      //debugPrint("connectToAp connect await");
      await _wifiManager.connect(apHandle);
      //debugPrint("connectToAp connect wake up");
    } catch (e) {
      //debugPrint("connectToAp err");
      _isConnecting = false;
      _notifyListenersSafe();
    }
  }

  Future<void> disconnectAp(WifiAP ap) async {
    if (_isDisposed) return;

    if (_isDisconnecting) {
      //debugPrint("disconnectAp _isDisconnecting true");
      return;
    }
    if (_connectedAp?.essid != ap.essid) {
      //debugPrint("already disconnected or different AP");
      // _lastDisconnectionResult = true;
      _notifyListenersSafe();
      return; // this ap is not connected now
    }

    try {
      _isDisconnecting = true;
      _notifyListenersSafe();
      //debugPrint("disconnectAp disconnect await");
      await _wifiManager.disconnect(ap.handle);
      //debugPrint("disconnectAp disconnect wake up");
    } catch (e) {
      //debugPrint("disconnectAp err");
      _isDisconnecting = false;
      // _lastDisconnectionResult = false;
      _notifyListenersSafe();
    }
  }

  Future<void> disconnectFromCurrentAp() async {
    if (_isDisposed || _connectedAp == null || _isDisconnecting) return;

    try {
      _isDisconnecting = true;
      _notifyListenersSafe();

      await _wifiManager.disconnect(_connectedAp!.handle);
    } catch (e) {
      _isDisconnecting = false;
      _notifyListenersSafe();
    }
  }

  List<WifiAP> get specificApList => _wifiManager.specificApList;

  Future<void> scanSpecificAP(String essid) async {
    if (_isDisposed || isInitialized == false) {
      return;
    }
    if (isActivated == false) {
      return;
    }
    if (_isScanning) {
      return;
    }

    try {
      _isScanning = true;
      _notifyListenersSafe();

      await _wifiManager.scanSpecificAP(essid);
    } catch (e) {
      _isScanning = false;
      _notifyListenersSafe();
    }
  }

  Future<void> connectToSpecificAP(
    String essid, {
    String? password = "",
  }) async {
    if (_isDisposed) return;

    if (_isConnecting) {
      return; // already connecting
    }
    if (_connectedAp?.essid == essid) {
      return; // already connecting
    }

    try {
      _isConnecting = true;
      _notifyListenersSafe();

      var apHandle = _wifiManager.findSpecificHandleByName(essid);
      if (apHandle == nullptr) {
        _isConnecting = false;
        return; // not found
      }

      if (_wifiManager.passphraseRequired(apHandle)) {
        if (password == null || password.isEmpty) {
          _isConnecting = false;
          return; // passphrase required but empty
        }
        if (!_wifiManager.setPassphrase(apHandle, password)) {
          _isConnecting = false;
          return; // cannot match password
        }
      }

      await _wifiManager.connect(apHandle);
    } catch (e) {
      _isConnecting = false;
      _notifyListenersSafe();
    }
  }

  Future<void> forgetNetwork(String essid) async {
    if (_isDisposed) return;

    try {
      _lastForgetResult = await _wifiManager.forgetNetwork(essid);
      _notifyListenersSafe();

      await Future.delayed(const Duration(milliseconds: 500));
      _updateApListAndCurrentAp();
    } catch (e) {
      _lastForgetResult = false;
      _notifyListenersSafe();
    }
  }
}
