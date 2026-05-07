import 'package:flutter/material.dart';
import 'package:music_player/desktop/youtube_page.dart';
import 'package:music_player/widgets/mini_player.dart';
import 'sidebar_desktop.dart';
import 'local_page.dart';

class DesktopMainPage extends StatefulWidget {
  const DesktopMainPage({super.key});

  @override
  State<DesktopMainPage> createState() => _DesktopMainPageState();
}

class _DesktopMainPageState extends State<DesktopMainPage> {
  int selectedIndex = 0;

  final pages = [
    Container(), // Home (kosong, sesuai permintaan tuan)
    const LocalPage(),
    const YoutubePage(),
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 🔹 LAYOUT UTAMA
        Row(
          children: [
            SidebarDesktop(
              selectedIndex: selectedIndex,
              onSelect: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
            ),

            Expanded(
              child: Padding(
                // ⬇️ kasih ruang biar konten gak ketutup mini player
                padding: const EdgeInsets.only(bottom: 108),

                child: (selectedIndex >= 0 &&
                        selectedIndex < pages.length)
                    ? pages[selectedIndex]
                    : const Center(
                        child: Text(
                          "Halaman tidak ditemukan",
                        ),
                      ),
              ),
            ),
          ],
        ),

        // 🔹 MINI PLAYER FULL WIDTH 🚀
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MiniPlayer(),
        ),
      ],
    ),
  );
}
}