import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:tizen_fs/styles/app_style.dart';

class BlinkBorder extends StatefulWidget {
  const BlinkBorder({
    super.key,
    required this.child,
    this.borderColor = Colors.white,
    this.borderWidth = 1.5,
    this.duration = const Duration(milliseconds: 800),
    this.begin = 0.7,
    this.end = 0,
    this.borderRadius,
    this.isAiMode = false,
  });

  final bool isAiMode;
  final Color borderColor;
  final Widget child;
  final double borderWidth;
  final Duration duration;
  final double begin;
  final double end;
  final BorderRadius? borderRadius;

  @override
  State<BlinkBorder> createState() => _BlinkBorderState();
}

class _BlinkBorderState extends State<BlinkBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>(begin: widget.begin, end: widget.end).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    )..addListener(() {
      setState(() {});
    });

    Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
      if (!_disposed) {
        controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.isAiMode
              ? BoxDecoration(
                // AI 모드일 때는 고정된 Gradient 보더 (또는 애니메이션 중지)
                border: GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: [Colors.pink, Colors.orange],
                  ),
                  width: 1.5,
                ),
                borderRadius: widget.borderRadius,
              )
              : BoxDecoration(
                // 일반 모드일 때는 기존 블링크 보더
                border: Border.all(
                  color: widget.borderColor.withAlphaF(animation.value),
                  width: widget.borderWidth,
                ),
                borderRadius: widget.borderRadius,
              ),
      child: widget.child,
    );
  }
}
