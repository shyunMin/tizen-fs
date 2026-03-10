import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/media/media_grid.dart';
import 'package:tizen_fs/widgets/video_player_view.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/providers/media_data_provider.dart';
import 'package:tizen_fs/widgets/lottie_view.dart';
import '../l10n/app_localizations.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => VideoContentProvider()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.videos),
          titleSpacing: 5,
          leading: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  Navigator.pop(context);
                }
              }
              return KeyEventResult.ignored;
            },
            child: Builder(
              builder: (context) {
                final hasFocus = Focus.of(context).hasFocus;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back,
                        color: hasFocus ? Colors.black : Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            hasFocus ? Colors.white : Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: Consumer<VideoContentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (provider.items.isNotEmpty) {
                return MediaGridView(
                  items: provider.items,
                  onItemSelected: (selected) {
                    _openfile(provider.items[selected]);
                  },
                );
              } else {
                return _createEmptyView(localizations.videos);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _createEmptyView(String title) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          LottieView(
            assetPath: 'assets/animation/video_no_item.json',
            width: 450,
            height: 120,
            autoplay: true,
            loop: true,
          ),
          Text(
            AppLocalizations.of(context).noFileFound,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  void _openfile(MediaContentInfo item) async {
    debugPrint('open :${item.name}');

    if (item.type == MediaType.video) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => VideoPlayerView(title: item.title, url: item.filePath),
        ),
      );
    }
  }
}
