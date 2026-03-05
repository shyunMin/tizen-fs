import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_interop/9.0/tizen.dart';
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';
import 'package:tizen_package_manager/tizen_package_manager.dart';
import 'package:tizen_app_control/tizen_app_control.dart';

class ApplicationManager {
  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();
  static Completer<bool>? _completer;
  static late final _result_cb = _registerResultCallback();
  static late final _reply_cb = _registerReplyCallback();
  static late final _pkg_size_cb = _registerPackageSizeCallback();

  static int _req = 0;
  static int get req => _req;

  static final List<Function(String, Map<String, dynamic>)>
  _appControlReceivedCallbacks = [];

  static void init() {
    PackageManager.onInstallProgressChanged.listen((event) {
      if (event.eventType == PackageEventType.install &&
          event.progress == 100) {
        debugPrint("install packageId=${event.packageId}");
        getIt<AppDataModel>().addInstalledApp(event.packageId);
      }
    });

    PackageManager.onUninstallProgressChanged.listen((event) {
      if (event.eventType == PackageEventType.uninstall &&
          event.progress == 100) {
        debugPrint("uninstall packageId=${event.packageId}");
        getIt<AppDataModel>().removeUninstalledApp(event.packageId);
      }
    });

    AppControl.onAppControl.listen((request) {
      _appControlReceivedCallbacks.forEach(
        (callback) =>
            callback.call(request.callerAppId ?? '', request.extraData),
      );
    });
  }

  static void addAppControlCallback(
    Function(String, Map<String, dynamic>) callback,
  ) {
    _appControlReceivedCallbacks.add(callback);
  }

  static void removeAppControlCallback(
    Function(String, Map<String, dynamic>) callback,
  ) {
    _appControlReceivedCallbacks.remove(callback);
  }

  static void dispose() {
    _callbacks.unregister(_result_cb);
    _callbacks.unregister(_reply_cb);
    _callbacks.unregister(_pkg_size_cb);
  }

  static RegisteredCallback<app_control_result_cbFunction>
  _registerResultCallback() {
    return _callbacks.register<app_control_result_cbFunction>(
      'app_control_result_cb',
      Pointer.fromFunction(_resultCallback),
      userObject: nullptr,
      blocking: false,
    );
  }

  static RegisteredCallback<app_control_reply_cbFunction>
  _registerReplyCallback() {
    return _callbacks.register<app_control_reply_cbFunction>(
      'app_control_reply_cb',
      Pointer.fromFunction(_replyCallback),
      userObject: nullptr,
      blocking: false,
    );
  }

  static RegisteredCallback<package_manager_size_info_receive_cbFunction>
  _registerPackageSizeCallback() {
    return _callbacks.register<package_manager_size_info_receive_cbFunction>(
      'package_manager_size_info_receive_cb',
      Pointer.fromFunction(_getSizeInfoCallback),
      userObject: nullptr,
      blocking: false,
    );
  }

  static void _resultCallback(
    app_control_h request,
    int result,
    Pointer<Void> user_data,
  ) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(true);
      _completer = null;
    }
  }

  static void _replyCallback(
    app_control_h request,
    app_control_h reply,
    int result,
    Pointer<Void> user_data,
  ) {
    // TODO: This callback is not invoked
  }

  static void _getSizeInfoCallback(
    Pointer<Char> pkgId,
    package_size_info_h size_info,
    Pointer<Void> user_data,
  ) {
    Timeline.startSync('_getSizeInfoCallback');
    try {
      debugPrint('_getSizeInfoCallback: ${pkgId.toDartString()}');
      using((Arena arena) {
        final appSize = arena<LongLong>();
        tizen.package_size_info_get_app_size(size_info, appSize);
        debugPrint('_getSizeInfoCallback, appSize: ${appSize.value}');
      });
    } catch (e) {
      debugPrint('_getSizeInfoCallback: $e');
    }
    Timeline.finishSync();
  }

  static Future<bool> launch(String appId) async {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(false);
      _completer = null;
    }

    _completer = Completer<bool>();

    return using((Arena arena) {
      final appControlPtr = arena<app_control_h>();
      int ret = tizen.app_control_create(appControlPtr);
      if (ret != 0) {
        debugPrint(
          'Failed to create app control handle: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      ret = tizen.app_control_set_operation(
        appControlPtr.value,
        APP_CONTROL_OPERATION_DEFAULT.toNativeChar(allocator: arena),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to set operation: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      ret = tizen.app_control_set_app_id(
        appControlPtr.value,
        appId.toNativeChar(allocator: arena),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to set app id: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      ret = tizen.app_control_send_launch_request_async(
        appControlPtr.value,
        _result_cb.interopCallback,
        _reply_cb.interopCallback,
        _result_cb.interopUserData,
      );
      if (ret != 0) {
        debugPrint(
          'Failed to launch the app: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      ret = tizen.app_control_destroy(appControlPtr.value);
      if (ret != 0) {
        debugPrint(
          'Failed to destropy app control handle: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      return _completer!.future;
    });
  }

  static Future<void> clearCache(String pkgnName) async {
    return using((Arena arena) {
      int ret = tizen.package_manager_clear_cache_dir(
        pkgnName.toNativeChar(allocator: arena),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to clear cache: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }
    });
  }

  static Future<void> uninstallPackage(String pkgName) async {
    await PackageManager.uninstall(pkgName);
  }

  static Future<PackageSizeInfo> getPackageSizeInfo(String pkgid) async {
    return PackageManager.getPackageSizeInfo(pkgid);
  }

  static Pointer<Void> intToPointer(int value) {
    return Pointer.fromAddress(value);
  }

  static void forceStop(String appId) {
    debugPrint('forceStop: $appId');
    return using((Arena arena) {
      final appContext = arena<app_context_h>();
      int ret = tizen.app_manager_get_app_context(
        appId.toNativeChar(allocator: arena),
        appContext,
      );
      if (ret == 0) {
        ret = tizen.app_manager_request_terminate_bg_app(appContext.value);
        if (ret != 0) {
          debugPrint(
            'Failed to get app context: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
          );
        }
      } else {
        debugPrint(
          'Failed to get app context: ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }
    });
  }
}
