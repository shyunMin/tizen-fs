import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/live/channel_add_popup.dart';
import 'package:tizen_fs/live/channel_recommend_popup.dart';
import 'package:tizen_fs/live/stream_channel.dart';
import 'package:tizen_fs/live/stream_channel_grid_view.dart';
import 'package:tizen_fs/widgets/toast_message.dart';
import 'package:tizen_fs/live/streaming_video_player.dart';
import 'package:tizen_fs/live/channel_action_popup.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  List<StreamChannel> channels = [];
  int _currentChannelIndex = 0;

  List<StreamChannel> get _channelItems {
    return channels;
  }

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationSupportDirectory();
    // /opt/usr/home/owner/apps_rw/org.tizen.homescreen/data
    return File('${directory.path}/stream_channels.json');
  }

  Future<void> _loadChannels() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        if (mounted) {
          setState(() {
            channels =
                jsonList.map((json) => StreamChannel.fromJson(json)).toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            channels = [];
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load channel list: $e');
      if (mounted) {
        setState(() {
          channels = [];
        });
      }
    }
  }

  Future<void> _saveChannels() async {
    try {
      final file = await _getLocalFile();
      final List<Map<String, dynamic>> jsonList =
          channels.map((channel) => channel.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Failed to save channel list: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '${AppLocalizations.of(context).livestream} ${AppLocalizations.of(context).channel}',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamChannelGridView(
              items: _channelItems,
              onItemSelected: (index) {
                if (index == 0) {
                  _showAddChannelDialog();
                } else {
                  final channelIndex = index - 1;
                  if (channelIndex < channels.length) {
                    _handleChannelSelected(channels[channelIndex]);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddChannelDialog() {
    _nameController.clear();
    _urlController.clear();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return ChannelAddPopup(
          nameController: _nameController,
          urlController: _urlController,
          onAdd: (channel) {
            _addChannel(channel);
            Navigator.of(context).pop();
          },
          onShowRecommend: () {
            _showRecommendChannelDialog();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _addChannel(StreamChannel channel) {
    setState(() {
      channels.add(channel);
    });

    _saveChannels();

    ToastMessage.show(
      context,
      "${channel.name} ${AppLocalizations.of(context).channel} ${AppLocalizations.of(context).added}",
      const Duration(seconds: 2),
    );
  }

  void _showRecommendChannelDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return ChannelRecommendPopup(
          onAddChannel: (channel) {
            _addChannel(channel);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _handleChannelSelected(StreamChannel channel) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return ChannelActionPopup(
          channel: channel,
          onPlay: () {
            _playChannel(channel);
          },
          onDelete: () {
            _deleteChannel(channel);
          },
          onEdit: (updatedChannel) {
            _editChannel(channel, updatedChannel);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  void _playChannel(StreamChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: StreamingVideoPlayer(
                streamUrl: channel.url,
                title: channel.name,
                onVideoLoaded: () {
                  debugPrint('Stream loaded: ${channel.name}');
                },
                onError: (error) {
                  debugPrint('Stream error: $error');
                },
                onPreviousChannel: () {
                  _previousChannel();
                },
                onNextChannel: () {
                  _nextChannel();
                },
              ),
            ),
      ),
    );
  }

  void _editChannel(
    StreamChannel originalChannel,
    StreamChannel updatedChannel,
  ) {
    updatedChannel.logo = originalChannel.logo ?? "";
    updatedChannel.category = originalChannel.category ?? "";
    updatedChannel.description = originalChannel.description ?? "";
    final index = channels.indexOf(originalChannel);
    if (index != -1) {
      setState(() {
        channels[index] = updatedChannel;
      });

      _saveChannels();

      ToastMessage.show(
        context,
        "${updatedChannel.name} ${AppLocalizations.of(context).channel} ${AppLocalizations.of(context).edited}",
        const Duration(seconds: 2),
      );
    }
  }

  void _deleteChannel(StreamChannel channel) {
    setState(() {
      channels.remove(channel);
    });

    _saveChannels();

    ToastMessage.show(
      context,
      "${channel.name} ${AppLocalizations.of(context).channel} ${AppLocalizations.of(context).deleted}",
      const Duration(seconds: 2),
    );
  }

  void _previousChannel() {
    if (channels.isEmpty) return;
    setState(() {
      _currentChannelIndex =
          (_currentChannelIndex - 1 + channels.length) % channels.length;
    });
    final StreamChannel currentChannel = channels[_currentChannelIndex];
    debugPrint('Previous channel: ${currentChannel.name}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: StreamingVideoPlayer(
                streamUrl: currentChannel.url,
                title: currentChannel.name,
                onVideoLoaded: () {
                  debugPrint('Stream loaded: ${currentChannel.name}');
                  ToastMessage.show(
                    context,
                    "${AppLocalizations.of(context).currentChannel}: ${currentChannel.name}",
                    Duration(seconds: 2),
                  );
                },
                onError: (error) {
                  debugPrint('Stream error: $error');
                },
                onPreviousChannel: () {
                  _previousChannel();
                },
                onNextChannel: () {
                  _nextChannel();
                },
              ),
            ),
      ),
    );
  }

  void _nextChannel() {
    if (channels.isEmpty) return;
    setState(() {
      _currentChannelIndex = (_currentChannelIndex + 1) % channels.length;
    });
    final StreamChannel currentChannel = channels[_currentChannelIndex];
    debugPrint('Next channel: ${currentChannel.name}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: StreamingVideoPlayer(
                streamUrl: currentChannel.url,
                title: currentChannel.name,
                onVideoLoaded: () {
                  debugPrint('Stream loaded: ${currentChannel.name}');
                  ToastMessage.show(
                    context,
                    "${AppLocalizations.of(context).currentChannel}: ${currentChannel.name}",
                    Duration(seconds: 2),
                  );
                },
                onError: (error) {
                  debugPrint('Stream error: $error');
                },
                onPreviousChannel: () {
                  _previousChannel();
                },
                onNextChannel: () {
                  _nextChannel();
                },
              ),
            ),
      ),
    );
  }
}
