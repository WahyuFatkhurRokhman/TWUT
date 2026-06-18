import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class PlaylistTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const PlaylistTile({
    super.key,
    required this.title,
    required this.onTap,
    this.onMoreTap,
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
            const Icon(Icons.playlist_play, color: AppColors.accent, size: 32),
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
            if (onMoreTap != null)
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onPressed: onMoreTap,
              ),
          ],
        ),
      ),
    );
  }
}
