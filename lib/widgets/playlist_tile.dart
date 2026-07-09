import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class PlaylistTile extends StatelessWidget {
  final String title;
  final List<Uint8List?> artworkList;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onShufflePlay;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const PlaylistTile({
    super.key,
    required this.title,
    this.artworkList = const [],
    required this.onTap,
    required this.onPlay,
    required this.onShufflePlay,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: artworkList.isEmpty
                  ? const Icon(Icons.playlist_play, color: AppColors.accent, size: 32)
                  : GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: artworkList.take(4).map((bytes) => 
                        bytes != null ? Image.memory(bytes, fit: BoxFit.cover) : const SizedBox()
                      ).toList(),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'play') {
                  onPlay();
                } else if (value == 'shuffle') {
                  onShufflePlay();
                } else if (value == 'rename') {
                  onRename();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'play',
                  child: Text('Mainkan'),
                ),
                const PopupMenuItem(
                  value: 'shuffle',
                  child: Text('Mainkan (Shuffle)'),
                ),
                const PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
