import 'package:flutter/material.dart';
import 'package:music_player/routes/app_router.dart';

/// Jenis transisi yang tersedia untuk push/replace page.
enum PageTransition { none, slideUp, slideLeft, fade }

class NavigationUtil {
  // ========== NESTED NAVIGATOR (MainLayout) ==========

  /// Ambil navigator yang sesuai (root atau nested).
  static NavigatorState _navigatorOf(BuildContext context, bool root) {
    return Navigator.of(context, rootNavigator: root);
  }

  /// Push dalam nested navigator (home, folder-music, dll) lewat named route.
  static Future<T?>? pushNested<T>(BuildContext context, String routeName, {Object? arguments}) {
    return _navigatorOf(context, false).pushNamed(routeName, arguments: arguments);
  }

  /// Pop navigator (root/nested).
  static void pop<T>(BuildContext context, {T? result, bool root = true}) {
    final navigator = _navigatorOf(context, root);
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  /// Pop nested navigator
  static void popNested<T>(BuildContext context, [T? result]) {
    final navigator = _navigatorOf(context, false);
    if (navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }

  // ========== NESTED NAMED ROUTES (Helper) ==========

  /// Navigate ke Home
  static Future<T?>? toHome<T>(BuildContext context) {
    return pushNested<T>(context, AppRouter.home);
  }

  /// Navigate ke Folder Music List
  static Future<T?>? toFolderMusic<T>(BuildContext context, String folder) {
    return pushNested<T>(context, AppRouter.folderMusic, arguments: {'groupMusic': folder});
  }

  // ========== ROOT NAVIGATOR (Full App) ==========

  /// Push ke root navigator (music-player, dll) lewat named route.
  static Future<void> pushRoot(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return _navigatorOf(context, true).pushNamed(routeName, arguments: arguments);
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

  // ========== ROUTE BUILDER (default: TANPA animasi) ==========

  static PageRouteBuilder<T> _buildRoute<T>(
      Widget page, {
        PageTransition transition = PageTransition.none,
      }) {
    switch (transition) {
      case PageTransition.none:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        );

      case PageTransition.slideUp:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        );

      case PageTransition.slideLeft:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        );

      case PageTransition.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
        );
    }
  }

  // ========== PUSH / REPLACE (default: TANPA animasi) ==========

  /// Push widget ke navigator (root/nested).
  /// Default TANPA animasi — set [transition] untuk pakai animasi tertentu.
  static Future<T?> push<T>(
      BuildContext context,
      Widget page, {
        bool root = true,
        PageTransition transition = PageTransition.none,
      }) {
    return _navigatorOf(context, root)
        .push<T>(_buildRoute<T>(page, transition: transition));
  }

  /// Push widget ke navigator menggunakan GlobalKey.
  static Future<T?> pushWithKey<T>(
      GlobalKey<NavigatorState> key,
      Widget page, {
        PageTransition transition = PageTransition.none,
      }) {
    return key.currentState!.push<T>(_buildRoute<T>(page, transition: transition));
  }

  /// Replace page di navigator (root/nested).
  /// Default TANPA animasi.
  static Future<T?> pushReplace<T>(
      BuildContext context,
      Widget page, {
        bool root = true,
        PageTransition transition = PageTransition.none,
      }) {
    return _navigatorOf(context, root)
        .pushReplacement<T, T>(_buildRoute<T>(page, transition: transition));
  }

  /// Replace page di navigator menggunakan GlobalKey.
  static Future<T?> pushReplaceWithKey<T>(
      GlobalKey<NavigatorState> key,
      Widget page, {
        PageTransition transition = PageTransition.none,
      }) {
    return key.currentState!.pushReplacement<T, T>(_buildRoute<T>(page, transition: transition));
  }

  /// Hapus semua route lalu push page baru.
  /// Default TANPA animasi.
  static Future<T?> pushReplaceAndRemoveAll<T>(
      BuildContext context,
      Widget page, {
        bool root = true,
        PageTransition transition = PageTransition.none,
      }) {
    return _navigatorOf(context, root).pushAndRemoveUntil<T>(
      _buildRoute<T>(page, transition: transition),
          (route) => false,
    );
  }

  // ========== UTIL ==========

  /// Cek apakah nested navigator bisa pop
  static bool canPopNested(BuildContext context) => _navigatorOf(context, false).canPop();
}