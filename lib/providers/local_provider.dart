import 'package:flutter/material.dart';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/music_service.dart';
import 'package:music_player/data/database.dart';

class LocalProvider extends ChangeNotifier {
  final MusicService musicService = MusicService.instance;
  final AppDatabase db;

  // --- State previously in MusicService ---
  final ValueNotifier<List<Song>> songs = ValueNotifier([]);
  final ValueNotifier<List<FolderGroup>> folderGroup = ValueNotifier([]);
  final ValueNotifier<List<ArtistGroup>> artistGroup = ValueNotifier([]);
  final ValueNotifier<List<AlbumGroup>> albumGroup = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isScanned = ValueNotifier(false);
  final ValueNotifier<GroupMusic?> selectedGroup = ValueNotifier(null);

  LocalProvider(this.db) {
  }

  Future<void> loadSongs() async {
    await musicService.loadSongs(
      onSongInserted: (song) {
        songs.value = [...songs.value, song];
      },
      onFolderGroupsUpdated: (groups) {
        folderGroup.value = groups;
      },
      onArtistGroupsUpdated: (groups) {
        artistGroup.value = groups;
      },
      onAlbumGroupsUpdated: (groups) {
        albumGroup.value = groups;
      },
      onLoadingChanged: (loading) {
        isLoading.value = loading;
      },
      onScannedChanged: (scanned) {
        isScanned.value = scanned;
      },
      onScanFinished: () {

      },
      getSongsList: () async => songs.value,
    );
  }

  Future<void> refreshSongs() async {
    await musicService.refreshSongs(
      onSongInserted: (song) {
        songs.value = [...songs.value, song];
      },
      onFolderGroupsUpdated: (groups) {
        folderGroup.value = groups;
      },
      onArtistGroupsUpdated: (groups) {
        artistGroup.value = groups;
      },
      onAlbumGroupsUpdated: (groups) {
        albumGroup.value = groups;
      },
      onLoadingChanged: (loading) {
        isLoading.value = loading;
      },
      onScannedChanged: (scanned) {
        isScanned.value = scanned;
      },
      onScanFinished: () {},
      getSongsList: () async => songs.value,
    );
  }

  @override
  void dispose() {
    songs.dispose();
    folderGroup.dispose();
    artistGroup.dispose();
    albumGroup.dispose();
    isLoading.dispose();
    isScanned.dispose();
    selectedGroup.dispose();
    super.dispose();
  }
}
