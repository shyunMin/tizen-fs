import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/live/stream_channel.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/widgets/toast_message.dart';

class ChannelRecommendPopup extends StatefulWidget {
  const ChannelRecommendPopup({
    required this.onAddChannel,
  });

  final Function(StreamChannel) onAddChannel;

  @override
  State<ChannelRecommendPopup> createState() => _ChannelRecommendPopupState();
}

class _ChannelRecommendPopupState extends State<ChannelRecommendPopup> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<StreamChannel> allChannels = [];
  List<StreamChannel> existingChannels = [];
  List<StreamChannel> recommendedChannels = [];
  List<GlobalKey> _itemKeys = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/stream_channels.json');
  }

  Future<void> _loadChannels() async {
    try {
      final existingFile = await _getLocalFile();
      if (await existingFile.exists()) {
        final existingContents = await existingFile.readAsString();
        final List<dynamic> existingJsonList = json.decode(existingContents);
        existingChannels = existingJsonList
            .map((json) => StreamChannel.fromJson(json))
            .toList();
      }

      final String allChannelsString = await rootBundle.loadString('assets/stream_channels.json');
      final List<dynamic> allJsonList = json.decode(allChannelsString);
      allChannels = allJsonList
          .map((json) => StreamChannel.fromJson(json))
          .toList();

      final existingChannelNames = existingChannels.map((channel) => channel.name).toSet();
      recommendedChannels = allChannels
          .where((channel) => !existingChannelNames.contains(channel.name))
          .toList();

      setState(() {
        _itemKeys = List.generate(recommendedChannels.length, (index) => GlobalKey());
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load recommended channels: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_selectedIndex < recommendedChannels.length - 1) {
          _selectTo(_selectedIndex + 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_selectedIndex > 0) {
          _selectTo(_selectedIndex - 1);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        if (recommendedChannels.isNotEmpty) {
          _handleChannelSelected(recommendedChannels[_selectedIndex]);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _selectTo(int index) async {
    if (index >= 0 && index < recommendedChannels.length) {
      await _scrollToSelected(index);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _scrollToSelected(int index) async {
    final context = _itemKeys[index].currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleChannelSelected(StreamChannel channel) {
    widget.onAddChannel(channel);
    Navigator.of(context).pop();
    ToastMessage.show(
      context,
      "${channel.name} ${AppLocalizations.of(context).channel} ${AppLocalizations.of(context).added}",
      const Duration(seconds: 2),
    );
  }

  Widget _buildChannelItem(StreamChannel channel, int index) {
    final isSelected = index == _selectedIndex;
    final double titleFontSize = 15;
    final double subtitleFontSize = 11;
    final double itemHeight = 65;

    return Focus(
      canRequestFocus: false,
      child: GestureDetector(
        onTap: () {
          _selectTo(index);
          _handleChannelSelected(channel);
        },
        child: SizedBox(
          key: _itemKeys[index],
          child: AnimatedScale(
            scale: isSelected ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.transparent,
              ),
              child: ListTile(
                onTap: () {
                  _selectTo(index);
                  _handleChannelSelected(channel);
                },
                minTileHeight: itemHeight,
                leading: SizedBox(
                  width: 40,
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.blue.withAlphaF(0.2)
                          : Colors.grey,
                    ),
                    child: channel.logo != null && channel.logo!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: channel.logo,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) {
                                return Icon(
                                  Icons.tv_outlined,
                                  size: 25,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.tv_outlined,
                            size: 25,
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey,
                          ),
                  ),
                ),
                title: Text(
                  channel.name,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onTertiary
                        : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                subtitle: Text(
                  channel.url,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv_outlined,
            size: 60,
            color: Colors.white.withAlphaF(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "${AppLocalizations.of(context).noRecommendedChannels}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlphaF(0.8),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context).recommended} ${AppLocalizations.of(context).channel}",
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 120, 100, 0),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : recommendedChannels.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: recommendedChannels.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildChannelItem(recommendedChannels[index], index),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
