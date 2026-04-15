import 'dart:typed_data';

class Song {
  final String path;
  final String title;
  final String artist;
  final String album;
  final Duration? duration;
  final Uint8List? artwork;

  Song({
    required this.path,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.duration,
    this.artwork,
  });

  String get fileName => path.split('\\').last;

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration?.inMilliseconds,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      path: json['path'],
      title: json['title'],
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Unknown Album',
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
    );
  }
}