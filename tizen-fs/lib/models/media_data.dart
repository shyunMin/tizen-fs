/*
// image = 0
// video = 1
// sound = 2
// music = 3
 */
enum MediaType { image, video, sound, music, other, book }

class FolderInfo extends MediaContentInfo {
  String folderId;
  String path;
  int itemCount;

  FolderInfo({
    this.folderId = '',
    name = '',
    title = '',
    this.path = '',
    this.itemCount = 0,
    type = MediaType.other,
  }) : super(
         id: folderId,
         filePath: path,
         name: name,
         size: 0,
         thumbnailPath: '',
         title: title,
         type: type,
       ) {}
}

class MediaContentInfo {
  String id;
  String filePath;
  String name;
  int size;
  String thumbnailPath;
  String title;
  DateTime? modifiedTime;
  MediaType type;

  MediaContentInfo({
    required this.id,
    required this.filePath,
    required this.name,
    required this.size,
    required this.thumbnailPath,
    required this.title,
    required this.type,
    this.modifiedTime,
  }) {}
}

class AudioInfo extends MediaContentInfo {
  String artist;
  int trackNumber;

  AudioInfo({
    this.artist = '',
    this.trackNumber = 0,
    required id,
    required filePath,
    required name,
    int? size,
    String? thumbnailPath,
    String? title,
    MediaType type = MediaType.music,
  }) : super(
         id: id,
         filePath: filePath,
         name: name,
         size: size ?? 0,
         thumbnailPath: thumbnailPath ?? '',
         title: title ?? '',
         type: type,
       ) {}
}

class VideoInfo extends MediaContentInfo {
  VideoInfo({
    required id,
    required filePath,
    required name,
    int? size,
    String? thumbnailPath,
    String? title,
    MediaType type = MediaType.video,
  }) : super(
         id: id,
         filePath: filePath,
         name: name,
         size: size ?? 0,
         thumbnailPath: thumbnailPath ?? '',
         title: title ?? '',
         type: type,
       ) {}
}

class ImageInfo extends MediaContentInfo {
  int width;
  int height;

  ImageInfo({
    this.width = 0,
    this.height = 0,
    required id,
    required filePath,
    required name,
    int? size,
    String? thumbnailPath,
    String? title,
    MediaType type = MediaType.image,
  }) : super(
         id: id,
         filePath: filePath,
         name: name,
         size: size ?? 0,
         thumbnailPath: thumbnailPath ?? '',
         title: title ?? '',
         type: type,
       ) {}
}
