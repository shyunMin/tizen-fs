import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:ffi/ffi.dart';
import 'package:tizen_interop/9.0/tizen.dart';

enum NetworkType { wifi, ethernet, none }

class NetworkStatusProvider extends ChangeNotifier {
  String ipAddress = "";
  String subnetMask = "";
  String gateway = "";
  String dns = "";
  NetworkType networkType = NetworkType.none;
  bool isConnected = false;
  
  bool isLoading = false;
  String? error;

  connection_h? _handle;

  Future<void> _ensureInitialized() async {
    if (_handle != null) return;
    using((Arena arena) {
      final pHandle = arena<connection_h>();
      if (tizen.connection_create(pHandle) == 0) {
        _handle = pHandle.value;
      }
    });
  }

  Future<void> loadNetworkStatus() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _ensureInitialized();
      if (_handle == null) throw Exception("Failed to init Tizen Connection");

      using((Arena arena) {
        final pProfile = arena<connection_profile_h>();
        int ret = tizen.connection_get_current_profile(_handle!, pProfile);

        if (ret == 0 && pProfile.value != nullptr) {
          _updateFromProfile(arena, pProfile.value);
        } else {
          _resetToDefaults();
        }
      });
    } catch (e) {
      error = e.toString();
      _resetToDefaults();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _updateFromProfile(Arena arena, connection_profile_h profile) {
    final pType = arena<Int32>();
    tizen.connection_profile_get_type(profile, pType);
    final int type = pType.value;

    final pState = arena<Int32>();
    tizen.connection_profile_get_state(profile, pState);
    final int stateValue = pState.value;

    bool profileIsConnected = false;

    if (type == connection_profile_type_e.CONNECTION_PROFILE_TYPE_WIFI) {
      networkType = NetworkType.wifi;
      profileIsConnected = (stateValue == 3); 
    } else if (type == connection_profile_type_e.CONNECTION_PROFILE_TYPE_ETHERNET) {
      networkType = NetworkType.ethernet;
      profileIsConnected = (stateValue == 3);
    } else {
      networkType = NetworkType.none;
      profileIsConnected = false;
    }

    isConnected = profileIsConnected;

    if (isConnected) {
      ipAddress = _getProfileString(arena, profile, tizen.connection_profile_get_ip_address);
      gateway = _getProfileString(arena, profile, tizen.connection_profile_get_gateway_address);
      subnetMask = _getProfileString(arena, profile, tizen.connection_profile_get_subnet_mask);
      
      // DNS order 1 is primary
      final pDns = arena<Pointer<Char>>();
      if (tizen.connection_profile_get_dns_address(profile, 1, connection_address_family_e.CONNECTION_ADDRESS_FAMILY_IPV4, pDns) == 0) {
        if (pDns.value != nullptr) {
          dns = pDns.value.cast<Utf8>().toDartString();
          malloc.free(pDns.value.cast());
        }
      }
    } else {
      _resetToDefaults();
    }
  }

  String _getProfileString(Arena arena, connection_profile_h profile, 
      int Function(connection_profile_h, int, Pointer<Pointer<Char>>) fn) {
    final pStr = arena<Pointer<Char>>();
    final int res = fn(profile, connection_address_family_e.CONNECTION_ADDRESS_FAMILY_IPV4, pStr);
    
    if (res == 0 && pStr.value != nullptr) {
      final String result = pStr.value.cast<Utf8>().toDartString();
      malloc.free(pStr.value.cast());
      return result;
    }
    return "";
  }

  void _resetToDefaults() {
    ipAddress = "";
    subnetMask = "";
    gateway = "";
    dns = "";
    networkType = NetworkType.none;
    isConnected = false;
  }

  @override
  void dispose() {
    if (_handle != null) {
      tizen.connection_destroy(_handle!);
      _handle = null;
    }
    super.dispose();
  }
}