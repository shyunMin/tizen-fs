import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/models/app_data_model.dart';
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/native/content_manager.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/utils/extensions.dart';
import 'package:tizen_interop/9.0/tizen.dart';

class ToggleItem extends ChangeNotifier {
  String name;
  bool isOn;

  ToggleItem({this.name = '', this.isOn = false});
}

class StorageData extends ChangeNotifier implements ItemDisplayInterface {
  String name;
  int size;
  Color? color;

  StorageData({this.name = '', this.size = 0, this.color});

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateSize(int value) {
    size += value;
    notifyListeners();
  }

  @override
  String get displayText => name;

  @override
  String? get displaySubText => size.toSizeString();

  @override
  Object? get iconSourceData => color;

  @override
  IconSourceType get iconSourceType => IconSourceType.color;

  @override
  bool get isSelectable => true;
}

class StorageDataModel extends ChangeNotifier {
  List<StorageData> _internal = [];
  List<StorageData> get internal => _internal;

  List<StorageData> _external = [];
  List<StorageData> get external => _external;

  void initStorages() {
    _internal = [
      StorageData(name: 'total', size: 0, color: null),
      StorageData(name: 'available', size: 0, color: null),
      StorageData(name: 'apps', size: 0, color: $style.storageColors.apps),
      StorageData(name: 'images', size: 0, color: $style.storageColors.images),
      StorageData(name: 'videos', size: 0, color: $style.storageColors.videos),
      StorageData(name: 'audio', size: 0, color: $style.storageColors.audio),
      StorageData(name: 'misc', size: 0, color: $style.storageColors.misc),
      StorageData(name: 'cache', size: 0, color: $style.storageColors.cache),
      // StorageData(name: 'System storage', size: 0),
    ];
    _external = [
      StorageData(name: 'total', size: 0, color: null),
      StorageData(name: 'available', size: 0, color: null),
      // TOOD
      // StorageData(name: 'unmount', size: -1, color: null),
      // StorageData(name: 'format', size: -1, color: null),
    ];
  }

  void updateInternel(String key, int value) {
    final item = _internal.where((item) => item.name == key).firstOrNull;

    if (item != null) {
      item.updateSize(value);
    }
  }

  void updateExtrenal(String key, int value) {
    final item = _external.where((item) => item.name == key).firstOrNull;

    if (item != null) {
      item.updateSize(value);
    }
  }

  static bool _getStorageCallback(
    int storage_id,
    int type,
    int state,
    Pointer<Char> path,
    Pointer<Void> user_data,
  ) {
    debugPrint('storage_id=$storage_id, type=$type, state=$state');
    int total = 0, available = 0;

    using((Arena arena) {
      final totalptr = arena<UnsignedLongLong>();
      int ret = tizen.storage_get_total_space(storage_id, totalptr);
      if (ret != 0) {
        debugPrint(
          'Failed to storage_get_total_space. Error code: ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      total = totalptr.value;

      final availableptr = arena<UnsignedLongLong>();
      ret = tizen.storage_get_available_space(storage_id, availableptr);
      if (ret != 0) {
        debugPrint(
          'Failed to storage_get_available_space. Error code: ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      available = availableptr.value;
    });

    // internal, extrenal, extended internal
    if (type == 0 || type == 2) {
      getIt<StorageDataModel>().updateInternel('total', total);
      getIt<StorageDataModel>().updateInternel('available', available);
    } else {
      getIt<StorageDataModel>().updateExtrenal('total', total);
      getIt<StorageDataModel>().updateExtrenal('available', available);
    }
    return true;
  }

  Future<void> loadStorage() async {
    final callback = Pointer.fromFunction<storage_device_supported_cbFunction>(
      _getStorageCallback,
      false,
    );
    int ret = tizen.storage_foreach_device_supported(callback, nullptr);
    if (ret != 0) {
      debugPrint(
        'Failed to storage_foreach_device_supported. Error code: ${tizen.get_error_message(ret).toDartString()}',
      );
    }
  }

  Future<void> loadAppSize() async {
    // TODO app size, cache size
    // int ret = tizen.package_manager_get_total_package_size_info(
    //   _pkg_size_cb.interopCallback,
    //   _pkg_size_cb.interopUserData,
    // );
    await getIt<AppDataModel>().loadAppSize();
    final apps = [...getIt<AppDataModel>().allApps];
    int appSize = 0;
    int cacheSize = 0;
    for (var app in apps) {
      appSize += app.size?.total ?? 0;
      cacheSize += app.size?.cache ?? 0;
    }

    updateInternel('apps', appSize);
    updateInternel('cache', cacheSize);
  }

  Future<void> loadMediaSize() async {
    ContentManager.connect();

    int images = 0;
    int videos = 0;
    int audio = 0;
    int misc = 0;

    final list = await ContentManager.getAllMediaContentForSize('');
    debugPrint('list.length=${list.length}');
    for (var media in list) {
      if (media.type == MediaType.image) {
        images += media.size;
      } else if (media.type == MediaType.video) {
        videos += media.size;
      } else if (media.type == MediaType.music) {
        audio += media.size;
      } else {
        misc += media.size;
      }
    }
    updateInternel('images', images);
    updateInternel('videos', videos);
    updateInternel('audio', audio);

    // final others =
    //     "$MEDIA_TYPE != ${media_content_type_e.MEDIA_CONTENT_TYPE_IMAGE} AND $MEDIA_TYPE != ${media_content_type_e.MEDIA_CONTENT_TYPE_VIDEO} AND $MEDIA_TYPE != ${media_content_type_e.MEDIA_CONTENT_TYPE_MUSIC} AND $MEDIA_TYPE != ${media_content_type_e.MEDIA_CONTENT_TYPE_SOUND}";
    // final miscList = await ContentManager.getAllMediaContentForSize(others);
    // debugPrint('miscList.length=${miscList.length}');
    // for (var media in miscList) {
    //   misc += media.size;
    // }
    updateInternel('misc', misc);

    ContentManager.disconnect();
  }

  Future<void> loadMiscSize() async {}
}
