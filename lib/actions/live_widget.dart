import 'package:flutter/material.dart';
import 'package:tizen_fs/router.dart';
import 'package:tizen_fs/router_service.dart';

class LiveWidget extends StatefulWidget {
  const LiveWidget({super.key, required this.url});

  final String url;

  @override
  State<LiveWidget> createState() => LiveWidgetState();
}

class LiveWidgetState extends State<LiveWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: ElevatedButton(
          onPressed: () {
            RouterService.instance.safePush(
              ScreenPaths.live,
              extra: {'title': '', 'url': widget.url},
            );
          },
          child: Text('watch now'),
        ),
      ),
    );
  }
}
