import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tizen_fs/models/app_data.dart';
import 'package:tizen_fs/styles/app_style.dart';

class AppTile extends StatelessWidget {
  const AppTile({super.key, required this.app});

  final AppData app;

  final int _iconWidth = 80;

  Widget _loadIcon() {
    final iconUrl = app.icon;

    if (iconUrl.startsWith('/')) {
      final icon = Image.file(
        File(iconUrl),
        cacheWidth: _iconWidth,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
        fit: BoxFit.fitHeight,
      );
      return icon;
    } else if (iconUrl.startsWith('assets')) {
      final icon = Image.asset(
        iconUrl,
        cacheWidth: _iconWidth,
        fit: BoxFit.fitHeight,
      );
      return icon;
    } else {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  Color getAppColor() {
    if (app.appType.toLowerCase().contains('dotnet')) {
      return $style.colors.dotnetApp;
    } else if (app.appType.toLowerCase().contains('capp')) {
      return $style.colors.cApp;
    } else if (app.appType.toLowerCase().contains('webapp')) {
      return $style.colors.webApp;
    }
    return $style.colors.defaulApp;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: getAppColor()),
        Center(child: SizedBox(width: 50, child: _loadIcon())),
      ],
    );
  }
}
