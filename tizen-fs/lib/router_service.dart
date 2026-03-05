import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterService {
  static final RouterService instance = RouterService._internal();
  factory RouterService() => instance;
  RouterService._internal();

  late GoRouter router;
  bool _isNavigating = false;

  String get currentPath =>
      router.routerDelegate.currentConfiguration.matches.last.matchedLocation;

  void setRouter(GoRouter goRouter) {
    router = goRouter;
  }

  Future<void> safePopUntil(
    BuildContext context,
    bool Function(Route<dynamic>) predicate,
  ) async {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;
    try {
      Navigator.of(context).popUntil((router) => router.isFirst);

      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint("$e");
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> safePush(String location, {Object? extra}) async {
    if (_isNavigating || location == currentPath) {
      return;
    }

    _isNavigating = true;
    try {
      // Do Not use 'await', using 'await' would block until the page is popped
      router.push(location, extra: extra);

      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint("$e");
    } finally {
      _isNavigating = false;
    }
  }

  void safePop() {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;
    try {
      if (router.canPop()) {
        router.pop();
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      _isNavigating = false;
    }
  }
}
