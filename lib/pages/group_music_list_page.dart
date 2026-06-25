import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';
import 'package:music_player/widgets/song_tile.dart';

class GroupMusicListPage extends StatelessWidget {
  final GroupMusic groupMusic;

  const GroupMusicListPage({
    super.key,
    required this.groupMusic,
  });

  Future<void> _playAndOpen(
      BuildContext context,
      int index,
      ) async {
    final audio = AudioManager();

    try {
      await audio.playLocalGroup(groupMusic, startIndex: index);

      if (context.mounted) {
        NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
      }
    } catch (e) {
      debugPrint("Error playing local group: $e");
      if (context.mounted) {
        SnackbarUtil.showError(context, message: 'Gagal memutar musik: $e');
      }
    }
  }

  Future<void> _singlePlay(BuildContext context, Song song) async {
    final audio = AudioManager();

    try {
      await audio.playLocalSong(song);

      if (context.mounted) {
        NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
      }
    } catch (e) {
      debugPrint("Error playing local song: $e");
      if (context.mounted) {
        SnackbarUtil.showError(context, message: 'Gagal memutar musik: $e');
      }
    }
  }

  Future<void> _addToQueue(BuildContext context, Song song) async {
    final audio = AudioManager();

    if (audio.queue.isEmpty) {
      // Queue kosong → langsung play dan buka player
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

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Song list
            Expanded(
              child: ValueListenableBuilder<Song?>(
                valueListenable: audio.currentSong,  // ← dari getter baru di AudioManager
                builder: (context, currentSong, _) {
                  return ListView.separated(
                    itemCount: groupMusic.songs.length,
                    separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final song = groupMusic.songs[index];
                      final isPlaying = currentSong?.path == song.path;

                      return SongTile(
                        song: song,
                        isPlaying: isPlaying,
                        onTap: () => _playAndOpen(context, index),
                        onAddToQueue: () => _addToQueue(context, song),
                        onSinglePlay: () => _singlePlay(context, song),
                        onDetail: () => _showDetail(context, song),
                      );
                    },
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
