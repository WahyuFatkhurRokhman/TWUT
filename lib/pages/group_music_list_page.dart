import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/services/play_queue.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';
import 'package:music_player/widgets/song_tile.dart';
import '../services/audio_manager.dart';

class GroupMusicListPage extends StatelessWidget {
  final GroupMusic groupMusic;

  const GroupMusicListPage({super.key, required this.groupMusic});

  void _playAndOpen(BuildContext context, int index, Song song) async {
    final audio = AudioManager();
    final queue = PlayQueue();

    // Memasukkan seluruh daftar lagu dari grup ini ke antrean
    queue.addFolder(groupMusic);
    queue.setIndex(index);

    await audio.playFromQueue();
    // Menggunakan slideUp sesuai utilitas navigasi Anda
    NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
  }

  void _singlePlay(BuildContext context, Song song) async {
    final audio = AudioManager();
    final queue = PlayQueue();

    queue.clear();
    queue.addSong(song);

    await audio.playFromQueue();
    NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
  }

  void _addToQueue(BuildContext context, Song song) async {
    final audio = AudioManager();

    if (audio.queue.isEmpty) {
      _singlePlay(context, song);
    } else {
      audio.queue.addSong(song);
      SnackbarUtil.showSuccess(context, message: '${song.title} ditambahkan ke antrean');
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();

    return Scaffold(
      appBar: AppBar(
        // Menggunakan displayName agar dinamis (bisa nama folder, artis, atau album)
        title: Text(groupMusic.displayName),
        elevation: 0,
      ),
      body: ValueListenableBuilder<Song?>(
        valueListenable: audio.currentSong,
        builder: (context, currentSong, _) {
          return ListView.separated(
            // Mengambil list lagu dari groupMusic
            itemCount: groupMusic.songs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final song = groupMusic.songs[index];
              final isPlaying = currentSong?.path == song.path;

              return SongTile(
                song: song,
                isPlaying: isPlaying,
                onTap: () => _playAndOpen(context, index, song),
                onAddToQueue: () => _addToQueue(context, song),
                onSinglePlay: () => _singlePlay(context, song),
                onDetail: () {
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
                          Text('Path: ${song.path}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}