
import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/widgets/add_to_playlist_dialog.dart';
import 'package:music_player/widgets/media_artwork.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onAddToQueue;
  final VoidCallback onDetail;
  final VoidCallback onSinglePlay;
  final VoidCallback? onDelete;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onAddToQueue,
    required this.onDetail,
    required this.onSinglePlay,
    this.onDelete,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: MediaArtwork(
          media: song.toNowPlaying(),
          size: 48,
          radius: 8,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color: isPlaying ? Colors.blueAccent : null,
        ),
      ),
      subtitle: Text(song.artist, style: const TextStyle(fontSize: 12)),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'add_queue') {
            onAddToQueue.call();
          } else if (value == 'detail') {
            onDetail.call();
          } else if(value == 'single_play'){
            onSinglePlay.call();
          } else if (value == 'add_playlist') {
            showDialog(
              context: context,
              builder: (context) => AddToPlaylistDialog(db: AppDatabase(), song: song),
            );
          } else if (value == 'delete') {
            onDelete?.call();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
              value: 'single_play',
              child: Text('Mainkan')
          ),
          const PopupMenuItem(
            value: 'add_queue',
            child: Text('Tambahkan ke Antrian'),
          ),
          const PopupMenuItem(
            value: 'add_playlist',
            child: Text('Tambahkan ke Playlist'),
          ),
          const PopupMenuItem(
            value: 'detail',
            child: Text('Info Detail'),
          ),
          if (onDelete != null)
            const PopupMenuItem(
              value: 'delete',
              child: Text('Hapus dari Playlist', style: TextStyle(color: Colors.red)),
            ),
        ],
        icon: Icon(
          Icons.more_vert,
          color: isPlaying ? Colors.blueAccent : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
