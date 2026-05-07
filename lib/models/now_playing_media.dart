import 'dart:typed_data';

class NowPlayingMedia {
  final String id;
  final String sourceId;

  final String title;
  final String artist;

  final Uint8List? artworkBytes;
  final String? artworkUrl;

  final Duration? duration;

  final bool isYoutube;

  const NowPlayingMedia({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.artist,
    this.artworkBytes,
    this.artworkUrl,
    this.duration,
    required this.isYoutube,
  });

  String get path => sourceId;
}