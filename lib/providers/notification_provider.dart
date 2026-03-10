import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:tizen_fs/native/notification_manager.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationManager _manager = GetIt.instance<NotificationManager>();

  List<NotificationItem> _notifications = [];
  bool _isRefreshing = false;

  List<NotificationItem> get notifications => _notifications;
  int get count => _notifications.length;

  NotificationProvider() {
    _manager.onDetailChanged.listen((_) {
      _refresh();
    });
    _refresh();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final list = await _manager.getList();
      _notifications = list;
      if (hasListeners) {
        notifyListeners();
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> clearAll() async {
    await _manager.clear();
    await _refresh();
  }

  Future<void> delete(String appId, int privId) async {
    debugPrint("notification provider delete [$appId, $privId]");
    await _manager.delete(appId, privId);
    await _refresh();
  }

  Future<void> deleteHandle(Pointer<Opaque> handle) async {
    debugPrint("notification provider delete handle [$handle]");
    await _manager.deleteHandle(handle);
    await _refresh();
  }
}
