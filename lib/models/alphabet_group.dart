import 'group_music.dart';
import 'song.dart';

class AlphabetGroup extends GroupMusic {
  final String letter;
  @override
  final List<Song> songs;

  AlphabetGroup({
    required this.letter,
    required this.songs,
  });

  @override
  String get key => letter;

  @override
  String get displayName => letter;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'alphabet',
      'letter': letter,
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }

  factory AlphabetGroup.fromJson(Map<String, dynamic> json) {
    return AlphabetGroup(
      letter: json['letter'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
    );
  }
}