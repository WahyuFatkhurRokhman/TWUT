import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/widgets/group_music_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlaylistService _playlistService = PlaylistService(AppDatabase());
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _playlistService.getAllPlaylists();
    if (mounted) {
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    }
  }

  Future<List<Song>> _getSongs(Playlist playlist) async {
    final songsData = await _playlistService.getSongsInPlaylist(playlist.id);
    return songsData.map((s) => Song(
      path: s.songPath,
      title: s.title,
      artist: s.artist ?? 'Unknown',
      album: s.album ?? 'Unknown',
      duration: Duration(milliseconds: s.durationMs ?? 0),
    )).toList();
  }

  void _navigateToPlaylist(Playlist playlist) async {
    final songs = await _getSongs(playlist);
    if (!mounted) return;
    _homeNavigatorKey.currentState?.pushNamed(
      AppRouter.playlistDetail,
      arguments: {
        'playlistName': playlist.name,
        'songs': songs,
      },
    );
  }

  // Warna gradien per playlist berdasarkan index
  List<Color> _gradientColors(int index) {
    const gradients = [
      [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
      [Color(0xFFEC4899), Color(0xFF7C3AED)],
      [Color(0xFF0EA5E9), Color(0xFF2563EB)],
      [Color(0xFF10B981), Color(0xFF065F46)],
      [Color(0xFFF59E0B), Color(0xFFDC2626)],
      [Color(0xFFF97316), Color(0xFFEA580C)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _homeNavigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: const Color(0xFF0A0A0A),
              body: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1DB954)),
              )
                  : CustomScrollView(
                slivers: [
                  // ── HERO ──
                  SliverToBoxAdapter(
                    child: _HeroBanner(),
                  ),

                  // ── HEADER PLAYLIST ──
                  if (_playlists.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'YOUR PLAYLISTS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0x66FFFFFF),
                                letterSpacing: 2.5,
                              ),
                            ),
                            Text(
                              '${_playlists.length} playlists',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── LIST PLAYLIST ──
                  if (_playlists.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final playlist = _playlists[index];
                            final colors = _gradientColors(index);
                            return _PlaylistTile(
                              playlist: playlist,
                              gradientColors: colors,
                              onTap: () => _navigateToPlaylist(playlist),
                              onPlay: () async {
                                final songs = await _getSongs(playlist);
                                AudioManager().playPlaylist(songs, shuffle: false);
                              },
                              onShuffle: () async {
                                final songs = await _getSongs(playlist);
                                AudioManager().playPlaylist(songs, shuffle: true);
                              },
                            );
                          },
                          childCount: _playlists.length,
                        ),
                      ),
                    ),

                  // ── EMPTY STATE ──
                  if (_playlists.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.queue_music_rounded,
                                size: 56, color: Color(0x33FFFFFF)),
                            SizedBox(height: 16),
                            Text(
                              'No playlists yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0x66FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return AppRouter.generateNestedRoute(settings);
      },
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
          // Lingkaran dekoratif
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Konten
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.5),
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

// ── PLAYLIST TILE ─────────────────────────────────────────────────────────────

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  const _PlaylistTile({
    required this.playlist,
    required this.gradientColors,
    required this.onTap,
    required this.onPlay,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white54,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // Nama playlist
            Expanded(
              child: Text(
                playlist.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Tombol play + menu
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onPlay,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1DB954),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                  color: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'play') onPlay();
                    if (value == 'shuffle') onShuffle();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text('Mainkan Daftar Putar', style: TextStyle(color:
                          Colors
                              .white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'shuffle',
                      child: Row(
                        children: [
                          Icon(Icons.shuffle_rounded, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text('Mainkan Acak', style: TextStyle(color: Colors
                              .white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}