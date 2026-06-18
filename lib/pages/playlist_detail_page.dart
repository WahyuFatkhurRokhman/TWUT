import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/library_page.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/widgets/song_tile.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({
    super.key,
    required this.playlist
  });

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

    // Set title in LibraryPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libraryState = context.findAncestorStateOfType<LibraryPageState>();
      libraryState?.subPageTitle.value = widget.playlist.name;
    });
  }

  @override
  void dispose() {
    DataNotifier().playlistNotifier.removeListener(_loadSongs);

    // Reset title in LibraryPage
    final libraryState = context.findAncestorStateOfType<LibraryPageState>();
    libraryState?.subPageTitle.value = null;

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

  Future<void> _playPlaylist(bool shuffle) async {
    final audio = AudioManager();
    await audio.playPlaylist(
      _songs,
      shuffle: shuffle,
      playlistId: widget.playlist.id,
    );
  }

  Future<void> _removeSong(String songPath) async {
    await _playlistService.removeSongFromPlaylist(
      widget.playlist.id,
      songPath,
    );
    DataNotifier().notifyPlaylistChanged();
    _loadSongs();
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: _songs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return SongTile(
                          song: song,
                          isPlaying:
                              false,
                          onTap: () {
                            AudioManager().playPlaylist(
                              _songs,
                              playlistId: widget.playlist.id,
                            );
                            AudioManager().local.queue.setIndex(index);
                            AudioManager().local.play();
                          },
                          onAddToQueue: () {},
                          onSinglePlay: () {},
                          onDetail: () {},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
