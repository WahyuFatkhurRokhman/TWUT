import 'package:flutter/material.dart';
import 'package:music_player/pages/local_page.dart';
import 'package:music_player/pages/permission_page.dart';
import 'package:music_player/pages/youtube_page.dart';
import 'package:music_player/services/music_scanner.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:music_player/widgets/app_sidebar.dart';
import 'package:music_player/widgets/mini_player.dart';

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
    const LocalPage(),
    const YoutubePage(),
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

      if (isDesktop) {
        return Scaffold(
          body: Row(
            children: [
              AppSidebar(
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
              ),
              Expanded(
                child: Scaffold(
                  body: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 108),
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: MiniPlayer(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // MOBILE: Bottom Navigation
      return Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 108),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.white54,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: "Local"),
            BottomNavigationBarItem(icon: Icon(Icons.smart_display_outlined), label: "Youtube"),
          ],
        ),
      );
    });
  }
}
