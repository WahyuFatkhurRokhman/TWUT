import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/widgets/song_tile.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String playlistName;
  final List<Song> songs;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  Future<void> _playPlaylist(bool shuffle) async {
    final audio = AudioManager();
    await audio.playPlaylist(songs, shuffle: shuffle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(playlistName, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.card,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _playPlaylist(false),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () => _playPlaylist(true),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongTile(
            song: song,
            isPlaying: false, // You might want to implement check for playing
            onTap: () {
              // Play playlist starting from this song, adding all to queue
              AudioManager().playPlaylist(songs);
              AudioManager().playAt(index);
            },
            onAddToQueue: () {
              AudioManager().queue.addSong(song);
            },
            onDetail: () {
              // Implement detail dialog if needed
            },
            onSinglePlay: () {
              AudioManager().playLocalSong(song);
            },
          );
        },
      ),
    );
  }
}
