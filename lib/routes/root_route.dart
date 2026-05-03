import 'package:flutter/material.dart';
// import 'package:music_player/layouts/main_layout.dart';
import 'package:music_player/desktop/desktop_main_pages.dart';
import 'package:music_player/pages/music_player_page.dart';

class RootRoute {
  static const String mainLayout = '/';
  static const String musicPlayer = '/music-player';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainLayout:
        return MaterialPageRoute(
          builder: (_) => const DesktopMainPage(),
          settings: settings,
        );

      case musicPlayer:
        return MaterialPageRoute(
          builder: (_) => const MusicPlayerPage(),
          settings: settings,
        );

      default:
        return null;
    }
  }

  static Map<String, WidgetBuilder> get routes => {
    mainLayout: (context) => const DesktopMainPage(),
    musicPlayer: (context) => const MusicPlayerPage(),
  };
}