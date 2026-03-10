// import 'dart:convert';
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:ffi/ffi.dart';
// import 'package:tizen_interop/9.0/tizen.dart';
// import 'package:tizen_interop_callbacks/tizen_interop_callbacks.dart';

// class MediaFolder {
//   String folderId;
//   String name;
//   String path;
//   int itemCount;

//   MediaFolder({
//     this.folderId = '',
//     this.name = '',
//     this.path = '',
//     this.itemCount = 0,
//   });
// }

// class MediaContentInfo {
//   String id;
//   String filePath;
//   String name;
//   int size;
//   String thumbnailPath;
//   String title;

//   MediaContentInfo({
//     required this.id,
//     required this.filePath,
//     required this.name,
//     required this.size,
//     required this.thumbnailPath,
//     required this.title,
//   }) {}
// }

// class AudioInfo extends MediaContentInfo {
//   String artist;
//   int trackNumber;

//   AudioInfo({
//     this.artist = '',
//     this.trackNumber = 0,
//     required id,
//     required filePath,
//     required name,
//     int? size,
//     String? thumbnailPath,
//     String? title,
//   }) : super(
//          id: id,
//          filePath: filePath,
//          name: name,
//          size: size ?? 0,
//          thumbnailPath: thumbnailPath ?? '',
//          title: title ?? '',
//        ) {}
// }

// class VideoInfo extends MediaContentInfo {
//   VideoInfo({
//     required id,
//     required filePath,
//     required name,
//     int? size,
//     String? thumbnailPath,
//     String? title,
//   }) : super(
//          id: id,
//          filePath: filePath,
//          name: name,
//          size: size ?? 0,
//          thumbnailPath: thumbnailPath ?? '',
//          title: title ?? '',
//        ) {}
// }

// class ImageInfo extends MediaContentInfo {
//   int width;
//   int height;
//   //orientation

//   ImageInfo({
//     this.width = 0,
//     this.height = 0,
//     required id,
//     required filePath,
//     required name,
//     int? size,
//     String? thumbnailPath,
//     String? title,
//   }) : super(
//          id: id,
//          filePath: filePath,
//          name: name,
//          size: size ?? 0,
//          thumbnailPath: thumbnailPath ?? '',
//          title: title ?? '',
//        ) {}
// }

// class ContentManager {
//   bool _connected = false;
//   bool get connected => _connected;

//   static List<MediaFolder> folders = [];
//   static final TizenInteropCallbacks _callbacks = TizenInteropCallbacks();
//   static late final _update_cb = _registerUpdateCallback();
//   static late final Pointer<Pointer<Void>> _notiHandle = _createNotiHandle();

//   static late final _scan_cb = _registerScanCallback();

//   ContentManager() {}

//   void dispose() {
//     unsetUpdateCallback();
//     _callbacks.unregister(_update_cb);
//   }

//   static void _dbUpdated(
//     int error,
//     int pid,
//     int update_item,
//     int update_type,
//     int media_type,
//     Pointer<Char> id,
//     Pointer<Char> path,
//     Pointer<Char> mime_type,
//     Pointer<Void> user_data,
//   ) {
//     // media folder에 파일이 추가/삭제 되어도 callback 불리지 않음,
//     // 다른 app에서 insert_db 와 같은 db update 함수를 호출 해야 호출 될 것으로 보임 -> 현재 home 시나리오에서 당장은 사용하지 않을 것으로 보임
//     // scan 호출해야 해당 callback 불림 -> scan - get media item으로 처리 가능
//     try {
//       // Pointer<char> data 쓸 수 없음(bt와 동일 이슈)
//       debugPrint('*****************db updated');
//       debugPrint('id=${id.toDartString()}, path=${path.toDartString()}');
//       debugPrint(
//         'error=$error, pid=$pid, update_item=$update_item, update_type=$update_type, media_type=$media_type',
//       );
//       debugPrint('*****************');
//     } catch (e) {
//       debugPrint('$e');
//     }
//   }

//   static RegisteredCallback<media_content_db_update_cbFunction>
//   _registerUpdateCallback() {
//     return _callbacks.register(
//       'media_content_db_update_cb',
//       Pointer.fromFunction(_dbUpdated),
//       userObject: nullptr,
//       blocking: false,
//     );
//   }

//   static Pointer<Pointer<Void>> _createNotiHandle() {
//     return calloc<media_content_noti_h>();
//   }

//   static void setUpdateCallback() {
//     int ret = tizen.media_content_add_db_updated_cb(
//       _update_cb.interopCallback,
//       _update_cb.interopUserData,
//       _notiHandle,
//     );
//     debugPrint(
//       'media_content_add_db_updated_cb ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//     );
//   }

//   static void unsetUpdateCallback() {
//     tizen.media_content_remove_db_updated_cb(_notiHandle.value);
//   }

//   static bool _getFolder(
//     Pointer<media_folder_s> media_folder,
//     Pointer<Void> user_data,
//   ) {
//     final folderPtr = media_folder.cast<media_folder_s>();
//     final folder = MediaFolder();
//     using((Arena arena) {
//       final id = arena<Pointer<Char>>();
//       if (tizen.media_folder_get_folder_id(folderPtr, id) == 0) {
//         folder.name = id.value.toDartString();
//         debugPrint('###### id: ${id.value.toDartString()}');
//       }
//       final name = arena<Pointer<Char>>();
//       if (tizen.media_folder_get_name(folderPtr, name) == 0) {
//         folder.name = name.value.toDartString();
//         debugPrint('###### folder: ${name.value.toDartString()}');
//       }

//       final path = arena<Pointer<Char>>();
//       if (tizen.media_folder_get_path(folderPtr, path) == 0) {
//         folder.name = path.value.toDartString();
//         debugPrint('###### path: ${path.value.toDartString()}');
//       }

//       final filterHandlePtr = arena<filter_h>();
//       int ret = tizen.media_filter_create(filterHandlePtr);

//       final count = arena<Int>();
//       if (tizen.media_folder_get_media_count_from_db(
//             id.value,
//             filterHandlePtr.value,
//             count,
//           ) ==
//           0) {
//         debugPrint('###### item count: ${count.value}');
//       }
//     });

//     // destory호출은 foreach가 종료된 다음이어야 함
//     // tizen.media_folder_destroy(media_folder);

//     debugPrint('folders length: ${folders.length}');
//     return true;
//   }

//   static void connect() {
//     // connect 호출시마다 ref count 증가
//     int ret = tizen.media_content_connect();
//     debugPrint(
//       'media_content_connect ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//     );
//   }

//   static void disconnect() {
//     //return 되는 error다름, connect 된게 없는 경우 operation failed
//     // connection이 있는 경우 ref count 감소 0보다 작아지면 error(operation failed)
//     int ret = tizen.media_content_disconnect();
//     debugPrint(
//       'media_content_disconnect ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//     );
//   }

//   static void getFolderList() {
//     folders.clear();
//     using((Arena arena) {
//       final filterHandlePtr = arena<filter_h>();
//       int ret = tizen.media_filter_create(filterHandlePtr);

//       final folderCallback = Pointer.fromFunction<media_folder_cbFunction>(
//         _getFolder,
//         false,
//       );

//       ret = tizen.media_folder_foreach_folder_from_db(
//         filterHandlePtr.value,
//         folderCallback,
//         nullptr,
//       );
//       debugPrint('ret=$ret, ${tizen.get_error_message(ret).toDartString()}');
//       tizen.media_filter_destroy(filterHandlePtr.value);
//     });
//   }

//   static bool _getMediaAlbum(
//     Pointer<media_album_s> media_album,
//     Pointer<Void> usr_data,
//   ) {
//     final albumPtr = media_album.cast<media_album_s>();

//     using((Arena arena) {
//       final id = arena<Int>();
//       if (tizen.media_album_get_album_id(albumPtr, id) == 0) {
//         debugPrint('###### id: ${id.value}');
//       }
//       final name = arena<Pointer<Char>>();
//       if (tizen.media_album_get_name(albumPtr, name) == 0) {
//         debugPrint('###### album: ${name.value.toDartString()}');
//       }

//       final artist = arena<Pointer<Char>>();
//       if (tizen.media_album_get_artist(albumPtr, artist) == 0) {
//         debugPrint('###### artist: ${artist.value.toDartString()}');
//       }

//       //media_album_get_album_art
//       // art가 없는 경우 media_album_get_album_art 성공하지만 albumArt.value == nullptr (null아님)
//       final albumArt = arena<Pointer<Char>>();
//       int ret = tizen.media_album_get_album_art(albumPtr, albumArt);
//       debugPrint(
//         'media_album_get_album_art ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//       );
//       if (ret == 0) {
//         try {
//           debugPrint("albumArt==null? ${albumArt == nullptr}");
//           debugPrint("albumArt.value==null? ${albumArt.value == nullptr}");
//         } catch (e) {
//           debugPrint('$e');
//         }
//       }
//     });

//     // tizen.media_album_destroy(media_album);

//     debugPrint('folders length: ${folders.length}');
//     return true;
//   }

//   static String readCString(Pointer<Char> ptr) {
//     int length = 0;
//     while (ptr[length] != 0) {
//       length++;
//     }
//     debugPrint('string?  length=$length');
//     final bytes = ptr.cast<Uint8>().asTypedList(length);
//     return utf8.decode(bytes, allowMalformed: true);
//   }

//   static void getAlbumItems() {
//     using((Arena arena) {
//       final filterHandlePtr = arena<filter_h>();
//       final result = tizen.media_filter_create(filterHandlePtr);
//       final condition = "";
//       tizen.media_filter_set_condition(
//         filterHandlePtr.value,
//         condition.toNativeChar(allocator: arena),
//         media_content_collation_e.MEDIA_CONTENT_COLLATE_RTRIM,
//       );

//       tizen.media_filter_set_order(
//         filterHandlePtr.value,
//         media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
//         MEDIA_DISPLAY_NAME.toNativeChar(allocator: arena),
//         media_content_collation_e.MEDIA_CONTENT_COLLATE_NOCASE,
//       );

//       final albumCallback = Pointer.fromFunction<media_album_cbFunction>(
//         _getMediaAlbum,
//         false,
//       );

//       // all: filter == null
//       final ret = tizen.media_album_foreach_album_from_db(
//         filterHandlePtr.value,
//         albumCallback,
//         nullptr,
//       );
//       debugPrint('ret=$ret, ${tizen.get_error_message(ret).toDartString()}');
//       tizen.media_filter_destroy(filterHandlePtr.value);
//     });
//   }

//   //media_info_h media, ffi.Pointer<ffi.Void> user_data
//   static bool _getMediaCallback(
//     Pointer<media_info_s> media_info,
//     Pointer<Void> usr_data,
//   ) {
//     debugPrint('###### _getMediaCallback');
//     final mediaInfoPtr = media_info.cast<media_info_s>();

//     using((Arena arena) {
//       final id = arena<Pointer<Char>>();
//       if (tizen.media_info_get_media_id(mediaInfoPtr, id) == 0) {
//         debugPrint('###### id: ${id.value.toDartString()}');
//       }

//       final type = arena<Int32>();
//       if (tizen.media_info_get_media_type(mediaInfoPtr, type) == 0) {
//         debugPrint('###### type: ${type}');
//       }

//       final name = arena<Pointer<Char>>();
//       if (tizen.media_info_get_display_name(mediaInfoPtr, name) == 0) {
//         debugPrint('###### name: ${name.value.toDartString()}');
//       }

//       final filePath = arena<Pointer<Char>>();
//       if (tizen.media_info_get_file_path(mediaInfoPtr, filePath) == 0) {
//         debugPrint('###### filePath: ${filePath.value.toDartString()}');
//       }

//       //Since 3.0, a thumbnail is not automatically extracted during media scanning.
//       //A thumbnail will be created only when media_info_create_thumbnail() is called by any application.
//       int ret = tizen.media_info_generate_thumbnail(mediaInfoPtr);
//       debugPrint(
//         'media_info_generate_thumbnail, ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//       );

//       // 썸네일 생성 직후 get path 호출해도 path가 리턴되지 않음
//       // 썸네일 생성 후에는 재부팅해도 해상 썸네일 유지
//       // /opt/usr/home/owner/share/media/.thumb/ 에 생성
//       // image, video 가능, mpx - unsupported content
//       final thumbnailPath = arena<Pointer<Char>>();
//       ret = tizen.media_info_get_thumbnail_path(mediaInfoPtr, thumbnailPath);
//       debugPrint(
//         'media_info_get_thumbnail_path, ret=$ret, ${tizen.get_error_message(ret).toDartString()}',
//       );
//       if (ret == 0) {
//         debugPrint(
//           '###### thumbnailPath: ${thumbnailPath.value.toDartString()}',
//         );
//       }

//       //destory required
//     });
//     // tizen.media_album_destroy(mediaInfoPtr);

//     debugPrint('folders length: ${folders.length}');
//     return true;
//   }

//   static void getMediaContentInfo() {
//     using((Arena arena) {
//       final filterHandlePtr = arena<filter_h>();
//       final result = tizen.media_filter_create(filterHandlePtr);
//       final condition =
//           "$MEDIA_TYPE = ${media_content_type_e.MEDIA_CONTENT_TYPE_IMAGE} OR $MEDIA_TYPE = ${media_content_type_e.MEDIA_CONTENT_TYPE_VIDEO} OR $MEDIA_TYPE = ${media_content_type_e.MEDIA_CONTENT_TYPE_MUSIC}";
//       debugPrint('condition=$condition');
//       // image = 0
//       // video = 1
//       // sound = 2
//       // music = 3
//       // conditon = MEDIA_TYPE = 0 OR MEDIA_TYPE = 1

//       tizen.media_filter_set_condition(
//         filterHandlePtr.value,
//         condition.toNativeChar(allocator: arena),
//         media_content_collation_e.MEDIA_CONTENT_COLLATE_NOCASE,
//       );

//       tizen.media_filter_set_order(
//         filterHandlePtr.value,
//         media_content_order_e.MEDIA_CONTENT_ORDER_DESC,
//         MEDIA_DISPLAY_NAME.toNativeChar(allocator: arena),
//         media_content_collation_e.MEDIA_CONTENT_COLLATE_NOCASE,
//       );

//       final getMediaCallback = Pointer.fromFunction<media_info_cbFunction>(
//         _getMediaCallback,
//         false,
//       );

//       // all: filter == null
//       final ret = tizen.media_info_foreach_media_from_db(
//         filterHandlePtr.value,
//         getMediaCallback,
//         nullptr,
//       );
//       debugPrint('ret=$ret, ${tizen.get_error_message(ret).toDartString()}');
//       tizen.media_filter_destroy(filterHandlePtr.value);
//     });
//   }

//   static void _scanCompleteCallback(int result, Pointer<Void> user_data) {
//     debugPrint('_scanCompleteCallback: result=$result');
//   }

//   static RegisteredCallback<media_scan_completed_cbFunction>
//   _registerScanCallback() {
//     return _callbacks.register<media_scan_completed_cbFunction>(
//       'media_scan_completed_cb',
//       Pointer.fromFunction(_scanCompleteCallback),
//       userObject: nullptr,
//       blocking: false,
//     );
//   }

//   static void scan() {
//     using((Arena arena) {
//       final mediaFoler = '/opt/usr/home/owner/media';
//       //media_scan_completed_cb
//       int ret = tizen.media_content_scan_folder(
//         mediaFoler.toNativeChar(allocator: arena),
//         true,
//         _scan_cb!.interopCallback,
//         _scan_cb!.interopUserData,
//       );
//     });
//   }
// }
