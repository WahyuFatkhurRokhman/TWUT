import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';
import 'package:music_player/widgets/song_tile.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late List<Song> _songs;
  final PlaylistService _playlistService = PlaylistService(AppDatabase());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    DataNotifier().playlistNotifier.addListener(_loadSongs);

  }

  @override
  void dispose() {
    DataNotifier().playlistNotifier.removeListener(_loadSongs);


    super.dispose();
  }

  Future<void> _loadSongs() async {
    final songsData = await _playlistService.getSongsInPlaylist(
      widget.playlist.id,
    );
    final songs = songsData
        .map(
          (s) => Song(
            path: s.songPath,
            title: s.title,
            artist: s.artist,
            album: s.album,
            duration: s.durationMs != null
                ? Duration(milliseconds: s.durationMs!)
                : null,
          ),
        )
        .toList();

    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  Future<void> _singlePlay(BuildContext context, Song song) async {
    final audio = AudioManager();

    await audio.playLocalSong(song);

    if (context.mounted) {
      NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
    }
  }

  Future<void> _playPlaylist(BuildContext context, int index) async {
    final audio = AudioManager();

    audio.playPlaylist(_songs, playlistId: widget.playlist.id);

    if (context.mounted) {
      NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
    }
  }

  Future<void> _addToQueue(BuildContext context, Song song) async {
    final audio = AudioManager();

    if (audio.queue.isEmpty) {
      await _singlePlay(context, song);
    } else {
      audio.queue.addSong(song);

      if (context.mounted) {
        SnackbarUtil.showSuccess(
          context,
          message: '${song.title} ditambahkan ke antrian',
        );
      }
    }
  }

  void _showDetail(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(song.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Artis: ${song.artist}'),
            Text('Album: ${song.album}'),
            const SizedBox(height: 8),
            Text(
              'Path: ${song.path}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSong(BuildContext context, Song song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dari Playlist?'),
        content: Text('Anda yakin ingin menghapus "${song.title}" dari playlist ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await _playlistService.removeSongFromPlaylist(
        widget.playlist.id,
        song.path,
      );
      if (context.mounted) {
        SnackbarUtil.showSuccess(context, message: 'Lagu dihapus dari playlist');
        _loadSongs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header dengan tombol Back
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Daftar Lagu
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _songs.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return SongTile(
                        song: song,
                        isPlaying: false,
                        onTap: () async {
                          AudioManager().playPlaylist(
                            _songs,
                            playlistId: widget.playlist.id,
                          );
                          AudioManager().local.queue.setIndex(index);
                          await AudioManager().local.play();

                          if (context.mounted) {
                            NavigationUtil.slideUp(
                              context,
                              const MusicPlayerPage(),
                              root: true,
                            );
                          }
                        },
                        onAddToQueue: () => _addToQueue(context, song),
                        onSinglePlay: () => _singlePlay(context, song),
                        onDetail: () => _showDetail(context, song),
                        onDelete: () => _deleteSong(context, song),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
