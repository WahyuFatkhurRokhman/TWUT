import 'group_music.dart';
import 'song.dart';

class FolderGroup extends GroupMusic {
  final String path;
  final String name;
  @override
  final List<Song> songs;

  FolderGroup({
    required this.path,
    required this.name,
    required this.songs,
  });

  @override
  String get key => path;

  @override
  String get displayName => name;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'folder',
      'path': path,
      'name': name,
      'songs': songs.map((s) => s.toJson()).toList(),
    };
  }

  factory FolderGroup.fromJson(Map<String, dynamic> json) {
    return FolderGroup(
      path: json['path'],
      name: json['name'],
      songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
    );
  }
}