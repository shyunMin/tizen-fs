import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/live/stream_channel.dart';

class ActionModel extends ChangeNotifier {
  final List<String> _actions = [];
  bool _initialized = false;

  static final Map<String, String> actionData = {};

  List<String> get actions => _actions;

  Future<void> loadCommands() async {
    if (_initialized) return;

    _loadSystemCommands();
    _loadAppsCommands();
    _loadSettingsCommands();
    _loadNotificationCommands();
    await _loadChannels();
    _initialized = true;
  }

  void _loadSystemCommands() {
    actions.add('volume: up');
    actions.add('volume: down');
    actions.add('volume: ');
    actions.add('Change language: korean');
    actions.add('Change language: english');
    actions.add('Change device name: ');
    actions.add('feature: media on');
    actions.add('feature: media off');
    actions.add('feature: live on');
    actions.add('feature: live off');
    actions.add('feature: ai on');
    actions.add('feature: ai off');
  }

  void _loadAppsCommands() {
    actions.add('Reorder app list: DESC');
    actions.add('Reorder app list: ASC');
    actions.add('Filter app list by apptype: dotnet');
    actions.add('Filter app list by apptype: capp');
    actions.add('Filter app list by apptype: webapp');
    actions.add('Filter app list by apptype: ');
    actions.add('Filter app list by keyword: ');
  }

  void _loadSettingsCommands() {
    actions.add('settings: /settings');
    actions.add('settings: /settings/profile');
    actions.add('settings: /settings/about_device');
    actions.add('settings: /settings/date_time');
    actions.add('settings: /settings/wifi');
    actions.add('settings: /settings/bluetooth');
    actions.add('settings: /settings/language_input');
    actions.add('settings: /settings/apps');
    actions.add('settings: /settings/apps/installed_apps');
    actions.add('settings: /settings/apps/running_apps');
    actions.add('settings: /settings/apps/all_apps');
    actions.add('settings: /settings/storage');
    actions.add('settings: /settings/volume');
    actions.add('settings: /settings/additional_features');

    //Wi-Fi
    actions.add('wifi: on');
    actions.add('wifi: off');

    //Bluetooth
    actions.add('bluetooth: on');
    actions.add('bluetooth: off');
  }

  void _loadNotificationCommands() {
    actions.add('notification: show');
  }

  Future<void> _loadChannels() async {
    try {
      final String allChannelsString = await rootBundle.loadString(
        'assets/stream_channels.json',
      );
      final List<dynamic> allJsonList = json.decode(allChannelsString);
      final channels =
          allJsonList.map((json) => StreamChannel.fromJson(json)).toList();

      for (var ch in channels) {
        actions.add('live: ${ch.name}');
        actionData[ch.name.toLowerCase().trim()] = ch.url;
      }
    } catch (e) {
      debugPrint('Failed to load recommended channels: $e');
    }
  }
}
