import 'package:flutter/material.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/widgets/lottie_view.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget createEmptyView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            LottieView(
              assetPath: 'assets/animation/music_no_item.json',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return createEmptyView();
  }
}
