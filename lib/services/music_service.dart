import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../models/folder_group.dart';
import '../models/artist_group.dart';
import '../models/album_group.dart';
import '../services/music_scanner.dart';
import '../services/music_cache_service.dart';

class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  /// SONGS
  final ValueNotifier<List<Song>> songs = ValueNotifier([]);

  /// GROUPS
  final ValueNotifier<List<FolderGroup>> folderGroup = ValueNotifier([]);
  final ValueNotifier<List<ArtistGroup>> artistGroup = ValueNotifier([]);
  final ValueNotifier<List<AlbumGroup>> albumGroup = ValueNotifier([]);

  /// STATE
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isScanned = ValueNotifier(false);

  ReceivePort? _receivePort;
  Isolate? _isolate;

  final Map<String, FolderGroup> _folderMap = {};
  final Map<String, ArtistGroup> _artistMap = {};
  final Map<String, AlbumGroup> _albumMap = {};

  Future<void> loadSongs() async {
    if (isLoading.value || isScanned.value) return;

    _reset();
    isLoading.value = true;

    /// ===============================
    /// LOAD DARI CACHE DULU
    /// ===============================
    final cacheSongs = await MusicCacheService.loadSongs();

    if (cacheSongs.isNotEmpty) {
      for (final song in cacheSongs) {
        _insertSongRealtime(song);
      }

      isLoading.value = false;
      isScanned.value = true;
      return;
    }

    /// ===============================
    /// JIKA CACHE KOSONG => SCAN
    /// ===============================
    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(
      MusicScanner.scanMusicStream,
      _receivePort!.sendPort,
    );

    _receivePort!.listen((data) {
      if (data == null) {
        _finishScan();
        return;
      }

      if (data is Song) {
        _insertSongRealtime(data);
      }
    });
  }

  void _insertSongRealtime(Song song) {
    songs.value = [...songs.value, song];

    /// folder
    final folderPath = File(song.path).parent.path;
    final folderName = folderPath.split(Platform.pathSeparator).last;

    if (_folderMap.containsKey(folderPath)) {
      _folderMap[folderPath]!.songs.add(song);
    } else {
      _folderMap[folderPath] = FolderGroup(
        path: folderPath,
        name: folderName,
        songs: [song],
      );
    }

    folderGroup.value = _folderMap.values.toList();

    /// artist
    final artist =
    song.artist.trim().isEmpty ? 'Unknown Artist' : song.artist;

    if (_artistMap.containsKey(artist)) {
      _artistMap[artist]!.songs.add(song);
    } else {
      _artistMap[artist] = ArtistGroup(
        artistName: artist,
        songs: [song],
      );
    }

    artistGroup.value = _artistMap.values.toList();

    /// album
    final album =
    song.album.trim().isEmpty ? 'Unknown Album' : song.album;

    if (_albumMap.containsKey(album)) {
      _albumMap[album]!.songs.add(song);
    } else {
      _albumMap[album] = AlbumGroup(
        albumName: album,
        songs: [song],
      );
    }

    albumGroup.value = _albumMap.values.toList();
  }

  Future<void> _finishScan() async {
    isLoading.value = false;
    isScanned.value = true;

    /// simpan ke cache setelah scan selesai
    await MusicCacheService.saveSongs(songs.value);

    _receivePort?.close();
    _receivePort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  Future<void> refreshSongs() async {
    await MusicCacheService.clear(); // hapus cache
    stopScan();
    _reset();
    await loadSongs();
  }

  void stopScan() {
    _receivePort?.close();
    _receivePort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    isLoading.value = false;
  }

  void _reset() {
    songs.value = [];

    folderGroup.value = [];
    artistGroup.value = [];
    albumGroup.value = [];

    _folderMap.clear();
    _artistMap.clear();
    _albumMap.clear();

    isScanned.value = false;
  }

  void dispose() {
    stopScan();

    songs.dispose();
    folderGroup.dispose();
    artistGroup.dispose();
    albumGroup.dispose();

    isLoading.dispose();
    isScanned.dispose();
  }
}