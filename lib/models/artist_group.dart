import 'group_music.dart';
import 'song.dart';

class ArtistGroup extends GroupMusic {
  final String artistName;
  @override
  final List<Song> songs;

  ArtistGroup({
    required this.artistName,
    required this.songs,
  });

  @override
  String get key => artistName;

  @override
  String get displayName => artistName;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'artist',
      'artistName': artistName,
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }

  factory ArtistGroup.fromJson(Map<String, dynamic> json) {
    return ArtistGroup(
      artistName: json['artistName'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
    );
  }
}