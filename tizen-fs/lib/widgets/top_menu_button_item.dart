import 'package:flutter/material.dart';
import 'package:tizen_fs/generated/localization_map_helper.g.dart';
import 'package:tizen_fs/styles/app_style.dart';

class TopMenuButtonItem extends StatelessWidget {
  const TopMenuButtonItem({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isFocused,
    this.onPressed,
  });
  final bool isSelected;
  final bool isFocused;
  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.surface;
    final Color defautTextColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          color: baseColor.withAlphaF(
            isSelected
                ? isFocused
                    ? 0.9
                    : 0.15
                : 0.0,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          child: Text(
            getLocalizedTextByKey(context, text),
            style: TextStyle(
              color:
                  isSelected
                      ? isFocused
                          ? textColor
                          : defautTextColor
                      : defautTextColor,
              fontSize: 16,
              fontWeight:
                  isSelected
                      ? isFocused
                          ? FontWeight.w600
                          : FontWeight.w400
                      : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
