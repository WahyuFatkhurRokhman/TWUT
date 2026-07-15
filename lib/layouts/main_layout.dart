import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/widgets/playlist_navigator.dart';
import 'package:music_player/providers/navigation_provider.dart';
import 'package:music_player/widgets/local_navigator.dart';
import 'package:music_player/services/connectivity_service.dart';
import 'package:music_player/utils/snackbar_util.dart';

import 'package:music_player/pages/permission_page.dart';
import 'package:music_player/pages/youtube_page.dart';
import 'package:music_player/pages/history_page.dart';
import 'package:music_player/providers/local_provider.dart';
import 'package:music_player/services/music_scanner.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/widgets/app_sidebar.dart';
import 'package:music_player/widgets/mini_player.dart';
import 'package:music_player/widgets/youtube_mini_player.dart';
import 'package:provider/provider.dart';

import '../pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool? _hasPermission;
  StreamSubscription<bool>? _subscription;

  final List<Widget> _pages = [
    const HomePage(),
    ChangeNotifierProvider(
      create: (_) => LocalProvider(AppDatabase()),
      child: const LocalNavigator(),
    ),
    const YoutubePage(),
    const HistoryPage(),
    const PlaylistNavigator(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscription == null) {
      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );
      _subscription = connectivityService.connectionStream.listen((
        isConnected,
      ) {
        if (!isConnected) {
          SnackbarUtil.showError(
            context,
            message: "You are offline",
            duration: const Duration(seconds: 3),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
    final navProvider = Provider.of<NavigationProvider>(context);
    final int selectedIndex = navProvider.selectedIndex;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          body: Stack(
            children: [
              // Rumah permanen untuk YoutubePlayerController (webview_flutter).
              // Harus selalu ter-mount di tree supaya perintah play/pause/seek
              // dari mana pun (song tile, mini player, dll) benar-benar sampai
              // ke WebView — sebelumnya widget ini tidak pernah dipasang sama
              // sekali, jadi video YouTube di Android tidak pernah jalan
              // kalau MusicPlayerPage belum dibuka.
              const Positioned(left: -10, top: -10, child: YoutubeMiniPlayer()),
              Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isDesktop)
                          AppSidebar(
                            selectedIndex: selectedIndex,
                            onSelect: (index) => navProvider.setIndex(index),
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: selectedIndex,
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
            ],
          ),
          bottomNavigationBar: !isDesktop
              ? BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => navProvider.setIndex(index),
                  selectedItemColor: Colors.green,
                  unselectedItemColor: Colors.white54,
                  backgroundColor: Colors.black,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_music_outlined),
                      label: "Local",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.smart_display_outlined),
                      label: "Youtube",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history_outlined),
                      label: "History",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.playlist_play_outlined),
                      label: "Playlist",
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
