import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/providers/notification_provider.dart';
import 'package:tizen_fs/native/notification_manager.dart';
import 'package:tizen_fs/widgets/selectable_listview.dart';
import 'package:tizen_fs/notifications/notification_detail_popup.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'dart:async';

class NotificationsPanel extends StatefulWidget {
  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final NotificationProvider _notificationProvider =
      GetIt.instance<NotificationProvider>();
  Future<List<NotificationItem>> _notificationListFuture = Future.value([]);
  final GlobalKey<SelectableListViewState> _selectableListKey = GlobalKey();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _notificationProvider.addListener(_listener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode.requestFocus();
      _refreshNotificationList();
    });
  }

  void _listener() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshNotificationList();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshNotificationList();
      }
    });
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _notificationProvider.removeListener(_listener);
    super.dispose();
  }

  void _refreshNotificationList() {
    if (mounted) {
      setState(() {
        _notificationListFuture = Future.value(
          _notificationProvider.notifications,
        );
      });
    }
  }

  Future<void> _handleClearAll() async {
    await _notificationProvider.clearAll();
  }

  Widget _buildEmptyList(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Center(
        child: Text(
          AppLocalizations.of(context).noNotifications,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    AsyncSnapshot<List<NotificationItem>> snapshot,
  ) {
    return FocusScope(
      node: _focusScopeNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final listState = _selectableListKey.currentState;
            if (listState == null) return KeyEventResult.ignored;
            final selectedIndex = listState.selectedIndex;
            final notifications = snapshot.data!;

            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                listState.previous().then((_) {
                  if (mounted) setState(() {});
                });
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowDown:
                listState.next().then((_) {
                  if (mounted) setState(() {});
                });
                return KeyEventResult.handled;
              case LogicalKeyboardKey.enter:
              case LogicalKeyboardKey.select:
                if (selectedIndex == notifications.length) {
                  _handleClearAll();
                } else {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder:
                        (_) => NotificationDetailPopup(
                          notification: notifications[selectedIndex],
                        ),
                  );
                }
                return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: () {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyList(context);
        } else {
          final notifications = snapshot.data!;
          return _buildContents(context, notifications);
        }
      }(),
    );
  }

  Widget _buildContents(
    BuildContext context,
    List<NotificationItem> notifications,
  ) {
    return SelectableListView(
      key: _selectableListKey,
      itemCount: notifications.length + 1, // +1 for "Clear All"
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: 0.5,
      itemBuilder: (context, index, selectedIndex, key) {
        final isFocused = index == selectedIndex;
        final bool isClearAllItem = index == notifications.length;

        return AnimatedScale(
          key: key,
          scale: isFocused ? 1.0 : 0.9,
          duration: $style.times.med,
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: () {
              _selectableListKey.currentState?.selectTo(index);
              if (isClearAllItem) {
                _handleClearAll();
              } else {
                showDialog(
                  context: context,
                  builder:
                      (_) => NotificationDetailPopup(
                        notification: notifications[index],
                      ),
                );
              }
            },
            child:
                isClearAllItem
                    ? _buildClearAllItem(context, isFocused)
                    : _buildNotificationItem(
                      context,
                      notifications[index],
                      isFocused,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildClearAllItem(BuildContext context, bool isFocused) {
    const double titleFontSize = 15.0;
    const double innerPadding = 20.0;
    const double itemHeight = 65.0;
    const double iconSize = 25.0;

    final Color iconColor =
        isFocused
            ? Theme.of(context).colorScheme.onTertiary
            : Theme.of(context).colorScheme.tertiary.withAlphaF(0.7);

    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _getContainerColor(context, isFocused),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Icon(Icons.delete_sweep, size: iconSize, color: iconColor),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).clearAll,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: _getTextColor(context, isFocused),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTextColor(BuildContext context, bool isFocused) {
    return isFocused
        ? Theme.of(context).colorScheme.onTertiary
        : Theme.of(context).colorScheme.tertiary;
  }

  Color _getContainerColor(BuildContext context, bool isFocused) {
    return isFocused
        ? Theme.of(context).colorScheme.tertiary
        : Colors.transparent;
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    bool isFocused,
  ) {
    const double titleFontSize = 15.0;
    const double subtitleFontSize = 11.0;
    const double innerPadding = 20.0;
    const double itemHeight = 65.0;
    const double iconSize = 25.0;

    final Color iconColor =
        isFocused
            ? Theme.of(context).colorScheme.onTertiary
            : Theme.of(context).colorScheme.tertiary.withAlphaF(0.7);

    return SizedBox(
      height: itemHeight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _getContainerColor(context, isFocused),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: innerPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 15,
            children: [
              Icon(Icons.notifications, size: iconSize, color: iconColor),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ??
                          AppLocalizations.of(context).noTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: _getTextColor(context, isFocused),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.content != null)
                      Text(
                        notification.content!,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: _getTextColor(
                            context,
                            isFocused,
                          ).withAlphaF(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 630,
            child: SizedBox(
              width: 300,
              height: 450,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FutureBuilder<List<NotificationItem>>(
                          future: _notificationListFuture,
                          builder: _buildNotificationList,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
