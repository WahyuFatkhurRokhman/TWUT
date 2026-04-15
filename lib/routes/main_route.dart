import 'package:flutter/material.dart';
import 'package:music_player/pages/category_group_music_page.dart';
import 'package:music_player/pages/group_music_list_page.dart';

class MainRoute {
  static const String home = '/home';

  static const String folder = '/folder';
  static const String album = '/album';
  static const String artist = '/artist';

  static const String folderMusic = '/folder-music';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case home:
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'folder'),
        );

      case folder:
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'folder'),
        );

      case album:
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'album'),
        );

      case artist:
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'artist'),
        );

      case folderMusic:
        final args = settings.arguments as Map<String, dynamic>?;
        final groupMusic = args?['groupMusic'] ?? '';

        return MaterialPageRoute(
          builder: (_) => GroupMusicListPage(groupMusic: groupMusic),
        );

      default:
        return null;
    }
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const CategoryGroupMusicPage(category: 'folder'),
    );
  }
}