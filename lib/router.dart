import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tizen_fs/actions/action_page.dart';
import 'package:tizen_fs/live/streaming_video_player.dart';
import 'package:tizen_fs/screen/main_screen.dart';
import 'package:tizen_fs/settings/settings.dart';
import 'profiles/profiles.dart';

class ScreenPaths {
  static const String main = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String action = '/action';
  static const String live = '/live';
}

class PageCache {
  static final Map<String, Widget> _cache = {};

  static Widget getPage(String key, Widget Function() builder) {
    if (!_cache.containsKey(key)) {
      _cache[key] = builder();
    }
    return _cache[key]!;
  }
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: ScreenPaths.main,
        builder:
            (context, state) =>
                PageCache.getPage(ScreenPaths.main, () => const MainScreen()),
      ),
      GoRoute(
        path: ScreenPaths.settings,
        builder:
            (context, state) =>
                PageCache.getPage(ScreenPaths.settings, () => Settings()),
      ),
      GoRoute(
        path: ScreenPaths.profile,
        builder:
            (context, state) =>
                PageCache.getPage(ScreenPaths.profile, () => Profiles()),
      ),
      GoRoute(
        path: ScreenPaths.action,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: ActionPage(),
            transitionDuration: const Duration(milliseconds: 50),
            // opaque: true,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: ScreenPaths.live,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return StreamingVideoPlayer(
            title: extra['title']!,
            streamUrl: extra['url']!,
          );
        },
      ),
    ],
    observers: [routeObserver],
  );
}
