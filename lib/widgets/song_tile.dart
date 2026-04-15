
import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onAddToQueue;
  final VoidCallback onDetail;
  final VoidCallback onSinglePlay;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onAddToQueue,
    required this.onDetail,
    required this.onSinglePlay,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.music_note,
        color: isPlaying ? Colors.blueAccent : Colors.blue,
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
            value: 'detail',
            child: Text('Info Detail'),
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
