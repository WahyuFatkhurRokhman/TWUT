import 'package:flutter/material.dart';
import 'package:music_player/layouts/main_layout.dart';
import 'package:music_player/pages/music_player_page.dart';

import 'package:music_player/pages/category_group_music_page.dart';
import 'package:music_player/pages/group_music_list_page.dart';
import 'package:music_player/pages/playlist_detail_page.dart';
import 'package:music_player/pages/playlist_page.dart';

class AppRouter {
  // Top-level routes
  static const String mainLayout = '/';
  static const String musicPlayer = '/music-player';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainLayout:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(),
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

  static const String home = '/home';
  static const String folder = '/folder';
  static const String album = '/album';
  static const String artist = '/artist';
  static const String folderMusic = '/folder-music';
  static const String playlistPage = '/playlist-page';
  static const String playlistDetail = '/playlist-page/detail';

  static Route<dynamic>? generateLibraryRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case folder:
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'folder'),
        );
      case playlistPage:
        return MaterialPageRoute(builder: (_) => PlaylistPage());
      case playlistDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailPage(
            playlist: args['playlist']
          ),
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
        return MaterialPageRoute(
          builder: (_) => const CategoryGroupMusicPage(category: 'folder'),
        );
    }
  }
}
