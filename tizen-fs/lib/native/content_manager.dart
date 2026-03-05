import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_interop/9.0/tizen.dart';
import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

class ContentManager {
  static bool _connected = false;
  static bool get connected => _connected;

  static List<FolderInfo> folders = [];
  static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();
  static late final _update_cb = _registerUpdateCallback();
  static late final Pointer<Pointer<Void>> _notiHandle = _createNotiHandle();
  static late final _scan_cb = _registerScanCallback();

  static Completer<bool>? _completer;

  static Map<int, List<MediaContentInfo>> _map =
      Map<int, List<MediaContentInfo>>();

  static int _req = 0;
  static int get req => _req;

  ContentManager() {}

  void init() {}

  void dispose() {
    unsetUpdateCallback();
    _callbacks.unregister(_update_cb);
  }

  static void _dbUpdated(
    int error,
    int pid,
    int update_item,
    int update_type,
    int media_type,
    Pointer<Char> id,
    Pointer<Char> path,
    Pointer<Char> mime_type,
    Pointer<Void> user_data,
  ) {
    // media folder에 파일이 추가/삭제 되어도 callback 불리지 않음,
    // 다른 app에서 insert_db 와 같은 db update 함수를 호출 해야 호출 될 것으로 보임 -> 현재 home 시나리오에서 당장은 사용하지 않을 것으로 보임
    // scan 호출해야 해당 callback 불림 -> scan - get media item으로 처리 가능
    try {
      // Pointer<char> data 쓸 수 없음(bt와 동일 이슈)
      debugPrint('*****************db updated');
      debugPrint('id=${id.toDartString()}, path=${path.toDartString()}');
      debugPrint(
        'error=$error, pid=$pid, update_item=$update_item, update_type=$update_type, media_type=$media_type',
      );
      debugPrint('*****************');
    } catch (e) {
      debugPrint('$e');
    }
  }

  static RegisteredCallback<media_content_db_update_cbFunction>
  _registerUpdateCallback() {
    return _callbacks.register(
      'media_content_db_update_cb',
      Pointer.fromFunction(_dbUpdated),
      userObject: nullptr,
      blocking: false,
    );
  }

  static Pointer<Pointer<Void>> _createNotiHandle() {
    return calloc<media_content_noti_h>();
  }

  static void setUpdateCallback() {
    int ret = tizen.media_content_add_db_updated_cb(
      _update_cb.interopCallback,
      _update_cb.interopUserData,
      _notiHandle,
    );
    debugPrint(
      'media_content_add_db_updated_cb ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
    );
  }

  static void unsetUpdateCallback() {
    tizen.media_content_remove_db_updated_cb(_notiHandle.value);
  }

  static bool _getFolder(
    Pointer<media_folder_s> media_folder,
    Pointer<Void> user_data,
  ) {
    final folderPtr = media_folder.cast<media_folder_s>();
    final folder = FolderInfo();
    using((Arena arena) {
      final id = arena<Pointer<Char>>();
      if (tizen.media_folder_get_folder_id(folderPtr, id) == 0) {
        folder.name = id.value.toDartString();
        // debugPrint('###### id: ${id.value.toDartString()}');
      }
      final name = arena<Pointer<Char>>();
      if (tizen.media_folder_get_name(folderPtr, name) == 0) {
        folder.name = name.value.toDartString();
        // debugPrint('###### folder: ${name.value.toDartString()}');
      }

      final path = arena<Pointer<Char>>();
      if (tizen.media_folder_get_path(folderPtr, path) == 0) {
        folder.name = path.value.toDartString();
        // debugPrint('###### path: ${path.value.toDartString()}');
      }

      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);
      if (ret != media_content_error_e.MEDIA_CONTENT_ERROR_NONE) {
        debugPrint(
          'Failed to call media_filter_create ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      final count = arena<Int>();
      if (tizen.media_folder_get_media_count_from_db(
            id.value,
            filterHandlePtr.value,
            count,
          ) ==
          0) {
        // debugPrint('###### item count: ${count.value}');
      }
    });

    // destory호출은 foreach가 종료된 다음이어야 함
    // tizen.media_folder_destroy(media_folder);

    // debugPrint('folders length: ${folders.length}');
    return true;
  }

  static void connect() {
    if (_connected) return;
    // connect 호출시마다 ref count 증가
    int ret = tizen.media_content_connect();
    if (ret != media_content_error_e.MEDIA_CONTENT_ERROR_NONE) {
      debugPrint(
        'Failed to connect to media db ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
      );
    } else {
      _connected = true;
    }
  }

  static void disconnect() {
    if (!_connected) return;

    //return 되는 error다름, connect 된게 없는 경우 operation failed
    // connection이 있는 경우 ref count 감소 0보다 작아지면 error(operation failed)
    int ret = tizen.media_content_disconnect();
    if (ret != media_content_error_e.MEDIA_CONTENT_ERROR_NONE) {
      debugPrint(
        'Failed to disconnect to media db ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
      );
    } else {
      _connected = false;
    }
  }

  static void getFolderList() {
    folders.clear();
    using((Arena arena) {
      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);

      final folderCallback = Pointer.fromFunction<media_folder_cbFunction>(
        _getFolder,
        false,
      );

      ret = tizen.media_folder_foreach_folder_from_db(
        filterHandlePtr.value,
        folderCallback,
        nullptr,
      );
      debugPrint('ret=$ret, ${tizen.get_error_message(ret).toDartString()}');
      tizen.media_filter_destroy(filterHandlePtr.value);
    });
  }

  static bool _getMediaAlbum(
    Pointer<media_album_s> media_album,
    Pointer<Void> usr_data,
  ) {
    final albumPtr = media_album.cast<media_album_s>();

    using((Arena arena) {
      final id = arena<Int>();
      if (tizen.media_album_get_album_id(albumPtr, id) == 0) {
        // debugPrint('###### id: ${id.value}');
      }
      final name = arena<Pointer<Char>>();
      if (tizen.media_album_get_name(albumPtr, name) == 0) {
        // debugPrint('###### album: ${name.value.toDartString()}');
      }

      final artist = arena<Pointer<Char>>();
      if (tizen.media_album_get_artist(albumPtr, artist) == 0) {
        // debugPrint('###### artist: ${artist.value.toDartString()}');
      }
      //media_album_get_album_art
      // art가 없는 경우 media_album_get_album_art 성공하지만 albumArt.value == nullptr (null아님)
      final albumArt = arena<Pointer<Char>>();
      int ret = tizen.media_album_get_album_art(albumPtr, albumArt);
      // debugPrint(
      //   'media_album_get_album_art ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
      // );
      if (ret == 0) {
        try {
          debugPrint("albumArt==null? ${albumArt == nullptr}");
          debugPrint("albumArt.value==null? ${albumArt.value == nullptr}");
        } catch (e) {
          debugPrint('$e');
        }
      }
    });

    // debugPrint('folders length: ${folders.length}');
    return true;
  }

  static String readCString(Pointer<Char> ptr) {
    int length = 0;
    while (ptr[length] != 0) {
      length++;
    }
    debugPrint('string?  length=$length');
    final bytes = ptr.cast<Uint8>().asTypedList(length);
    return utf8.decode(bytes, allowMalformed: true);
  }

  static void getAlbumItems() {
    using((Arena arena) {
      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);
      if (ret != media_content_error_e.MEDIA_CONTENT_ERROR_NONE) {
        debugPrint(
          'Failed to call media_filter_create ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      final condition = "";
      tizen.media_filter_set_condition(
        filterHandlePtr.value,
        condition.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_RTRIM,
      );

      tizen.media_filter_set_order(
        filterHandlePtr.value,
        media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
        MEDIA_DISPLAY_NAME.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_NOCASE,
      );

      final albumCallback = Pointer.fromFunction<media_album_cbFunction>(
        _getMediaAlbum,
        false,
      );

      // all: filter == null
      ret = tizen.media_album_foreach_album_from_db(
        filterHandlePtr.value,
        albumCallback,
        nullptr,
      );
      if (ret != media_content_error_e.MEDIA_CONTENT_ERROR_NONE) {
        debugPrint(
          'Failed to call media_album_foreach_album_from_db ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      tizen.media_filter_destroy(filterHandlePtr.value);
    });
  }

  static bool _getMediaCallback(
    Pointer<media_info_s> media_info,
    Pointer<Void> usr_data,
  ) {
    // debugPrint('###### _getMediaCallback, req=${usr_data.address}');
    final mediaInfoPtr = media_info.cast<media_info_s>();

    final list = _map.putIfAbsent(usr_data.address, () => []);

    using((Arena arena) {
      final id = arena<Pointer<Char>>();
      if (tizen.media_info_get_media_id(mediaInfoPtr, id) == 0) {
        // debugPrint('###### id: ${id.value.toDartString()}');
      }

      final type = arena<Int32>();
      if (tizen.media_info_get_media_type(mediaInfoPtr, type) == 0) {
        // debugPrint('###### type: ${type.value}');
      }

      final name = arena<Pointer<Char>>();
      if (tizen.media_info_get_display_name(mediaInfoPtr, name) == 0) {
        // debugPrint('###### name: ${name.value.toDartString()}');
      }

      final title = arena<Pointer<Char>>();
      if (tizen.media_info_get_title(mediaInfoPtr, title) == 0) {
        // debugPrint('###### title: ${title.value.toDartString()}');
      }

      final size = arena<UnsignedLongLong>();
      if (tizen.media_info_get_size(mediaInfoPtr, size) == 0) {
        // debugPrint('###### size: ${size.value}'); //byte
      }

      final filePath = arena<Pointer<Char>>();
      if (tizen.media_info_get_file_path(mediaInfoPtr, filePath) == 0) {
        // debugPrint('###### filePath: ${filePath.value.toDartString()}');
      }

      final modifiedTime = arena<time_t>();
      DateTime? dateTime;
      if (tizen.media_info_get_modified_time(mediaInfoPtr, modifiedTime) == 0) {
        // debugPrint('##### modifiedTime: ${modifiedTime.value}');
        dateTime = DateTime.fromMillisecondsSinceEpoch(
          modifiedTime.value * 1000,
        );
        // debugPrint('##### dateTime: $dateTime');
      }

      String thumbnailPath =
          '/opt/usr/home/owner/share/media/.thumb/.jpg-${id.value.toDartString()}.jpg';

      if (!File(thumbnailPath).existsSync()) {
        int ret = tizen.thumbnail_util_extract_to_file(
          filePath.value,
          100,
          100,
          thumbnailPath.toNativeChar(allocator: arena),
        );
        if (ret != 0) {
          debugPrint(
            'thumbnail_util_extract_to_file, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
          );
          thumbnailPath = '';
        }
      }

      list.add(
        MediaContentInfo(
          id: id.value.toDartString(),
          filePath: filePath.value.toDartString(),
          name: name.value.toDartString(),
          size: size.value,
          thumbnailPath: thumbnailPath,
          title: title.value.toDartString(),
          modifiedTime: dateTime,
          type: MediaType.values[type.value],
        ),
      );
    });

    // debugPrint(' list length: ${list.length}');
    return true;
  }

  static bool _getMediaCallbackForSize(
    Pointer<media_info_s> media_info,
    Pointer<Void> usr_data,
  ) {
    // debugPrint('###### _getMediaCallback, req=${usr_data.address}');
    final mediaInfoPtr = media_info.cast<media_info_s>();

    final list = _map.putIfAbsent(usr_data.address, () => []);

    using((Arena arena) {
      // final id = arena<Pointer<Char>>();
      // if (tizen.media_info_get_media_id(mediaInfoPtr, id) == 0) {
      //   // debugPrint('###### id: ${id.value.toDartString()}');
      // }

      final type = arena<Int32>();
      if (tizen.media_info_get_media_type(mediaInfoPtr, type) == 0) {
        // debugPrint('###### type: ${type.value}');
      }

      // final name = arena<Pointer<Char>>();
      // if (tizen.media_info_get_display_name(mediaInfoPtr, name) == 0) {
      //   // debugPrint('###### name: ${name.value.toDartString()}');
      // }

      // final title = arena<Pointer<Char>>();
      // if (tizen.media_info_get_title(mediaInfoPtr, title) == 0) {
      //   // debugPrint('###### title: ${title.value.toDartString()}');
      // }

      final size = arena<UnsignedLongLong>();
      if (tizen.media_info_get_size(mediaInfoPtr, size) == 0) {
        // debugPrint('###### size: ${size.value}'); //byte
      }

      // final filePath = arena<Pointer<Char>>();
      // if (tizen.media_info_get_file_path(mediaInfoPtr, filePath) == 0) {
      //   // debugPrint('###### filePath: ${filePath.value.toDartString()}');
      // }

      // final modifiedTime = arena<time_t>();
      // DateTime? dateTime;
      // if (tizen.media_info_get_modified_time(mediaInfoPtr, modifiedTime) == 0) {
      //   // debugPrint('##### modifiedTime: ${modifiedTime.value}');
      //   dateTime = DateTime.fromMillisecondsSinceEpoch(
      //     modifiedTime.value * 1000,
      //   );
      //   // debugPrint('##### dateTime: $dateTime');
      // }
      list.add(
        MediaContentInfo(
          id: '',
          filePath: '',
          name: '',
          size: size.value,
          thumbnailPath: '',
          title: '',
          type: MediaType.values[type.value],
        ),
      );
    });

    // debugPrint(' list length: ${list.length}');
    return true;
  }

  static List<MediaContentInfo> getRecentMediaContentInfo(int itemCount) {
    return using((Arena arena) {
      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);
      if (ret != 0) {
        debugPrint(
          'Failed to call media_filter_create, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      final condition =
          "$MEDIA_TYPE = ${media_content_type_e.MEDIA_CONTENT_TYPE_IMAGE} OR $MEDIA_TYPE = ${media_content_type_e.MEDIA_CONTENT_TYPE_VIDEO}";
      debugPrint('condition=$condition');

      tizen.media_filter_set_order(
        filterHandlePtr.value,
        media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
        MEDIA_ADDED_TIME.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      tizen.media_filter_set_offset(filterHandlePtr.value, 0, itemCount);

      tizen.media_filter_set_condition(
        filterHandlePtr.value,
        condition.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      final getMediaCallback = Pointer.fromFunction<media_info_cbFunction>(
        _getMediaCallback,
        false,
      );

      final requestId = _req++;
      _map[requestId] = [];

      ret = tizen.media_info_foreach_media_from_db(
        filterHandlePtr.value,
        getMediaCallback,
        intToPointer(requestId),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to call media_info_foreach_media_from_db, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }

      tizen.media_filter_destroy(filterHandlePtr.value);

      return _map.remove(requestId) ?? <MediaContentInfo>[];
    });
  }

  static Pointer<Void> intToPointer(int value) {
    return Pointer.fromAddress(value);
  }

  static List<MediaContentInfo> getMediaContentInfo(MediaType type) {
    return using((Arena arena) {
      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);
      if (ret != 0) {
        debugPrint(
          'Failed to call media_filter_create, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      final condition = "$MEDIA_TYPE = ${type.index}";
      debugPrint('condition=$condition');

      tizen.media_filter_set_condition(
        filterHandlePtr.value,
        condition.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      tizen.media_filter_set_order(
        filterHandlePtr.value,
        media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
        MEDIA_ADDED_TIME.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      final getMediaCallback = Pointer.fromFunction<media_info_cbFunction>(
        _getMediaCallback,
        false,
      );

      final requestId = _req++;
      _map[requestId] = [];

      ret = tizen.media_info_foreach_media_from_db(
        filterHandlePtr.value,
        getMediaCallback,
        intToPointer(requestId),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to call media_info_foreach_media_from_db, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      tizen.media_filter_destroy(filterHandlePtr.value);

      return _map.remove(requestId) ?? <MediaContentInfo>[];
    });
  }

  static List<MediaContentInfo> getAllMediaContentForSize(String condition) {
    return using((Arena arena) {
      final filterHandlePtr = arena<filter_h>();
      int ret = tizen.media_filter_create(filterHandlePtr);
      if (ret != 0) {
        debugPrint(
          'Failed to call media_filter_create, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      debugPrint('condition=$condition');

      tizen.media_filter_set_condition(
        filterHandlePtr.value,
        condition.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      tizen.media_filter_set_order(
        filterHandlePtr.value,
        media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
        MEDIA_ADDED_TIME.toNativeChar(allocator: arena),
        media_content_collation_e.MEDIA_CONTENT_COLLATE_DEFAULT,
      );

      final getMediaCallback = Pointer.fromFunction<media_info_cbFunction>(
        _getMediaCallbackForSize,
        false,
      );

      final requestId = _req++;
      _map[requestId] = [];

      ret = tizen.media_info_foreach_media_from_db(
        filterHandlePtr.value,
        getMediaCallback,
        intToPointer(requestId),
      );
      if (ret != 0) {
        debugPrint(
          'Failed to call media_info_foreach_media_from_db, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      tizen.media_filter_destroy(filterHandlePtr.value);

      return _map.remove(requestId) ?? <MediaContentInfo>[];
    });
  }

  static void _scanCompleteCallback(int result, Pointer<Void> user_data) {
    if (_completer != null && !_completer!.isCompleted) {
      debugPrint('_scanCompleteCallback: result=$result');
      _completer!.complete(true);
      _completer = null;
    }
  }

  static RegisteredCallback<media_scan_completed_cbFunction>
  _registerScanCallback() {
    return _callbacks.register<media_scan_completed_cbFunction>(
      'media_scan_completed_cb',
      Pointer.fromFunction(_scanCompleteCallback),
      userObject: nullptr,
      blocking: false,
    );
  }

  static Future<bool> scan(String directoryPath) async {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(false);
      _completer = null;
    }

    _completer = Completer<bool>();

    if (!_connected) {
      connect();
    }

    return using((Arena arena) {
      int ret = tizen.media_content_scan_folder(
        directoryPath.toNativeChar(allocator: arena),
        true,
        _scan_cb.interopCallback,
        _scan_cb.interopUserData,
      );
      if (ret != 0) {
        debugPrint(
          'Failed to call media_content_scan_folder, ret=$ret,  ${tizen.get_error_message(ret).toDartString()}',
        );
      }
      return _completer!.future;
    });
  }
}
