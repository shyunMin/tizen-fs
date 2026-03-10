import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieView extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool autoplay;
  final bool loop;

  const LottieView({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.autoplay = true,
    this.loop = true,
  });

  @override
  State<LottieView> createState() => _LottieViewState();
}

class _LottieViewState extends State<LottieView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Lottie.asset(
        widget.assetPath,
        controller: _controller,
        fit: widget.fit,
        onLoaded: (composition) {
          if (!_isLoaded) {
            _isLoaded = true;
            _controller.duration = composition.duration;

            if (widget.autoplay) {
              if (widget.loop) {
                _controller.repeat();
              } else {
                _controller.forward(from: 0);
              }
            }
          }
        },
      ),
    );
  }
}
