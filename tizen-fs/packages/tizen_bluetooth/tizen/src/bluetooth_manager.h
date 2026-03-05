// Copyright 2022 Samsung Electronics Co., Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_BLUETOOTH_MANAGER_H_
#define FLUTTER_PLUGIN_BLUETOOTH_MANAGER_H_

#include <bluetooth.h>
#include <tizen_error.h>

#include <cstdint>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <vector>

struct DeviceDiscoveryInfo
{
  std::string remoteAddress;            /**< The address of remote device */
  std::string remoteName;               /**< The name of remote device */
  bt_class_s btClass;                   /**< The Bluetooth classes */
  int rssi;                             /**< The strength indicator of received signal  */
  bool isBonded;                        /**< The bonding state */
  std::vector<std::string> serviceUuid; /**< The UUID list of service */
  int serviceCount;                     /**< The number of services */
  bt_appearance_type_e appearance;      /**< The Bluetooth appearance */
  int manufacturerDataLen;              /**< manufacturer specific data length */
  std::string manufacturerData;         /**< manufacturer specific data */
};

using OnDeviceDiscoveryInfoStateChangedEvent =
    std::function<void(int result, int state, DeviceDiscoveryInfo info)>;

struct DeviceInfo
{
  std::string remoteAddress;            /**< The address of remote device */
  std::string remoteName;               /**< The name of remote device */
  bt_class_s btClass;                   /**< The Bluetooth classes */
  std::vector<std::string> serviceUuid; /**< The UUID list of service */
  int serviceCount;                     /**< The number of services */
  bool isBonded;                        /**< The bonding state */
  bool isConnected;                     /**< The connection state */
  bool isAuthorized;                    /**< The authorization state */
  int manufacturerDataLen;              /**< manufacturer specific data length */
  std::string manufacturerData;         /**< manufacturer specific data */
};

struct AudioConnectionInfo
{
  std::string remoteAddress; /**< The address of remote device */
  bool connected;
  int type;
};

struct ConnectionInfo
{
  std::string remoteAddress; /**< The address of remote device */
  bool connected;
};

using OnDeviceSetBondCreatedEvent =
    std::function<void(int result, DeviceInfo info)>;

using OnDeviceSetBondDestroyedEvent =
    std::function<void(int result, DeviceInfo info)>;

using OnAudioSetConnectionStateChangedEvent =
    std::function<void(int result, AudioConnectionInfo info)>;

using OnHidConnectionStateChangedEvent =
    std::function<void(int result, ConnectionInfo info)>;

class TizenBluetoothManager
{
public:
  ~TizenBluetoothManager();

  // Returns a unique instance of TizenPackageManager.
  static TizenBluetoothManager &GetInstance()
  {
    static TizenBluetoothManager instance;
    return instance;
  }

  // Prevent copying.
  TizenBluetoothManager(TizenBluetoothManager const &) = delete;
  TizenBluetoothManager &operator=(TizenBluetoothManager const &) = delete;

  void SetDeviceDiscoveryInfoStateChangedHandler(OnDeviceDiscoveryInfoStateChangedEvent on_event);
  void SetDeviceSetBondCreatedHandler(OnDeviceSetBondCreatedEvent on_event);
  void SetDeviceSetBondDestroyedHandler(OnDeviceSetBondDestroyedEvent on_event);
  void SetAudioSetConnectionStateChangedEvent(OnAudioSetConnectionStateChangedEvent on_event);
  void SetHidHostConnectionStateChangedEvent(OnHidConnectionStateChangedEvent on_event);
  void SetHidDeviceConnectionStateChangedEvent(OnHidConnectionStateChangedEvent on_event);

  int GetLastError() { return last_error_; }

  std::string GetLastErrorString() { return get_error_message(last_error_); }

  OnDeviceDiscoveryInfoStateChangedEvent device_discovery_info_state_changed_callback_ = nullptr;
  OnDeviceSetBondCreatedEvent device_set_bond_created_callback_ = nullptr;
  OnDeviceSetBondDestroyedEvent device_set_bond_destroyed_callback_ = nullptr;
  OnAudioSetConnectionStateChangedEvent audio_set_connection_state_changed_callback_ = nullptr;
  OnHidConnectionStateChangedEvent hid_host_connection_state_changed_callback_ = nullptr;
  OnHidConnectionStateChangedEvent hid_device_connection_state_changed_callback_ = nullptr;

private:
  explicit TizenBluetoothManager();

  int last_error_ = BT_ERROR_NONE;
};

#endif // FLUTTER_PLUGIN_BLUETOOTH_MANAGER_H_
