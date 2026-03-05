import 'package:flutter/material.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/native/content_manager.dart';

abstract class MediaContentProvider<T> extends ChangeNotifier {
  final List<T> _items = [];

  List<T> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<List<T>> fetchFromDb();

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final result = await fetchFromDb();

    _items
      ..clear()
      ..addAll(result);

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    ContentManager.disconnect();
    super.dispose();
  }
}

class ImageContentProvider extends MediaContentProvider<MediaContentInfo> {
  @override
  Future<List<MediaContentInfo>> fetchFromDb() async {
    final mediaDirectoryPath = '/opt/usr/home/owner/media';
    await ContentManager.scan(mediaDirectoryPath);
    final list = ContentManager.getMediaContentInfo(MediaType.image);
    return list;
  }
}

class VideoContentProvider extends MediaContentProvider<MediaContentInfo> {
  @override
  Future<List<MediaContentInfo>> fetchFromDb() async {
    final mediaDirectoryPath = '/opt/usr/home/owner/media';
    await ContentManager.scan(mediaDirectoryPath);
    final list = ContentManager.getMediaContentInfo(MediaType.video);
    return list;
  }
}

class RecentFileProvider extends MediaContentProvider<MediaContentInfo> {
  @override
  Future<List<MediaContentInfo>> fetchFromDb() async {
    final mediaDirectoryPath = '/opt/usr/home/owner/media';
    await ContentManager.scan(mediaDirectoryPath);
    return ContentManager.getRecentMediaContentInfo(5);
  }
}
