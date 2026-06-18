import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/config/app_colors.dart';

class PlaylistSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const PlaylistSongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note, color: AppColors.accent),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}
