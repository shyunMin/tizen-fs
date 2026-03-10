import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/models/item_display_interface.dart';
import 'package:tizen_fs/styles/app_style.dart';

class ItemView<T extends ItemDisplayInterface> extends StatelessWidget {
  const ItemView({
    super.key,
    required this.item,
    required this.isFocused,
    this.onTap,
  });

  final T item;
  final bool isFocused;
  final VoidCallback? onTap;

  final double titleFontSize = 15;
  final double subtitleFontSize = 11;
  final double itemHeight = 65;
  final int iconSize = 80;

  @protected
  bool get hasIcon => item.iconSourceData != null;

  @protected
  bool get hasSubText => item.displaySubText != null;

  @protected
  bool get canReceiveFocus => item.isSelectable;

  @protected
  Widget _loadIcon() {
    if (item.iconSourceData == null) return Container();

    if (item.iconSourceType == IconSourceType.icon) {
      return _genIcon();
    } else if (item.iconSourceType == IconSourceType.color) {
      return _genColorBoxIcon();
    } else if (item.iconSourceType == IconSourceType.uri) {
      return _genImageIcon();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:
            canReceiveFocus && Focus.of(context).hasFocus && isFocused
                ? Theme.of(context).colorScheme.tertiary
                : Colors.transparent,
      ),
      child: Opacity(
        opacity: canReceiveFocus ? 1.0 : 0.5,
        child: ListTile(
          onTap: canReceiveFocus ? onTap : null,
          // minTileHeight: hasSubText ? itemHeight : 82,
          minTileHeight: itemHeight,
          leading: (hasIcon) ? SizedBox(width: 40, child: _loadIcon()) : null,
          title: Text(
            getLocalizedTextByKey(context, item.displayText),
            style: TextStyle(
              fontSize: titleFontSize,
              color:
                  canReceiveFocus && Focus.of(context).hasFocus && isFocused
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle:
              (hasSubText)
                  ? Text(
                    item.displaySubText!,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Color(0xFF979AA0),
                    ),
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _genColorBoxIcon() {
    return Container(
      width: 40,
      height: 40,
      color: (item.iconSourceData as Color).withAlphaF(0.8),
    );
  }

  Widget _genImageIcon() {
    final iconUri = item.iconSourceData as String;

    if (iconUri.startsWith('/')) {
      final icon = Image.file(
        File(iconUri),
        cacheWidth: iconSize,
        errorBuilder:
            (context, error, stackTrace) => const Icon(Icons.broken_image),
        fit: BoxFit.fitHeight,
      );
      return icon;
    } else if (iconUri.startsWith('assets')) {
      final icon = Image.asset(
        iconUri,
        cacheWidth: iconSize,
        fit: BoxFit.fitHeight,
      );
      return icon;
    } else {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Color.fromARGB(255, 182, 114, 114),
        ),
      );
    }
  }

  Widget _genIcon() {
    return Container(
      width: 43, //iconSize * 1.75,
      height: 43, //iconSize * 1.75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isFocused ? Color(0xF04285F4).withAlphaF(0.2) : Color(0xF0263041),
      ),
      child: SizedBox(
        width: 40,
        child: Icon(
          item.iconSourceData as IconData,
          size: 25,
          color: isFocused ? Color(0xF04285F4) : Color(0xF0AEB2B9),
        ),
      ),
    );
  }
}
