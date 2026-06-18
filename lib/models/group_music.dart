import 'song.dart';
import 'folder_group.dart';
import 'album_group.dart';
import 'artist_group.dart';
import 'alphabet_group.dart';

abstract class GroupMusic {
  String get key;
  String get displayName;
  List<Song> get songs;
  int get songCount => songs.length;

  Map<String, dynamic> toJson();

  static GroupMusic fromJson(Map<String, dynamic> json, String type) {
    switch (type) {
      case 'folder':
        return FolderGroup.fromJson(json);
      case 'album':
        return AlbumGroup.fromJson(json);
      case 'artist':
        return ArtistGroup.fromJson(json);
      case 'alphabet':
        return AlphabetGroup.fromJson(json);
      default:
        throw Exception('Unknown group type: $type');
    }
  }
}