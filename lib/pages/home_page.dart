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

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              backgroundColor: const Color(0xFF0A0A0A),
              body: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _HeroBanner()),
                  if (_favoriteSongs.isNotEmpty)
                    _buildSection('Most Played', _favoriteSongs),
                  if (_recentSongs.isNotEmpty)
                    _buildSection('Recent Plays', _recentSongs),
                  if (_recentPlaylists.isNotEmpty)
                    _buildPlaylistSection('Recent Playlists', _recentPlaylists),
                ],
              ),
            ),
          );
        }
        return AppRouter.generateRoute(settings);
      },
    );
  }

  Widget _buildPlaylistSection(String title, List<Playlist> playlists) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          ...playlists.map(
            (playlist) => ListTile(
              leading: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
              title: Text(
                playlist.name,
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                final songsData = await _playlistService.getSongsInPlaylist(
                  playlist.id,
                );
                final songs = songsData
                    .map(
                      (s) => Song(
                        path: s.songPath,
                        title: s.title,
                        artist: s.artist,
                        album: s.album,
                        duration: Duration(milliseconds: s.durationMs ?? 0),
                      ),
                    )
                    .toList();
                await AudioManager().playPlaylist(songs, playlistId: playlist.id);
                
                if (context.mounted) {
                  NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSection(String title, List<Song> items) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No songs yet',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            )
          else
            ...items.map(
              (song) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white38),
                ),
                onTap: () async {
                  await AudioManager().playLocalSong(song);
                  if (context.mounted) {
                    NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
                  }
                },
              ),
            ),
        ]),
      ),
    );
  }
}

// ── HERO BANNER ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF0d6e32), Color(0xFF0A0A0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 255, 255, 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'TWUT',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
