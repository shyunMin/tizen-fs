import 'dart:ffi';
import 'package:tizen_interop/9.0/tizen.dart';

enum BluetoothAudioProfileType {
  /// < All supported profiles related with audio (Both Host and Device role)
  profileTypeAll,

  /// < local device AG and remote device HF Client (Host role, ex: mobile)
  profileTypeHSPHFP,

  /// < A2DP Source Connection, remote device is A2DP Sink (Host role, ex: mobile)
  profileTypeA2DP,

  /// < local device HF Client and remote device AG (Device role, ex: headset)
  profileTypeAG,

  /// < A2DP Sink Connection, remote device is A2DP Source (Device role, ex: headset)
  profileTypeA2DPSink,
}

class BluetoothClass {
  /// < Major device class.
  int majorDeviceClass;

  /// < Minor device class.
  int minorDeviceClass;

  /// < Major service class mask.
  /// This value can be a combination of #bt_major_service_class_e like #BT_MAJOR_SERVICE_CLASS_RENDERING | #BT_MAJOR_SERVICE_CLASS_AUDIO
  int majorServiceClassMask;

  BluetoothClass({
    this.majorDeviceClass = 0,
    this.minorDeviceClass = 0,
    this.majorServiceClassMask = 0,
  });
}

class BluetoothDeviceInfo {
  int result;

  /// < The address of remote device
  String remoteAddress;

  /// < The name of remote device
  String remoteName;

  /// < The Bluetooth classes
  BluetoothClass btClass;

  /// < The UUID list of service
  List<String> serviceUuid;

  /// < The number of services
  int serviceCount;

  /// < The bonding state
  bool isBonded;

  /// < The connection state
  bool isConnected;

  /// < The authorization state
  bool isAuthorized;

  /// < manufacturer specific data length
  int manufacturerDataLen;

  /// < manufacturer specific data
  String manufacturerData;

  BluetoothDeviceInfo({
    this.result = 0,
    this.remoteAddress = '',
    this.remoteName = '',
    BluetoothClass? btClass,
    List<String>? serviceUuid,
    this.serviceCount = 0,
    this.isBonded = false,
    this.isConnected = false,
    this.isAuthorized = false,
    this.manufacturerDataLen = 0,
    this.manufacturerData = '',
  }) : btClass = btClass ?? BluetoothClass(),
       serviceUuid = serviceUuid ?? <String>[];

  static BluetoothDeviceInfo deviceInfoSToBluetoothDeviceInfo(
    bt_device_info_s info,
  ) {
    // Convert native structure to Dart object
    BluetoothDeviceInfo deviceInfo = BluetoothDeviceInfo();
    if (info.remote_address != nullptr) {
      deviceInfo.remoteAddress = info.remote_address.toDartString();
    }
    if (info.remote_name != nullptr) {
      deviceInfo.remoteName = info.remote_name.toDartString();
    }
    // Convert Bluetooth class
    deviceInfo.btClass = BluetoothClass(
      majorDeviceClass: info.bt_class.major_device_class,
      minorDeviceClass: info.bt_class.minor_device_class,
      majorServiceClassMask: info.bt_class.major_service_class_mask,
    );
    // Convert service UUIDs
    deviceInfo.serviceCount = info.service_count;
    if (info.service_uuid != nullptr && deviceInfo.serviceCount > 0) {
      final serviceUuidPtr = info.service_uuid;
      for (int i = 0; i < deviceInfo.serviceCount; i++) {
        final uuidPtr = serviceUuidPtr.elementAt(i).value;
        if (uuidPtr != nullptr) {
          deviceInfo.serviceUuid.add(uuidPtr.toDartString());
        }
      }
    }
    deviceInfo.isBonded = info.is_bonded;
    deviceInfo.isConnected = info.is_connected;
    deviceInfo.isAuthorized = info.is_authorized;
    deviceInfo.manufacturerData = info.manufacturer_data.toDartString();

    return deviceInfo;
  }

  static BluetoothDeviceInfo fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceInfo(
      result: map['result'] != null ? map['result'] as int : 0,
      remoteAddress: map['remoteAddress'] != null
          ? map['remoteAddress'] as String
          : '',
      remoteName: map['remoteName'] != null ? map['remoteName'] as String : '',
      btClass: BluetoothClass(
        majorDeviceClass: map['btClass_majorDeviceClass'] != null
            ? map['btClass_majorDeviceClass'] as int
            : 0,
        minorDeviceClass: map['btClass_minorDeviceClass'] != null
            ? map['btClass_minorDeviceClass'] as int
            : 0,
        majorServiceClassMask: map['btClass_majorServiceClassMask'] != null
            ? map['btClass_majorServiceClassMask'] as int
            : 0,
      ),
      isConnected: map['isConnected'] != null
          ? map['isConnected'] as bool
          : false,
      isBonded: map['isBonded'] != null ? map['isBonded'] as bool : false,
      serviceUuid: map['serviceUuid'] != null
          ? List<String>.from(map['serviceUuid'] as List)
          : [],
      serviceCount: map['serviceCount'] != null
          ? map['serviceCount'] as int
          : 0,
      isAuthorized: map['isAuthorized'] != null
          ? map['isAuthorized'] as bool
          : false,
      manufacturerDataLen: map['manufacturerDataLen'] != null
          ? map['manufacturerDataLen'] as int
          : 0,
      manufacturerData: map['manufacturerData'] != null
          ? map['manufacturerData'] as String
          : '',
    );
  }
}

class AudioConnectionInfo {
  int result;

  /// < The address of remote device
  String remoteAddress;

  bool connected;

  int type;

  AudioConnectionInfo({
    this.result = 0,
    this.remoteAddress = '',
    this.connected = false,
    this.type = 0,
  }) {}

  static AudioConnectionInfo fromMap(Map<String, dynamic> map) {
    return AudioConnectionInfo(
      result: map['result'] != null ? map['result'] as int : 0,
      remoteAddress: map['remoteAddress'] != null
          ? map['remoteAddress'] as String
          : '',
      connected: map['connected'] != null ? map['connected'] as bool : false,
      type: map['type'] != null ? map['type'] as int : 0,
    );
  }
}

class ConnectionInfo {
  int result;

  /// < The address of remote device
  String remoteAddress;

  bool connected;

  ConnectionInfo({
    this.result = 0,
    this.remoteAddress = '',
    this.connected = false,
  }) {}

  static ConnectionInfo fromMap(Map<String, dynamic> map) {
    return ConnectionInfo(
      result: map['result'] != null ? map['result'] as int : 0,
      remoteAddress: map['remoteAddress'] != null
          ? map['remoteAddress'] as String
          : '',
      connected: map['connected'] != null ? map['connected'] as bool : false,
    );
  }
}

class DeviceDiscoveryInfo {
  int result;
  int state;

  /// < The address of remote device
  String remoteAddress;

  /// < The name of remote device
  String remoteName;

  /// < The Bluetooth classes
  BluetoothClass btClass;

  /// < The strength indicator of received signal
  int rssi;

  /// < The bonding state
  bool isBonded;

  /// < The UUID list of service
  List<String> serviceUuid;

  /// < The number of services
  int serviceCount;

  /// < The Bluetooth appearance
  int appearance;

  /// < manufacturer specific data length
  int manufacturerDataLen;

  /// < manufacturer specific data
  String manufacturerData;

  DeviceDiscoveryInfo({
    this.result = 0,
    this.state = 0,
    this.remoteAddress = '',
    this.remoteName = '',
    BluetoothClass? btClass,
    this.rssi = 0,
    this.isBonded = false,
    List<String>? serviceUuid,
    this.serviceCount = 0,
    this.appearance = 0,
    this.manufacturerDataLen = 0,
    this.manufacturerData = '',
  }) : btClass = btClass ?? BluetoothClass(),
       serviceUuid = serviceUuid ?? <String>[];

  static DeviceDiscoveryInfo deviceDiscoveryInfoSToDeviceDiscoveryInfo(
    bt_adapter_device_discovery_info_s info,
  ) {
    // Convert native structure to Dart object
    DeviceDiscoveryInfo discoveryInfo = DeviceDiscoveryInfo();

    if (info.remote_address != nullptr) {
      discoveryInfo.remoteAddress = info.remote_address.toDartString();
    }

    if (info.remote_name != nullptr) {
      discoveryInfo.remoteName = info.remote_name.toDartString();
    }

    discoveryInfo.rssi = info.rssi;

    // Convert Bluetooth class
    discoveryInfo.btClass = BluetoothClass(
      majorDeviceClass: info.bt_class.major_device_class,
      minorDeviceClass: info.bt_class.minor_device_class,
      majorServiceClassMask: info.bt_class.major_service_class_mask,
    );

    // Convert service UUIDs
    discoveryInfo.serviceCount = info.service_count;
    if (info.service_uuid != nullptr && discoveryInfo.serviceCount > 0) {
      final serviceUuidPtr = info.service_uuid;
      for (int i = 0; i < discoveryInfo.serviceCount; i++) {
        final uuidPtr = serviceUuidPtr.elementAt(i).value;
        if (uuidPtr != nullptr) {
          discoveryInfo.serviceUuid.add(uuidPtr.toDartString());
        }
      }
    }

    discoveryInfo.isBonded = info.is_bonded;
    discoveryInfo.manufacturerDataLen = info.manufacturer_data_len;
    discoveryInfo.manufacturerData = info.manufacturer_data.toDartString();
    discoveryInfo.appearance = info.appearance;

    return discoveryInfo;
  }

  static DeviceDiscoveryInfo fromMap(Map<String, dynamic> map) {
    return DeviceDiscoveryInfo(
      result: map['result'] != null ? map['result'] as int : 0,
      state: map['state'] != null ? map['state'] as int : 0,
      remoteAddress: map['remoteAddress'] != null
          ? map['remoteAddress'] as String
          : '',
      remoteName: map['remoteName'] != null ? map['remoteName'] as String : '',
      btClass: BluetoothClass(
        majorDeviceClass: map['btClass_majorDeviceClass'] != null
            ? map['btClass_majorDeviceClass'] as int
            : 0,
        minorDeviceClass: map['btClass_minorDeviceClass'] != null
            ? map['btClass_minorDeviceClass'] as int
            : 0,
        majorServiceClassMask: map['btClass_majorServiceClassMask'] != null
            ? map['btClass_majorServiceClassMask'] as int
            : 0,
      ),
      rssi: map['rssi'] != null ? map['rssi'] as int : 0,
      isBonded: map['isBonded'] != null ? map['isBonded'] as bool : false,
      serviceUuid: map['serviceUuid'] != null
          ? List<String>.from(map['serviceUuid'] as List)
          : [],
      serviceCount: map['serviceCount'] != null
          ? map['serviceCount'] as int
          : 0,
      appearance: map['appearance'] != null ? map['appearance'] as int : 0,
      manufacturerDataLen: map['manufacturerDataLen'] != null
          ? map['manufacturerDataLen'] as int
          : 0,
      manufacturerData: map['manufacturerData'] != null
          ? map['manufacturerData'] as String
          : '',
    );
  }
}
