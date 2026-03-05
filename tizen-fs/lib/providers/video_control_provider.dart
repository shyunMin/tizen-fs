import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tizen_fs/utils/extensions.dart';
import 'package:video_player_videohole/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  Future<void>? _disposing;
  bool _isLoading = false;
  bool _isSeeking = false;

  VideoPlayerController? get controller => _controller;
  bool get isLoading => _isLoading;
  bool get isSeeking => _isSeeking;

  bool get isPlaying => _controller?.value.isPlaying ?? false;

  Future<void> createController(String url) async {
    _isLoading = true;
    notifyListeners();

    if (_disposing != null) {
      await _disposing;
    }

    if (_controller != null) {
      _disposing = _controller!.dispose();
      await _disposing;
    }

    final controller = VideoPlayerController.file(File(url));
    _controller = controller;

    await controller.initialize();
    await controller.play();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> disposeController() async {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
      }

      _disposing = _controller!.dispose();
      await _disposing;

      _disposing = null;
      _controller = null;
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null) return;
    if (_isSeeking) return;

    _isSeeking = true;
    debugPrint('_isSeeking=$_isSeeking');
    notifyListeners();

    await _controller!.seekTo(
      (position.clamp(
        Duration.zero,
        _controller!.value.duration.end - Duration(milliseconds: 300),
      )),
    );

    _isSeeking = false;
    debugPrint('_isSeeking=$_isSeeking');
    notifyListeners();
  }

  void togglePlayPause() async {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    notifyListeners();
  }

  void pause() async {
    if (_controller == null) return;
    if (!_controller!.value.isPlaying) return;

    _controller!.pause();

    notifyListeners();
  }

  void play() async {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) return;

    _controller!.play();

    notifyListeners();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}
