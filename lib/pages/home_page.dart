import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/history_play_local_song.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/services/music_scanner.dart';
import 'package:music_player/widgets/bento_card.dart';
import 'package:music_player/widgets/album_card.dart';
import 'package:music_player/config/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HistoryPlayLocalSong _historyService = HistoryPlayLocalSong(
    AppDatabase(),
  );
  final PlaylistService _playlistService = PlaylistService(AppDatabase());

  List<Song> _recentSongs = [];
  List<Song> _favoriteSongs = [];
  List<Playlist> _recentPlaylists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    DataNotifier().historyNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    DataNotifier().historyNotifier.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final recent = await _historyService.getRecentSongs();
    final frequent = await _historyService.getFrequentlyPlayedSongs();
    final recentPlaylists = await _historyService.getRecentPlaylist();
    if (mounted) {
      setState(() {
        _recentSongs = recent;
        _favoriteSongs = frequent;
        _recentPlaylists = recentPlaylists;
      });
    }
  }

  Future<void> _startScanning() async {
    // 1. Cek izin
    if (!(await MusicScanner.hasPermissions())) {
      if (!(await MusicScanner.requestPermissions())) {
        print("Izin tidak diberikan");
        return;
      }
    }

    // 2. Setup ReceivePort untuk menerima data dari Isolate
    final receivePort = ReceivePort();

    // 3. Spawn Isolate
    await Isolate.spawn(MusicScanner.scanMusicStream, receivePort.sendPort);

    // 4. Dengarkan data yang dikirim dari Isolate
    receivePort.listen((message) {
      if (message is Song) {
        // Simpan lagu ke database jika diperlukan
        print("Ditemukan lagu: ${message.title}");
      } else if (message == null) {
        // Pemindaian selesai
        receivePort.close();
        _loadData(); // Refresh UI setelah scan selesai
        print("Scan selesai");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              backgroundColor: AppColors.background,
              body: CustomScrollView(
                slivers: [
                  // Figma Header & Bento Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LIBRARY EXPLORER",
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFBCCBB9),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "TWUT",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildBentoGrid(),
                        ],
                      ),
                    ),
                  ),

                  // Grids of Albums (Songs)
                  if (_recentSongs.isNotEmpty)
                    _buildAlbumSection('Recently Played', _recentSongs),
                  if (_favoriteSongs.isNotEmpty)
                    _buildAlbumSection('Frequently Played', _favoriteSongs),
                  
                  // Bottom Spacer
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          );
        }
        return AppRouter.generateRoute(settings);
      },
    );
  }

  Widget _buildBentoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid responds to screen width
        int crossAxisCount = constraints.maxWidth > 1000 ? 4 : 2;
        double childAspectRatio = constraints.maxWidth > 1000 ? 1.5 : 1.3;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            BentoCard(
              icon: Icons.folder_open_rounded,
              title: "Hi-Res Masters",
              subtitle: "245 tracks • FLAC Lossless",
              iconColor: const Color(0xFF53E076),
              onTap: () {
                // Future: Navigate to a filtered view
              },
            ),
            BentoCard(
              icon: Icons.download_rounded,
              title: "Downloads",
              subtitle: "${_recentSongs.length} local files",
              iconColor: Colors.blueAccent,
              onTap: () {
                // Navigate to Local Page
                // Assuming we can access the parent or use a global route
                // For now, simple navigation if possible or placeholder
              },
            ),
            BentoCard(
              icon: Icons.playlist_play_rounded,
              title: "My Playlists",
              subtitle: "${_recentPlaylists.length} playlists",
              iconColor: Colors.purpleAccent,
              onTap: () {
                // Navigate to playlist page
              },
            ),
            BentoCard(
              icon: Icons.add_circle_outline_rounded,
              title: "Add Folder",
              subtitle: "Link local storage",
              iconColor: Colors.grey,
              onTap: () async {
                await _startScanning(); // Panggil fungsi di atas
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlbumSection(String title, List<Song> songs) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF53E076)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid count for album cards
                int crossAxisCount = 6;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 2;
                } else if (constraints.maxWidth < 1000) {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: songs.length > crossAxisCount ? crossAxisCount : songs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.50,
                  ),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return AlbumCard(
                      title: song.title,
                      artist: song.artist,
                      badgeText: "LOCAL",
                      onTap: () async {
                        await AudioManager().playLocalSong(song);
                        if (context.mounted) {
                          NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
