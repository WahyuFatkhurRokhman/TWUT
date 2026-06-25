import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/pages/playlist_page.dart';
import 'package:music_player/pages/local_page.dart';
import 'package:music_player/pages/permission_page.dart';
import 'package:music_player/pages/youtube_page.dart';
import 'package:music_player/pages/history_page.dart';
import 'package:music_player/providers/local_provider.dart';
import 'package:music_player/services/music_scanner.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/widgets/app_sidebar.dart';
import 'package:music_player/widgets/mini_player.dart';
import 'package:provider/provider.dart';

import '../pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool? _hasPermission;

  final List<Widget> _pages = [
    const HomePage(),
    ChangeNotifierProvider(
      create: (_) => LocalProvider(AppDatabase()),
      child: const LocalPage(),
    ),
    const YoutubePage(),
    const HistoryPage(),
    const PlaylistPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (!PlatformUtil.isAndroid) {
      setState(() => _hasPermission = true);
      return;
    }
    
    bool granted = await MusicScanner.hasPermissions();
    setState(() => _hasPermission = granted);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (!_hasPermission! && PlatformUtil.isAndroid) {
      return PermissionPage(
        onGranted: () => setState(() => _hasPermission = true),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 800;

      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (isDesktop)
                    AppSidebar(
                      selectedIndex: _selectedIndex,
                      onSelect: (index) => setState(() => _selectedIndex = index),
                    ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<NowPlayingMedia?>(
              valueListenable: AudioManager().currentMedia,
              builder: (context, media, _) {
                return Visibility(
                  visible: media != null,
                  child: MiniPlayer(),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: !isDesktop
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.white54,
                backgroundColor: Colors.black,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), label: "Local"),
                  BottomNavigationBarItem(icon: Icon(Icons.smart_display_outlined), label: "Youtube"),
                  BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: "History"),
                  BottomNavigationBarItem(icon: Icon(Icons.playlist_play_outlined), label: "Playlist"),
                ],
              )
            : null,
      );
    });
  }
}
