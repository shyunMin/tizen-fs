import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/media/Image_view_page.dart';
import 'package:tizen_fs/media/Images_page.dart';
import 'package:tizen_fs/media/media_list_view.dart';
import 'package:tizen_fs/media/music_page.dart';
import 'package:tizen_fs/media/videos_page.dart';
import 'package:tizen_fs/widgets/video_player_view.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/providers/media_data_provider.dart';
import '../l10n/app_localizations.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late final List<FolderInfo> _categories = _createMediaCategories();

  List<FolderInfo> _createMediaCategories() {
    return [
      FolderInfo(title: 'Images', type: MediaType.image),
      FolderInfo(title: 'Videos', type: MediaType.video),
      // FolderInfo(title: 'Music', type: MediaType.music),
    ];
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Provider.of<RecentFileProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 58, vertical: 20),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceEvenly, // Distributes space evenly between children.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<RecentFileProvider>(
            builder: (context, provider, _) {
              if (provider.items.isEmpty) {
                return SizedBox(height: 0);
              } else {
                return MediaListView<MediaContentInfo>(
                  title: localizations.recentFiles,
                  items: provider.items,

                  onItemSelected: (selected) {
                    _openfile(provider.items[selected]);
                  },
                );
              }
            },
          ),
          MediaListView<FolderInfo>(
            title: localizations.categories,
            items: _categories,
            itemBuilder: _createFolderItem,
            onItemSelected: (selected) {
              _pushPage(_categories[selected].type);
            },
          ),
        ],
      ),
    );
  }

  void _openfile(MediaContentInfo item) {
    debugPrint('open :${item.name}');

    if (item.type == MediaType.video) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => VideoPlayerView(title: item.title, url: item.filePath),
        ),
      );
    } else if (item.type == MediaType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ImageViewPage(name: item.title, imageUrl: item.filePath),
        ),
      );
    }
  }

  void _pushPage(MediaType type) {
    if (type == MediaType.image) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ImagesPage()));
    } else if (type == MediaType.video) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => VideosPage()));
    } else if (type == MediaType.music) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MusicPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ImagesPage()));
    }
  }

  Widget _createFolderItem(
    BuildContext context,
    int index,
    int selected,
    FolderInfo folder,
  ) {
    IconData iconData;

    if (folder.type == MediaType.image) {
      iconData = Icons.image_outlined;
    } else if (folder.type == MediaType.video) {
      iconData = Icons.video_library_outlined;
    } else if (folder.type == MediaType.music) {
      iconData = Icons.music_note_outlined;
    } else {
      iconData = Icons.file_copy_outlined;
    }

    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Icon(iconData, size: 25),
            Text(
              _gettitle(context, folder.title),
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _gettitle(BuildContext context, String title) {
    final localizations = AppLocalizations.of(context);
    if (title.toLowerCase() == 'images') {
      return localizations.images;
    } else if (title.toLowerCase() == 'videos') {
      return localizations.videos;
    }
    return '';
  }
}
