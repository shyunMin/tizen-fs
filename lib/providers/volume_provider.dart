import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tizen_audio_manager/tizen_audio_manager.dart';
import 'package:tizen_fs/models/item_display_interface.dart';

class VolumeData extends ChangeNotifier implements ItemDisplayInterface {
  AudioVolumeType type;
  int level;
  int maxLevel;
  bool isInitialized = false;

  VolumeData({
    this.type = AudioVolumeType.none,
    this.level = 0,
    this.maxLevel = 0,
  });

  @override
  String get displayText => _getText();

  @override
  String get displaySubText => level.toString();

  @override
  Object? get iconSourceData => null;

  @override
  IconSourceType get iconSourceType => IconSourceType.none;

  @override
  bool get isSelectable => true;

  String _getText() {
    switch (type) {
      case AudioVolumeType.media:
        return 'mediaVolume';
      case AudioVolumeType.system:
        return 'systemVolume';
      case AudioVolumeType.notification:
        return 'notificationVolume';
      default:
        return '';
    }
  }

  void updateLevel(int value) {
    level = value;
    notifyListeners();
  }

  void updateMaxLevel(int value) {
    maxLevel = value;
    notifyListeners();
  }
}

class VolumeProvider extends ChangeNotifier {
  List<VolumeData> _volumes = [];
  late AudioVolumeType _type;
  bool _initialized = false;

  List<VolumeData> get volumes => _volumes;
  AudioVolumeType get audioType => _type;
  set audioType(AudioVolumeType value) {
    _type = value;
  }

  final _manager = AudioManager.volumeController;
  StreamSubscription? _subscription;

  VolumeProvider() {
    if (_initialized) return;

    _volumes = [
      VolumeData(type: AudioVolumeType.media),
      VolumeData(type: AudioVolumeType.system),
      VolumeData(type: AudioVolumeType.notification),
    ];

    _type = AudioVolumeType.media;

    // loadData();
    startListening();

    _initialized = true;
  }

  String getText(AudioVolumeType type) {
    final volume = _volumes.where((v) => v.type == type).firstOrNull;
    return (volume == null) ? '' : volume.displayText;
  }

  Future<void> loadData() async {
    _loadLevel(AudioVolumeType.media);
    _loadLevel(AudioVolumeType.system);
    _loadLevel(AudioVolumeType.notification);

    _loadMaxLevel(AudioVolumeType.media);
    _loadMaxLevel(AudioVolumeType.system);
    _loadMaxLevel(AudioVolumeType.notification);
  }

  int getMaxLevel(AudioVolumeType type) {
    final volume = getVolumeData(type);
    return volume.maxLevel;
  }

  int getLevel(AudioVolumeType type) {
    final volume = getVolumeData(type);
    return volume.level;
  }

  Future<void> _loadLevel(AudioVolumeType type) async {
    final level = await _manager.getLevel(type);
    _updateLevel(type, level);
  }

  Future<void> _loadMaxLevel(AudioVolumeType type) async {
    final level = await _manager.getMaxLevel(type);
    _updateMaxLevel(type, level);
  }

  void _updateLevel(AudioVolumeType type, int value) {
    final volume = getVolumeData(type);
    if (volume.level != value) {
      volume.updateLevel(value);
    }
  }

  void _updateMaxLevel(AudioVolumeType type, int value) {
    final volume = getVolumeData(type);
    volume.updateMaxLevel(value);
  }

  Future<void> startListening() async {
    _subscription = _manager.onChanged.listen((event) async {
      _updateLevel(event.type, event.level);
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  Stream<dynamic> get onChanged => _manager.onChanged;

  VolumeData getVolumeData(AudioVolumeType type) {
    final volume = _volumes.where((v) => v.type == type).firstOrNull;
    if (volume != null) {
      return volume;
    } else {
      final created = VolumeData(type: type);
      _volumes.add(created);
      return created;
    }
  }

  Future<void> setLevel(AudioVolumeType type, int value) async {
    // _updateLevel(type, value);
    await _manager.setLevel(type, value);
  }
}
