import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/models/album_group.dart';

String getGroupTitle(GroupMusic group) {
  if (group is FolderGroup) {
    return group.name;
  } else if (group is ArtistGroup) {
    return group.artistName;
  } else if (group is AlbumGroup) {
    return group.albumName; // atau name
  } else {
    return "Unknown";
  }
}