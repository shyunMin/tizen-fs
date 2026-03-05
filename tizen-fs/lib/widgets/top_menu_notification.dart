import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/providers/notification_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';

class TopMenuNotification extends StatefulWidget {
  const TopMenuNotification({
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
  State<TopMenuNotification> createState() => TopMenuNotificationState();
}

class TopMenuNotificationState extends State<TopMenuNotification> {
  @override
  void initState() {
    super.initState();
  }

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
            color:
                widget.isSelected && widget.hasFocus
                    ? baseColor
                    : Colors.transparent,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(
              widget.icon,
              size: 17,
              color:
                  widget.isSelected && widget.hasFocus
                      ? textColor
                      : defautTextColor,
            ),
            onPressed: () {
              widget.onPressed?.call();
            },
            style: IconButton.styleFrom(
              backgroundColor:
                  widget.isSelected
                      ? (widget.hasFocus
                          ? baseColor.withAlphaF(0.8)
                          : baseColor.withAlphaF(0.2))
                      : baseColor.withAlphaF(0.2),
            ),
          ),
          if (Provider.of<NotificationProvider>(context, listen: false).count >
              0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
        ],
      ),
    );
  }
}
