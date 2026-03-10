import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:video_player_videohole/video_player.dart';

class StreamingVideoPlayer extends StatefulWidget {
  final String title;
  final String streamUrl;
  final Function()? onVideoLoaded;
  final Function(String)? onError;
  final Function()? onPreviousChannel;
  final Function()? onNextChannel;

  const StreamingVideoPlayer({
    super.key,
    required this.streamUrl,
    required this.title,
    this.onVideoLoaded,
    this.onError,
    this.onPreviousChannel,
    this.onNextChannel,
  });

  @override
  State<StreamingVideoPlayer> createState() => _StreamingVideoPlayerState();
}

class _StreamingVideoPlayerState extends State<StreamingVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isError = false;
  bool _isLoading = true;
  bool _showOverlay = true;
  static const Duration _timeoutDuration = Duration(seconds: 7);
  static const Duration _overlayHideDuration = Duration(seconds: 3);
  Timer? _timeoutTimer;
  Timer? _overlayHideTimer;
  final FocusNode _selectButtonFocusNode = FocusNode();
  final FocusNode _overlayFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startOverlayHideTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _selectButtonFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(StreamingVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitialized = false;
      _isError = false;
      _isLoading = true;
    });

    _timeoutTimer = Timer(_timeoutDuration, () {
      if (mounted && _isLoading) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
        widget.onError?.call('Loading timeout: ${widget.title}');
        debugPrint('Loading timeout for ${widget.title}');
      }
    });

    try {
      _controller = VideoPlayerController.network(widget.streamUrl);

      await _controller.initialize();

      _timeoutTimer?.cancel();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });

        if (!_controller.value.isPlaying) {
          try {
            await _controller.seekTo(Duration(seconds: 1));
            await _controller.play();
          } catch (playError) {
            debugPrint('Play error (but stream loaded): $playError');
          }
        }

        widget.onVideoLoaded?.call();
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
        widget.onError?.call('Failed to load stream: $e');
      }
    }
  }

  void _disposePlayer() {
    try {
      _controller.dispose();
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _startOverlayHideTimer() {
    _overlayHideTimer?.cancel();
    _overlayHideTimer = Timer(_overlayHideDuration, () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  void _showOverlayTemporarily() {
    setState(() {
      _showOverlay = true;
    });
    _startOverlayHideTimer();
  }

  void _togglePlayPause() async {
    if (!_isInitialized || _isError) return;

    try {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  Widget _buildPlayPauseOverlay() {
    if (!_isInitialized || _isError) return SizedBox.shrink();

    return Center(
      child: AnimatedOpacity(
        opacity: _showOverlay ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withAlphaF(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _overlayHideTimer?.cancel();
    _selectButtonFocusNode.dispose();
    _overlayFocusNode.dispose();
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          widget.onPreviousChannel?.call();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          widget.onNextChannel?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          if (_isError) {
            return _buildFailureWidget();
          }

          if (_isLoading || !_isInitialized) {
            return _buildLoadingWidget();
          }

          return Stack(
            children: [
              Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              _buildOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: () {
        _togglePlayPause();
        _showOverlayTemporarily();
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              widget.onPreviousChannel?.call();
              _showOverlayTemporarily();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              widget.onNextChannel?.call();
              _showOverlayTemporarily();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              _togglePlayPause();
              _showOverlayTemporarily();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              if (_showOverlay)
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onPreviousChannel?.call();
                              _showOverlayTemporarily();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '<',
                              style: TextStyle(
                                color: Colors.white.withAlphaF(0.7),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onNextChannel?.call();
                              _showOverlayTemporarily();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '>',
                              style: TextStyle(
                                color: Colors.white.withAlphaF(0.7),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              _buildPlayPauseOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).loadingChannel,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 60),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).unableToLoadChannel,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 24),
            Focus(
              focusNode: _selectButtonFocusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    _goBack();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Builder(
                builder: (context) {
                  final bool hasFocus = Focus.of(context).hasFocus;
                  return ElevatedButton(
                    onPressed: _goBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasFocus ? Colors.white : Colors.white70,
                      foregroundColor: Colors.black,
                      side: BorderSide(
                        color: hasFocus ? Colors.white : Colors.transparent,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).back),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
