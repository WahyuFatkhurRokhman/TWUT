import 'package:flutter/material.dart';
import 'package:music_player/desktop/desktop_main_pages.dart';
import 'package:music_player/desktop/local_page.dart';
import 'package:music_player/pages/youtube_page.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:music_player/widgets/mini_player.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Home Page")), // Placeholder Home
    const LocalPage(),
    const YoutubePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // DESKTOP: Side Navigation (Sudah dibuat sebelumnya)
    if (PlatformUtil.isDesktop) {
      return const DesktopMainPage();
    }

    // MOBILE: Bottom Navigation
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 108), // Ruang untuk MiniPlayer
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
  }
}
