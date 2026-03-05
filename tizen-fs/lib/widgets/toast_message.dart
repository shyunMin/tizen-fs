import 'package:flutter/material.dart';
import 'package:tizen_fs/styles/app_style.dart';

class ToastMessage {
  static void show(BuildContext context, String message, Duration? duration) {
    final screen = MediaQuery.of(context).size;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface.withAlphaF(0.8),
        duration: duration ?? const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        action: null,
        margin: EdgeInsets.only(
          bottom: screen.height / 3,
          left: screen.width / 4,
          right: screen.width / 4,
        ),

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      snackBarAnimationStyle: AnimationStyle.noAnimation,
    );
  }
}
