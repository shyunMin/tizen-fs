import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tizen_fs/widgets/blink_border.dart';

enum MediaCardRatio { wide, square, poster, circle }

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    this.width = 196,
    required this.imageUrl,
    this.imageWidth,
    this.title,
    this.subtitle,
    this.description,
    this.isSelected = false,
    this.duration,
    this.ratio = MediaCardRatio.wide,
    this.shadowColor,
    this.content,
    this.onRequestSelect,
  }) : height =
           width *
           (ratio == MediaCardRatio.wide
               ? 9 / 16
               : ratio == MediaCardRatio.square
               ? 1
               : 3 / 2);

  const MediaCard.oneCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 844,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.twoCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 416,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.threeCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 268,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.fourCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 196,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.fiveCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 152,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.sixCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 124,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.nineCard({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    MediaCardRatio ratio = MediaCardRatio.wide,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 80,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: ratio,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.circle({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 80,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: MediaCardRatio.circle,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  const MediaCard.circleLarge({
    Key? key,
    required String imageUrl,
    int? imageWidth,
    String? title,
    String? subtitle,
    String? description,
    String? duration,
    bool isSelected = false,
    Widget? content,
    Color? shadowColor,
    void Function()? onRequestSelect,
  }) : this(
         key: key,
         width: 124,
         imageUrl: imageUrl,
         imageWidth: imageWidth,
         title: title,
         subtitle: subtitle,
         description: description,
         duration: duration,
         isSelected: isSelected,
         ratio: MediaCardRatio.circle,
         content: content,
         onRequestSelect: onRequestSelect,
         shadowColor: shadowColor,
       );

  static const int animationDuration = 100;
  static const double _fontSize = 10;

  final double width;
  final double height;
  final String imageUrl;
  final int? imageWidth;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? duration;
  final bool isSelected;
  final MediaCardRatio ratio;
  final Color? shadowColor;
  final Widget? content;
  final void Function()? onRequestSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onRequestSelect?.call(),
      child: Column(
        spacing: 1,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.1 : 1,
            duration: Duration(milliseconds: animationDuration),
            child: Stack(
              children: [
                _buildBorder(
                  ratio == MediaCardRatio.circle
                      ? ClipOval(child: _buildTileContent())
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildTileContent(),
                      ),
                ),
                if (duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.black.withAlphaF(0.8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      child: Text(
                        duration!,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (title != null || subtitle != null || description != null)
            SizedBox(height: 3),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: SizedBox(
                width: width,
                child: Text(
                  title!,
                  style: TextStyle(
                    fontSize: (description != null) ? 12 : _fontSize,
                    color:
                        (description != null)
                            ? Colors.white.withAlphaF(0.8)
                            : (isSelected
                                ? Colors.white.withAlphaF(0.8)
                                : Colors.transparent),
                  ),
                  maxLines: 1,
                  textAlign:
                      (description != null) ? TextAlign.left : TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: SizedBox(
                width: width,
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: $style.colors.onPrimary.withAlphaF(
                      (isSelected ? 1 : 0.9),
                    ),
                  ),
                  maxLines: 1,
                  textAlign:
                      ratio == MediaCardRatio.circle
                          ? TextAlign.center
                          : TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: SizedBox(
                width: width,
                child: Text(
                  description!,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: $style.colors.onPrimary.withAlphaF(
                      (isSelected ? 1 : 0.9),
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBorder(Widget content) {
    final shadow = shadowColor ?? Colors.grey.shade600;
    return isSelected
        ? BlinkBorder(
          borderRadius:
              ratio != MediaCardRatio.circle ? BorderRadius.circular(10) : null,
          child: Container(
            width: width,
            height: height.roundToDouble(),
            decoration: BoxDecoration(
              shape:
                  ratio == MediaCardRatio.circle
                      ? BoxShape.circle
                      : BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: shadow.withAlphaF(0.9),
                  spreadRadius: 1,
                  blurRadius: 11,
                  blurStyle: BlurStyle.normal,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: content,
          ),
        )
        : SizedBox(
          width: width,
          height: height.roundToDouble(),
          child: content,
        );
  }

  Widget _buildTileContent() {
    var cacheWidth = (width * 2).round();

    if (imageWidth != null) {
      cacheWidth = (cacheWidth > imageWidth!) ? imageWidth! : cacheWidth;
    }

    if (content != null) {
      return content!;
    } else if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        memCacheWidth: cacheWidth,
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        cacheWidth: cacheWidth,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('assets')) {
      return Image.asset(imageUrl, cacheWidth: cacheWidth, fit: BoxFit.cover);
    } else {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }
}
