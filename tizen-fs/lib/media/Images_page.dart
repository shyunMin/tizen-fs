import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/media/Image_view_page.dart';
import 'package:tizen_fs/media/media_grid.dart';
import 'package:tizen_fs/models/media_data.dart';
import 'package:tizen_fs/providers/media_data_provider.dart';
import 'package:tizen_fs/widgets/lottie_view.dart';

import '../l10n/app_localizations.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => ImageContentProvider()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.images),
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
        body: Consumer<ImageContentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (provider.items.isNotEmpty) {
                return MediaGridView(
                  items: provider.items,
                  onItemSelected: (selected) {
                    debugPrint(
                      'open item: ${provider.items[selected].filePath}',
                    );
                    _openfile(provider.items[selected]);
                  },
                );
              } else {
                return _createEmptyView();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _createEmptyView() {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          LottieView(
            assetPath: 'assets/animation/image_no_item.json',
            width: 450,
            height: 120,
            autoplay: true,
            loop: true,
          ),
          Text(localizations.noFileFound, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  void _openfile(MediaContentInfo item) {
    debugPrint('open :${item.name}');

    if (item.type == MediaType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ImageViewPage(name: item.title, imageUrl: item.filePath),
        ),
      );
    }
  }
}
