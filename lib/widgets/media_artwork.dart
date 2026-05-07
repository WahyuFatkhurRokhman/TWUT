import 'package:flutter/material.dart';
import 'package:music_player/models/now_playing_media.dart';

class MediaArtwork extends StatelessWidget {
  final NowPlayingMedia media;

  final double size;
  final double radius;

  const MediaArtwork({
    super.key,
    required this.media,
    this.size = 60,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // LOCAL IMAGE
    if (media.artworkBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          media.artworkBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // YOUTUBE IMAGE
    if (media.artworkUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          media.artworkUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // FALLBACK
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.blueAccent.withOpacity(.1),
      ),
      child: const Icon(Icons.music_note_rounded),
    );
  }
}
