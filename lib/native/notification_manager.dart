import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_interop/9.0/tizen.dart';
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

final DynamicLibrary _notificationLib = DynamicLibrary.open(
  'libnotification.so.0',
);

typedef _NotificationGetListNative =
    Int32 Function(Int32 type, Int32 count, Pointer<Pointer<Opaque>> list);
typedef _NotificationGetListDart =
    int Function(int type, int count, Pointer<Pointer<Opaque>> list);
final _NotificationGetListDart _notificationGetList = _notificationLib
    .lookupFunction<_NotificationGetListNative, _NotificationGetListDart>(
      'notification_get_list',
    );

typedef _NotificationListGetHeadNative =
    Pointer<Opaque> Function(Pointer<Opaque> list);
typedef _NotificationListGetHeadDart =
    Pointer<Opaque> Function(Pointer<Opaque> list);
final _NotificationListGetHeadDart _notificationListGetHead = _notificationLib
    .lookupFunction<
      _NotificationListGetHeadNative,
      _NotificationListGetHeadDart
    >('notification_list_get_head');

typedef _NotificationListGetDataNative =
    Pointer<Opaque> Function(Pointer<Opaque> list);
typedef _NotificationListGetDataDart =
    Pointer<Opaque> Function(Pointer<Opaque> list);
final _NotificationListGetDataDart _notificationListGetData = _notificationLib
    .lookupFunction<
      _NotificationListGetDataNative,
      _NotificationListGetDataDart
    >('notification_list_get_data');

typedef _NotificationListGetNextNative =
    Pointer<Opaque> Function(Pointer<Opaque> list);
typedef _NotificationListGetNextDart =
    Pointer<Opaque> Function(Pointer<Opaque> list);
final _NotificationListGetNextDart _notificationListGetNext = _notificationLib
    .lookupFunction<
      _NotificationListGetNextNative,
      _NotificationListGetNextDart
    >('notification_list_get_next');

typedef _NotificationFreeListNative = Int32 Function(Pointer<Opaque> list);
typedef _NotificationFreeListDart = int Function(Pointer<Opaque> list);
final _NotificationFreeListDart _notificationFreeList = _notificationLib
    .lookupFunction<_NotificationFreeListNative, _NotificationFreeListDart>(
      'notification_free_list',
    );

typedef _NotificationGetIdNative =
    Int32 Function(
      Pointer<Opaque> noti,
      Pointer<Int32> groupId,
      Pointer<Int32> privId,
    );
typedef _NotificationGetIdDart =
    int Function(
      Pointer<Opaque> noti,
      Pointer<Int32> groupId,
      Pointer<Int32> privId,
    );
final _NotificationGetIdDart _notificationGetId = _notificationLib
    .lookupFunction<_NotificationGetIdNative, _NotificationGetIdDart>(
      'notification_get_id',
    );

typedef _NotificationGetTextNative =
    Int32 Function(
      Pointer<Opaque> noti,
      Int32 type,
      Pointer<Pointer<Utf8>> text,
    );
typedef _NotificationGetTextDart =
    int Function(Pointer<Opaque> noti, int type, Pointer<Pointer<Utf8>> text);
final _NotificationGetTextDart _notificationGetText = _notificationLib
    .lookupFunction<_NotificationGetTextNative, _NotificationGetTextDart>(
      'notification_get_text',
    );

typedef _NotificationGetPkgnameNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Pointer<Utf8>> pkgname);
typedef _NotificationGetPkgnameDart =
    int Function(Pointer<Opaque> noti, Pointer<Pointer<Utf8>> pkgname);
final _NotificationGetPkgnameDart _notificationGetPkgname = _notificationLib
    .lookupFunction<_NotificationGetPkgnameNative, _NotificationGetPkgnameDart>(
      'notification_get_pkgname',
    );

typedef _NotificationGetInsertTimeNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<time_t> time);
typedef _NotificationGetInsertTimeDart =
    int Function(Pointer<Opaque> noti, Pointer<time_t> time);
final _NotificationGetInsertTimeDart _notificationGetInsertTime =
    _notificationLib.lookupFunction<
      _NotificationGetInsertTimeNative,
      _NotificationGetInsertTimeDart
    >('notification_get_insert_time');

typedef _NotificationGetTimeNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<time_t> time);
typedef _NotificationGetTimeDart =
    int Function(Pointer<Opaque> noti, Pointer<time_t> time);
final _NotificationGetTimeDart _notificationGetTime = _notificationLib
    .lookupFunction<_NotificationGetTimeNative, _NotificationGetTimeDart>(
      'notification_get_time',
    );

typedef _NotificationGetAutoRemoveNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Uint8> autoRemove);
typedef _NotificationGetAutoRemoveDart =
    int Function(Pointer<Opaque> noti, Pointer<Uint8> autoRemove);
final _NotificationGetAutoRemoveDart _notificationGetAutoRemove =
    _notificationLib.lookupFunction<
      _NotificationGetAutoRemoveNative,
      _NotificationGetAutoRemoveDart
    >('notification_get_auto_remove');

typedef _NotificationGetLayoutNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Int32> layout);
typedef _NotificationGetLayoutDart =
    int Function(Pointer<Opaque> noti, Pointer<Int32> layout);
final _NotificationGetLayoutDart _notificationGetLayout = _notificationLib
    .lookupFunction<_NotificationGetLayoutNative, _NotificationGetLayoutDart>(
      'notification_get_layout',
    );

typedef _NotificationGetTypeNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Int32> type);
typedef _NotificationGetTypeDart =
    int Function(Pointer<Opaque> noti, Pointer<Int32> type);
final _NotificationGetTypeDart _notificationGetType = _notificationLib
    .lookupFunction<_NotificationGetTypeNative, _NotificationGetTypeDart>(
      'notification_get_type',
    );

typedef _NotificationDeleteByPrivIdNative =
    Int32 Function(Pointer<Utf8> appid, Int32 type, Int32 privId);
typedef _NotificationDeleteByPrivIdDart =
    int Function(Pointer<Utf8> appid, int type, int privId);
final _NotificationDeleteByPrivIdDart _notificationDeleteByPrivId =
    _notificationLib.lookupFunction<
      _NotificationDeleteByPrivIdNative,
      _NotificationDeleteByPrivIdDart
    >('notification_delete_by_priv_id');

typedef _NotificationDeleteNative = Int32 Function(Pointer<Opaque> handle);
typedef _NotificationDeleteDart = int Function(Pointer<Opaque> handle);
final _NotificationDeleteDart _notificationDelete = _notificationLib
    .lookupFunction<_NotificationDeleteNative, _NotificationDeleteDart>(
      'notification_delete',
    );

typedef _NotificationClearNative = Int32 Function(Int32 type);
typedef _NotificationClearDart = int Function(int type);
final _NotificationClearDart _notificationClear = _notificationLib
    .lookupFunction<_NotificationClearNative, _NotificationClearDart>(
      'notification_clear',
    );

typedef _NotificationCreateNative =
    Int32 Function(Pointer<Pointer<Opaque>> notification);
typedef _NotificationCreateDart =
    int Function(Pointer<Pointer<Opaque>> notification);
final _NotificationCreateDart _notificationCreate = _notificationLib
    .lookupFunction<_NotificationCreateNative, _NotificationCreateDart>(
      'notification_create',
    );

typedef _NotificationFreeNative = Int32 Function(Pointer<Opaque> notification);
typedef _NotificationFreeDart = int Function(Pointer<Opaque> notification);
final _NotificationFreeDart _notificationFree = _notificationLib
    .lookupFunction<_NotificationFreeNative, _NotificationFreeDart>(
      'notification_free',
    );

enum NotificationOperationDataType { Type, UniqueNumber, Notification }

typedef _NotificationGetOperationDataNative =
    Int32 Function(
      Pointer<Opaque> operationList,
      Int32 type,
      Pointer<Pointer<Void>> userData,
    );
typedef _NotificationGetOperationDataDart =
    int Function(
      Pointer<Opaque> operationList,
      int type,
      Pointer<Pointer<Void>> userData,
    );
final _NotificationGetOperationDataDart _notificationGetOperationData =
    _notificationLib.lookupFunction<
      _NotificationGetOperationDataNative,
      _NotificationGetOperationDataDart
    >('notification_op_get_data');

typedef _NotificationGetTagNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Pointer<Utf8>> tag);
typedef _NotificationGetTagDart =
    int Function(Pointer<Opaque> noti, Pointer<Pointer<Utf8>> tag);
final _NotificationGetTagDart _notificationGetTag = _notificationLib
    .lookupFunction<_NotificationGetTagNative, _NotificationGetTagDart>(
      'notification_get_tag',
    );

typedef _NotificationGetImageNative =
    Int32 Function(
      Pointer<Opaque> noti,
      Int32 type,
      Pointer<Pointer<Utf8>> image,
    );
typedef _NotificationGetImageDart =
    int Function(Pointer<Opaque> noti, int type, Pointer<Pointer<Utf8>> image);
final _NotificationGetImageDart _notificationGetImage = _notificationLib
    .lookupFunction<_NotificationGetImageNative, _NotificationGetImageDart>(
      'notification_get_image',
    );

typedef _NotificationGetCheckBoxNative =
    Int32 Function(
      Pointer<Opaque> noti,
      Pointer<Uint8> flag,
      Pointer<Uint8> checkedValue,
    );
typedef _NotificationGetCheckBoxDart =
    int Function(
      Pointer<Opaque> noti,
      Pointer<Uint8> flag,
      Pointer<Uint8> checkedValue,
    );
final _NotificationGetCheckBoxDart _notificationGetCheckBox = _notificationLib
    .lookupFunction<
      _NotificationGetCheckBoxNative,
      _NotificationGetCheckBoxDart
    >('notification_get_check_box');

typedef _NotificationGetEventFlagNative =
    Int32 Function(Pointer<Opaque> noti, Pointer<Uint8> eventFlag);
typedef _NotificationGetEventFlagDart =
    int Function(Pointer<Opaque> noti, Pointer<Uint8> eventFlag);
final _NotificationGetEventFlagDart _notificationGetEventFlag = _notificationLib
    .lookupFunction<
      _NotificationGetEventFlagNative,
      _NotificationGetEventFlagDart
    >('notification_get_event_flag');

typedef _NotificationSendEventNative =
    Int32 Function(Int32 uniqueNumber, Int32 evnetType);
typedef _NotificationSendEventDart =
    int Function(int uniqueNumber, int evnetType);
final _NotificationSendEventDart _notificationSendEvent = _notificationLib
    .lookupFunction<_NotificationSendEventNative, _NotificationSendEventDart>(
      'notification_send_event_by_priv_id',
    );

typedef _NotificationSetCheckedValueNative =
    Int32 Function(Pointer<Opaque> handle, Uint8 checkedValue);
typedef _NotificationSetCheckedValueDart =
    int Function(Pointer<Opaque> handle, int checkedValue);
final _NotificationSetCheckedValueDart _notificationSetCheckedValue =
    _notificationLib.lookupFunction<
      _NotificationSetCheckedValueNative,
      _NotificationSetCheckedValueDart
    >('notification_set_check_box_checked');

typedef _NotificationSendEventWithNotificationNative =
    Int32 Function(Pointer<Opaque> handle, Int32 evnetType);
typedef _NotificationSendEventWithNotificationDart =
    int Function(Pointer<Opaque> handle, int evnetType);
final _NotificationSendEventWithNotificationDart
_notificationSendEventWithNotification = _notificationLib.lookupFunction<
  _NotificationSendEventWithNotificationNative,
  _NotificationSendEventWithNotificationDart
>('notification_send_event');

typedef _NotificationLoadNative =
    Pointer<Opaque> Function(Pointer<Utf8> appID, Int32 uniqueID);
typedef _NotificationLoadDart =
    Pointer<Opaque> Function(Pointer<Utf8> appID, int uniqueID);
final _NotificationLoadDart _notificationLoad = _notificationLib
    .lookupFunction<_NotificationLoadNative, _NotificationLoadDart>(
      'notification_load',
    );

typedef _NotificationGetAllCountNative =
    Int32 Function(Int32 type, Pointer<Int32> count);
typedef _NotificationGetAllCountDart =
    int Function(int type, Pointer<Int32> count);
final _NotificationGetAllCountDart _notificationGetAllCount = _notificationLib
    .lookupFunction<
      _NotificationGetAllCountNative,
      _NotificationGetAllCountDart
    >('notification_get_all_count');

class NotificationConstants {
  static const int NOTIFICATION_ERROR_NONE = 0;

  static const int NOTIFICATION_TYPE_NONE = -1; // all type
  static const int NOTIFICATION_TYPE_NOTIFICATION = 0;
  static const int NOTIFICATION_TYPE_ONGOING = 1;
  static const int NOTIFICATION_TYPE_NOTI = 2; // noti
  static const int NOTIFICATION_TYPE_APP_NOTI = 3; // app noti

  static const int NOTIFICATION_TEXT_TYPE_TITLE = 0;
  static const int NOTIFICATION_TEXT_TYPE_CONTENT = 1;

  static const int NOTIFICATION_LAYOUT_TYPE_DEFAULT = 0;
  static const int NOTIFICATION_LAYOUT_TYPE_THUMBNAIL = 1;
  static const int NOTIFICATION_LAYOUT_TYPE_PROGRESS = 2;
}

base class notification_op extends Struct {
  @Int32()
  external int type;
  @Int32()
  external int priv_id;
  @Int32()
  external int extra_info_1;
  @Int32()
  external int extra_info_2;
  external Pointer<Void> noti;
}

typedef _registerDetailedChangedCbNative =
    Void Function(
      Pointer<Void> user_data,
      Int32 type,
      Pointer<notification_op> operations,
      Int32 num_op,
    );

typedef _NotificationRegisterDetailedChangedCbNative =
    Int32 Function(
      Pointer<NativeFunction<_registerDetailedChangedCbNative>>,
      Pointer<Void>,
    );

typedef _NotificationRegisterDetailedChangedCb =
    int Function(
      Pointer<NativeFunction<_registerDetailedChangedCbNative>>,
      Pointer<Void>,
    );

final _NotificationRegisterDetailedChangedCb
notificationRegisterDetailedChangedCb = _notificationLib.lookupFunction<
  _NotificationRegisterDetailedChangedCbNative,
  _NotificationRegisterDetailedChangedCb
>('notification_register_detailed_changed_cb');

typedef _unRegisterDetailedChangedCbDart =
    void Function(
      Pointer<Void> user_data,
      int type,
      Pointer<notification_op> operations,
      int num_op,
    );
typedef _NotificationUnRegisterDetailedCbNative =
    Int32 Function(
      Pointer<
        NativeFunction<
          Void Function(Pointer<Void>, Int32, Pointer<notification_op>, Int32)
        >
      >,
      Pointer<Void>,
    );

typedef _NotificationUnRegisterDetailedCb =
    int Function(
      Pointer<
        NativeFunction<
          Void Function(Pointer<Void>, Int32, Pointer<notification_op>, Int32)
        >
      >,
      Pointer<Void>,
    );

final _NotificationUnRegisterDetailedCb notificationUnRegisterDetailedCb =
    _notificationLib.lookupFunction<
      _NotificationUnRegisterDetailedCbNative,
      _NotificationUnRegisterDetailedCb
    >('notification_unregister_detailed_changed_cb');

class NotificationManager {
  static final _detailChangedController = StreamController<void>.broadcast();
  Stream<void> get onDetailChanged => _detailChangedController.stream;

  static void emitDetailChanged() {
    _detailChangedController.add(null);
  }

  NotificationManager() {
    _registerDetailedChangedCallback();
  }

  bool registered = false;

  @pragma('vm:entry-point')
  static void detailChangedCallback(
    Pointer<Void> user_data,
    int type,
    Pointer<notification_op> list,
    int num_op,
  ) {
    debugPrint(
      '_staticDetailedChangedCallback called: type=$type, num_op=$num_op',
    );
    if (list.address == nullptr.address || num_op <= 0) {
      debugPrint('[Notifications] No operation details provided.');
      return;
    }
    _detailChangedController.add(null);
  }

  Future<void> _registerDetailedChangedCallback() async {
    if (registered) {
      return;
    }
    registered = true;

    final callbacks = TizenInteropCallbacks();
    final detailedChangedCb = callbacks.register<
      Void Function(Pointer<Void>, Int32, Pointer<notification_op>, Int32)
    >(
      'notification_detailed_changed_cb',
      Pointer.fromFunction(detailChangedCallback),
      userObject: nullptr,
    );
    var err = notificationRegisterDetailedChangedCb(
      detailedChangedCb.interopCallback,
      detailedChangedCb.interopUserData,
    );
    if (err != NotificationConstants.NOTIFICATION_ERROR_NONE) {
      debugPrint(
        "[Notifications] Failed to register notification callback: $err",
      );
    } else {
      debugPrint("[Notifications] Callback registered successfully.");
    }
  }

  Future<List<NotificationItem>> getList({
    int type = NotificationConstants.NOTIFICATION_TYPE_NONE,
    int count = -1,
  }) async {
    final listPtrPtr = calloc<Pointer<Opaque>>();
    final items = <NotificationItem>[];
    try {
      final err = _notificationGetList(type, count, listPtrPtr);
      if (err != NotificationConstants.NOTIFICATION_ERROR_NONE) {
        debugPrint("[Notifications] Failed to get notification list: $err");
      }

      final listHead = listPtrPtr.value;
      if (listHead.address == nullptr.address) {
        return [];
      }
      var currentList = _notificationListGetHead(listHead);
      while (currentList.address != nullptr.address) {
        final notiHandle = _notificationListGetData(currentList);
        if (notiHandle.address != nullptr.address) {
          try {
            items.add(NotificationItem._fromHandle(notiHandle));
          } catch (e) {
            debugPrint("[Notifications] Error parsing notification item: $e");
          }
        }
        currentList = _notificationListGetNext(currentList);
      }
      _notificationFreeList(listHead);
    } finally {
      calloc.free(listPtrPtr);
    }
    return items;
  }

  Future<void> delete(String appId, int privId) async {
    final appIdPtr = appId.toNativeUtf8();
    try {
      final err = _notificationDeleteByPrivId(appIdPtr, 0, privId);
      if (err != NotificationConstants.NOTIFICATION_ERROR_NONE) {
        debugPrint("[Notifications] Failed to delete notification: $err");
      }
    } finally {
      calloc.free(appIdPtr);
    }
  }

  Future<void> deleteHandle(Pointer<Opaque> handle) async {
    debugPrint("notification manager delete by handle");
    final err = _notificationDelete(handle);
    if (err != NotificationConstants.NOTIFICATION_ERROR_NONE) {
      debugPrint(
        "[Notifications] Failed to delete notification by handle: $err",
      );
    }
  }

  Future<void> clear() async {
    final err = _notificationClear(
      NotificationConstants.NOTIFICATION_TYPE_NOTIFICATION,
    );
    if (err != NotificationConstants.NOTIFICATION_ERROR_NONE) {
      debugPrint("[Notifications] Failed to clear notifications. Err: $err");
    }
    final err2 = _notificationClear(
      NotificationConstants.NOTIFICATION_TYPE_ONGOING,
    );
    if (err2 != NotificationConstants.NOTIFICATION_ERROR_NONE) {
      debugPrint(
        "[Notifications] Failed to clear ongoing notifications. Err: $err2",
      );
    }
  }

  void dispose() {
    notificationUnRegisterDetailedCb(nullptr, nullptr);
    _detailChangedController.close();
  }
}

class NotificationItem {
  final Pointer<Opaque> handle;
  final int groupId;
  final int privId;
  final String? title;
  final String? content;
  final String? appId;
  final int? insertTime;
  final int layout;
  final int type;

  final String? tag;
  final bool? checkBox;
  final bool? checkedValue;
  final bool? eventFlag;

  final String? icon;
  final String? subIcon;
  final bool? isTimeStampVisible;
  final int? timeStamp;
  final bool? isOngoing;
  final bool? isVisible;
  final bool? autoRemove;

  NotificationItem({
    required this.handle,
    required this.groupId,
    required this.privId,
    this.title,
    this.content,
    this.appId,
    this.insertTime,
    required this.layout,
    required this.type,
    this.tag,
    this.checkBox,
    this.checkedValue,
    this.eventFlag,
    this.icon,
    this.subIcon,
    this.isTimeStampVisible,
    this.timeStamp,
    this.isOngoing,
    this.isVisible,
    this.autoRemove,
  });

  factory NotificationItem._fromHandle(Pointer<Opaque> handle) {
    if (handle.address == nullptr.address) {
      debugPrint("[Notifications] Invalid notification handle");
    }

    final pGroupId = calloc<Int32>();
    final pPrivId = calloc<Int32>();
    final getTitlePtr = calloc<Pointer<Utf8>>();
    final getContentPtr = calloc<Pointer<Utf8>>();
    final getAppIdPtr = calloc<Pointer<Utf8>>();
    final getInsertTimePtr = calloc<time_t>();
    final getTimePtr = calloc<time_t>();
    final getAutoRemovePtr = calloc<Uint8>();
    final pLayout = calloc<Int32>();
    final pType = calloc<Int32>();
    final getTagPtr = calloc<Pointer<Utf8>>();
    final getCheckBoxPtr = calloc<Uint8>();
    final getCheckedValuePtr = calloc<Uint8>();
    final getEventFlagPtr = calloc<Uint8>();
    final getIconPtr = calloc<Pointer<Utf8>>();
    final getSubIconPtr = calloc<Pointer<Utf8>>();

    String? title;
    String? content;
    String? appId;
    int? insertTime;
    int? timeStamp;
    bool? autoRemove;
    int layout = 0;
    int type = 0;
    String? tag;
    bool? checkBox;
    bool? checkedValue;
    bool? eventFlag;
    String? icon;
    String? subIcon;

    late NotificationItem item;
    try {
      final idErr = _notificationGetId(handle, pGroupId, pPrivId);
      if (idErr != NotificationConstants.NOTIFICATION_ERROR_NONE) {
        debugPrint("[Notifications] Failed to get notification ID: $idErr");
      }

      if (_notificationGetText(
            handle,
            NotificationConstants.NOTIFICATION_TEXT_TYPE_TITLE,
            getTitlePtr,
          ) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getTitlePtr.value.address != nullptr.address) {
          title = getTitlePtr.value.toDartString();
        }
      }
      if (_notificationGetText(
            handle,
            NotificationConstants.NOTIFICATION_TEXT_TYPE_CONTENT,
            getContentPtr,
          ) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getContentPtr.value.address != nullptr.address) {
          content = getContentPtr.value.toDartString();
        }
      }
      if (_notificationGetPkgname(handle, getAppIdPtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getAppIdPtr.value.address != nullptr.address) {
          appId = getAppIdPtr.value.toDartString();
        }
      }
      if (_notificationGetInsertTime(handle, getInsertTimePtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        insertTime = getInsertTimePtr.value;
      }
      if (_notificationGetTime(handle, getTimePtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        timeStamp = getTimePtr.value;
      }
      if (_notificationGetAutoRemove(handle, getAutoRemovePtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        autoRemove = getAutoRemovePtr.value != 0;
      }
      if (_notificationGetLayout(handle, pLayout) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        layout = pLayout.value;
      }
      if (_notificationGetType(handle, pType) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        type = pType.value;
      }
      if (_notificationGetTag(handle, getTagPtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getTagPtr.value.address != nullptr.address) {
          tag = getTagPtr.value.toDartString();
        }
      }
      if (_notificationGetCheckBox(
            handle,
            getCheckBoxPtr,
            getCheckedValuePtr,
          ) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        checkBox = getCheckBoxPtr.value != 0;
        checkedValue = getCheckedValuePtr.value != 0;
      }
      if (_notificationGetEventFlag(handle, getEventFlagPtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        eventFlag = getEventFlagPtr.value != 0;
      }

      if (_notificationGetImage(handle, 0, getIconPtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getIconPtr.value.address != nullptr.address) {
          icon = getIconPtr.value.toDartString();
        }
      }
      if (_notificationGetImage(handle, 1, getSubIconPtr) ==
          NotificationConstants.NOTIFICATION_ERROR_NONE) {
        if (getSubIconPtr.value.address != nullptr.address) {
          subIcon = getSubIconPtr.value.toDartString();
        }
      }

      item = NotificationItem(
        handle: handle,
        groupId: pGroupId.value,
        privId: pPrivId.value,
        title: title,
        content: content,
        appId: appId,
        insertTime: insertTime,
        layout: layout,
        type: type,
        tag: tag,
        checkBox: checkBox,
        checkedValue: checkedValue,
        eventFlag: eventFlag,
        icon: icon,
        subIcon: subIcon,
        isTimeStampVisible: timeStamp != null,
        timeStamp: timeStamp,
        isOngoing: false,
        isVisible: true,
        autoRemove: autoRemove,
      );
    } finally {
      calloc.free(pGroupId);
      calloc.free(pPrivId);
      calloc.free(getTitlePtr);
      calloc.free(getContentPtr);
      calloc.free(getAppIdPtr);
      calloc.free(getInsertTimePtr);
      calloc.free(getTimePtr);
      calloc.free(getAutoRemovePtr);
      calloc.free(pLayout);
      calloc.free(pType);
      calloc.free(getTagPtr);
      calloc.free(getCheckBoxPtr);
      calloc.free(getCheckedValuePtr);
      calloc.free(getEventFlagPtr);
      calloc.free(getIconPtr);
      calloc.free(getSubIconPtr);
    }
    return item;
  }
}
