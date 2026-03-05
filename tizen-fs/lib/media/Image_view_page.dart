import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage({super.key, required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
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
      body: Center(
        child: Image.file(
          File(imageUrl),
          errorBuilder:
              (context, error, stackTrace) => const Icon(Icons.broken_image),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
