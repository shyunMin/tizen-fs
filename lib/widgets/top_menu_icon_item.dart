import 'package:flutter/material.dart';
import 'package:tizen_fs/styles/app_style.dart';

class TopMenuIconItem extends StatelessWidget {
  const TopMenuIconItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.hasFocus,
    this.onPressed,
  });
  final bool isSelected;
  final IconData icon;
  final bool hasFocus;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.surface;
    final Color defautTextColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isSelected && hasFocus ? baseColor : Colors.transparent,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.all(0.0),
        icon: Icon(
          icon,
          size: 17,
          color: isSelected && hasFocus ? textColor : defautTextColor,
        ),
        onPressed: () {
          onPressed?.call();
        },
        style: IconButton.styleFrom(
          backgroundColor:
              isSelected
                  ? (hasFocus
                      ? baseColor.withAlphaF(0.8)
                      : baseColor.withAlphaF(0.2))
                  : baseColor.withAlphaF(0.2),
        ),
      ),
    );
  }
}
