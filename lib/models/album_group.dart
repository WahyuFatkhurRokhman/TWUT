import 'group_music.dart';
import 'song.dart';

class AlbumGroup extends GroupMusic {
  final String albumName;
  @override
  final List<Song> songs;

  AlbumGroup({
    required this.albumName,
    required this.songs,
  });

  @override
  String get key => albumName;

  @override
  String get displayName => albumName;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'album',
      'albumName': albumName,
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }

  factory AlbumGroup.fromJson(Map<String, dynamic> json) {
    return AlbumGroup(
      albumName: json['albumName'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
    );
  }
}