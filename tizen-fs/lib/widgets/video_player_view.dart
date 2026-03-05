import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/locator.dart';
import 'package:tizen_fs/providers/video_control_provider.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:video_player_videohole/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String title;
  final String url;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerView({
    super.key,
    required this.title,
    required this.url,
    this.autoPlay = true,
    this.looping = false,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with SingleTickerProviderStateMixin {
  late VideoControllerProvider _videoProvider;
  late FocusNode _focusNode;
  bool _isSeeking = false;
  bool _isPlaying = false;
  double? _dragValue;

  bool _isControlsShown = false;
  Timer? _showControllerTimer;

  late final AnimationController _animationController;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    setupVideoController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _videoProvider = context.read<VideoControllerProvider>();
        _videoProvider.createController(widget.url);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _showControllerTimer?.cancel();
    _videoProvider.disposeController();
    super.dispose();
  }

  void _showControls() {
    setState(() {
      _isControlsShown = true;
    });
    _showControllerTimer?.cancel();
    _animationController.forward(from: 0.0);
    if (_videoProvider.isPlaying) {
      _showControllerTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isControlsShown = false;
          });
        }
      });
    }
  }

  void _hideControls() {
    _showControllerTimer?.cancel();
    setState(() {
      _isControlsShown = false;
    });
  }

  void _onSliderDraggingStart() {
    _isPlaying = _videoProvider.isPlaying;
    _showControllerTimer?.cancel();
    _videoProvider.pause();
  }

  void _onSliderDraggingEnd() {
    _showControllerTimer?.cancel();

    if (_isPlaying) {
      _videoProvider.play();
      _showControllerTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isControlsShown = false;
          });
        }
      });
    }
  }

  void _resetTimer() {
    _showControllerTimer?.cancel();
    _showControllerTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isControlsShown = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_videoProvider.isPlaying) {
          context.read<VideoControllerProvider>().pause();
          _showControls();
        } else {
          context.read<VideoControllerProvider>().play();
          _showControls();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekTo(10, false);
        _resetTimer();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekTo(10, true);
        _resetTimer();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _seekTo(int seconds, bool isForward) async {
    final position = await _videoProvider.controller?.position;
    if (position == null) return;

    final move =
        isForward
            ? (position + Duration(seconds: seconds))
            : (position - Duration(seconds: seconds));
    _videoProvider.seekTo(move);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerProvider>(
      builder: (context, provider, _) {
        final controller = provider.controller;
        return Scaffold(
          backgroundColor: Colors.black,
          body: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKeyEvent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_isControlsShown) {
                  _hideControls();
                } else {
                  _showControls();
                }
              },
              child: AspectRatio(
                aspectRatio:
                    (provider.isLoading || controller == null)
                        ? 16 / 9
                        : controller.value.aspectRatio,
                child: Stack(
                  children: [
                    if (provider.isSeeking)
                      const Center(child: CircularProgressIndicator()),
                    (provider.isLoading || controller == null)
                        ? const Center(child: CircularProgressIndicator())
                        : VideoPlayer(controller),
                    if (_isControlsShown)
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlphaF(0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_isControlsShown)
                      Positioned(
                        left: 50,
                        right: 50,
                        bottom: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(height: 15),
                            (controller == null)
                                ? _videoProgressBar(
                                  context,
                                  Duration.zero,
                                  Duration.zero,
                                )
                                : ValueListenableBuilder<VideoPlayerValue>(
                                  valueListenable: controller,
                                  builder: (context, value, child) {
                                    final position = value.position;
                                    final duration =
                                        value.duration.end -
                                        Duration(
                                          milliseconds: 300,
                                        ); //padding to prevent error
                                    return _videoProgressBar(
                                      context,
                                      position,
                                      duration,
                                    );
                                  },
                                ),
                          ],
                        ),
                      ),
                    if (_isControlsShown)
                      Center(
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: ScaleTransition(
                              scale: _scale,
                              child: IconButton(
                                icon: Icon(
                                  (controller?.value.isPlaying ?? false)
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withAlphaF(0.5),
                                ),
                                onPressed: () {
                                  _showControllerTimer?.cancel();
                                  context
                                      .read<VideoControllerProvider>()
                                      .togglePlayPause();
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (_videoProvider.isPlaying) {
                                      _showControllerTimer = Timer(
                                        const Duration(seconds: 2),
                                        () {
                                          if (mounted) {
                                            setState(() {
                                              _isControlsShown = false;
                                            });
                                          }
                                        },
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _videoProgressBar(
    BuildContext context,
    Duration position,
    Duration duration,
  ) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape:
                (_videoProvider.isPlaying)
                    ? SliderComponentNoThumb()
                    : ConcentricCircleThumb(),
            trackHeight: _isControlsShown ? 4 : 2,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            overlayColor: Colors.transparent,
            padding: EdgeInsets.all(0),
          ),
          child: Slider(
            min: 0,
            max:
                duration.inMilliseconds > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1,
            value:
                _isSeeking
                    ? _dragValue!
                    : position.inMilliseconds
                        .clamp(
                          0,
                          duration.inMilliseconds > 0
                              ? duration.inMilliseconds
                              : 1,
                        )
                        .toDouble(),
            onChangeStart: (_) {
              _onSliderDraggingStart();
              setState(() {
                _isSeeking = true;
              });
            },
            onChanged: (newValue) {
              setState(() {
                _dragValue = newValue;
              });
            },
            onChangeEnd: (value) async {
              setState(() {
                _dragValue = null;
                _isSeeking = false;
              });
              try {
                await _videoProvider.seekTo(
                  Duration(milliseconds: value.toInt() - 300),
                );
              } catch (e) {
                debugPrint('$e');
              }
              _isSeeking = false;
              _onSliderDraggingEnd();
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              _formatDuration(duration),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class ConcentricCircleThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final outerPaint =
        Paint()
          ..color = Colors.white.withAlphaF(0.3)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, outerPaint);

    final middlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, middlePaint);

    final innerPaint =
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, innerPaint);
  }
}

class SliderComponentNoThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
