import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class AlbumCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? artworkUrl; // For web images if any
  final String badgeText; // e.g. "LOCAL"
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.title,
    required this.artist,
    this.artworkUrl,
    required this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AspectRatio ensures square artwork
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  image: artworkUrl != null
                      ? DecorationImage(
                          image: NetworkImage(artworkUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: artworkUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.album_rounded,
                          size: 48,
                          color: Colors.white24,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            const SizedBox(height: 4),
            Text(
              artist,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            const SizedBox(height: 8),
            // Small Platform/Format Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
