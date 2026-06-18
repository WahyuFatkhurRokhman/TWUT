import 'package:flutter/material.dart';
import 'package:music_player/routes/app_router.dart';

class NavigationUtil {
  // ========== NESTED NAVIGATOR (MainLayout) ==========

  static final GlobalKey<NavigatorState> nestedKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _nested => nestedKey.currentState;

  /// Push dalam nested navigator (home, folder-music, dll)
  static Future<T?>? pushNested<T>(String routeName, {Object? arguments}) {
    return _nested?.pushNamed(routeName, arguments: arguments);
  }

  /// Push widget dalam nested navigator
  static Future<T?>? pushNestedPage<T>(Widget page) {
    return _nested?.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Pop nested navigator
  static void popNested<T>([T? result]) {
    if (_nested?.canPop() ?? false) {
      _nested?.pop<T>(result);
    }
  }

  // ========== NESTED NAMED ROUTES (Helper) ==========

  /// Navigate ke Home
  static Future<T?>? toHome<T>() {
    return pushNested<T>(AppRouter.home);
  }

  /// Navigate ke Folder Music List
  static Future<T?>? toFolderMusic<T>(String folder) {
    return pushNested<T>(AppRouter.folderMusic, arguments: {'groupMusic': folder});
  }

  // ========== ROOT NAVIGATOR (Full App) ==========

  /// Push ke root navigator (music-player, dll)
  static Future<void> pushRoot(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(routeName, arguments: arguments);
  }

  /// Pop dari root navigator
  static void popRoot(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // ========== ROOT NAMED ROUTES (Helper) ==========

  /// Navigate ke Music Player
  static Future<void> toMusicPlayer(BuildContext context, {Object? arguments}) {
    return pushRoot(context, AppRouter.musicPlayer, arguments: arguments);
  }

  // ========== CUSTOM ANIMATIONS ==========

  /// Slide dari bawah
  /// [root] = true untuk root navigator, false untuk nested navigator
  static Future<T?> slideUp<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;

    if (navigator == null) {
      throw Exception('Navigator not available');
    }

    return navigator.push<T>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  /// Slide dari kanan (left direction)
  /// [root] = true untuk root navigator, false untuk nested navigator
  static Future<T?> slideLeft<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;

    if (navigator == null) {
      throw Exception('Navigator not available');
    }

    return navigator.push<T>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  /// Fade transition
  /// [root] = true untuk root navigator, false untuk nested navigator
  static Future<T?> fade<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;

    if (navigator == null) {
      throw Exception('Navigator not available');
    }

    return navigator.push<T>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Fade transition (REPLACE) root / nested
  /// [root] = true untuk root navigator, false untuk nested navigator
  static Future<T?> fadeReplace<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;

    if (navigator == null) {
      throw Exception('Navigator not available');
    }

    return navigator.pushReplacement<T, T>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  static Future<T?> fadeReplaceAndRemove<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;

    if (navigator == null) {
      throw Exception('Navigator not available');
    }

    return navigator.pushAndRemoveUntil<T>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  static PageRouteBuilder<T> _noAnimationRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, child) => child,
    );
  }

  // ========== PUSH TANPA ANIMASI ==========
  /// root=true => root navigator
  /// root=false => nested navigator
  static Future<T?> noAnimation<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;
    if (navigator == null) {
      throw Exception('Navigator not available');
    }
    return navigator.push<T>(_noAnimationRoute(page));
  }

  // ========== REPLACE TANPA ANIMASI ==========
  static Future<T?> noAnimationReplace<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;
    if (navigator == null) {
      throw Exception('Navigator not available');
    }
    return navigator.pushReplacement<T, T>(_noAnimationRoute(page));
  }

  // ========== REMOVE ALL + PUSH TANPA ANIMASI ==========
  static Future<T?> noAnimationReplaceAndRemove<T>(
    BuildContext context,
    Widget page, {
    bool root = true,
  }) {
    final navigator = root
        ? Navigator.of(context, rootNavigator: true)
        : _nested;
    if (navigator == null) {
      throw Exception('Navigator not available');
    }
    return navigator.pushAndRemoveUntil<T>(
      _noAnimationRoute(page),
      (route) => false,
    );
  }
  // ========== UTIL ==========

  /// Cek apakah nested navigator bisa pop
  static bool canPopNested() => _nested?.canPop() ?? false;

  /// Get nested context
  static BuildContext? get nestedContext => nestedKey.currentContext;
}
