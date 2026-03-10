import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/providers/notification_provider.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/native/notification_manager.dart';

class NotificationDetailPopup extends StatefulWidget {
  const NotificationDetailPopup({Key? key, required this.notification})
    : super(key: key);

  final NotificationItem notification;

  @override
  State<NotificationDetailPopup> createState() =>
      _NotificationDetailPopupState();
}

class _NotificationDetailPopupState extends State<NotificationDetailPopup> {
  final NotificationProvider _notificationProvider =
      GetIt.instance<NotificationProvider>();
  final FocusNode _closeFocusNode = FocusNode();
  final FocusNode _deleteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _closeFocusNode.dispose();
    _deleteFocusNode.dispose();
    super.dispose();
  }

  String _format(dynamic value) => value?.toString() ?? '-';

  void _deleteNotification(NotificationItem notification) {
    if (notification.appId != null) {
      _notificationProvider.delete(notification.appId!, notification.privId);
    }
  }

  @override
  Widget build(BuildContext context) {
    var notification = widget.notification;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_closeFocusNode.hasFocus) {
              Navigator.of(context).pop();
            } else if (_deleteFocusNode.hasFocus) {
              _deleteNotification(notification);
              Navigator.of(context).pop();
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(40),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FocusScope(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ??
                              AppLocalizations.of(context).noTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        focusNode: _closeFocusNode,
                        tooltip: AppLocalizations.of(context).close,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        focusNode: _deleteFocusNode,
                        tooltip: AppLocalizations.of(context).delete,
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteNotification(notification);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                if (notification.content != null) ...[
                  Text(
                    notification.content!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                ],

                _infoRow(
                  '${AppLocalizations.of(context).from} ',
                  _format(notification.appId),
                ),
                // _infoRow('Group ID', _format(notification.groupId)),
                // _infoRow('Priv ID', _format(notification.privId)),
                // _infoRow('Insert Time', _format(notification.insertTime)),
                // _infoRow('Layout', _format(notification.layout)),
                // _infoRow('Type', _format(notification.type)),
                // _infoRow('Tag', _format(notification.tag)),
                // _infoRow('Check Box', _format(notification.checkBox)),
                // _infoRow('Checked Value', _format(notification.checkedValue)),
                // _infoRow('Event Flag', _format(notification.eventFlag)),
                // _infoRow('Icon', _format(notification.icon)),
                // _infoRow('Sub Icon', _format(notification.subIcon)),
                // _infoRow('Timestamp Visible', _format(notification.isTimeStampVisible)),
                // _infoRow('Timestamp', _format(notification.timeStamp)),
                // _infoRow('Ongoing', _format(notification.isOngoing)),
                // _infoRow('Visible', _format(notification.isVisible)),
                // _infoRow('Auto Remove', _format(notification.autoRemove)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
