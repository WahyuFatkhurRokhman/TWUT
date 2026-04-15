import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../models/folder_group.dart';
import '../models/album_group.dart';
import '../models/artist_group.dart';
import '../models/alphabet_group.dart';

import 'music_scanner.dart';
import 'music_cache_service.dart';

class MusicService {

  Future<List<Song>> _getSongs() async {
    final userMusicDir = Directory('C:\\Users');

    if (!await userMusicDir.exists()) return [];

    final cache = await MusicCacheService.loadSongs();
    if (cache.isNotEmpty) {
      print("Load dari cache ⚡");
      return cache;
    }

    final songs = await compute(_scanInIsolate, userMusicDir.path);
    await MusicCacheService.saveSongs(songs);

    return songs;
  }

  static List<Song> _scanInIsolate(String path) {
    return MusicScanner.scanMusicStrict(path);
  }


  Future<List<FolderGroup>> getByFolder() async {
    final songs = await _getSongs();

    final Map<String, List<Song>> map = {};

    for (final song in songs) {
      final folderPath = Directory(song.path).parent.path;

      map.putIfAbsent(folderPath, () => []);
      map[folderPath]!.add(song);
    }

    return map.entries.map((e) {
      return FolderGroup(
        path: e.key,
        name: e.key.split(Platform.pathSeparator).last,
        songs: e.value,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }


  Future<List<AlbumGroup>> getByAlbum() async {
    final songs = await _getSongs();

    final Map<String, List<Song>> map = {};

    for (final song in songs) {
      final album = song.album.isNotEmpty ? song.album : 'Unknown Album';
      map.putIfAbsent(album, () => []);
      map[album]!.add(song);
    }

    map.values.forEach((list) {
      list.sort((a, b) => a.title.compareTo(b.title));
    });

    final keys = map.keys.toList()..sort();

    return keys
        .map((k) => AlbumGroup(albumName: k, songs: map[k]!))
        .toList();
  }


  Future<List<ArtistGroup>> getByArtist() async {
    final songs = await _getSongs();

    final Map<String, List<Song>> map = {};

    for (final song in songs) {
      final artist = song.artist.isNotEmpty ? song.artist : 'Unknown Artist';
      map.putIfAbsent(artist, () => []);
      map[artist]!.add(song);
    }

    map.values.forEach((list) {
      list.sort((a, b) => a.title.compareTo(b.title));
    });

    final keys = map.keys.toList()..sort();

    return keys
        .map((k) => ArtistGroup(artistName: k, songs: map[k]!))
        .toList();
  }


  Future<List<AlphabetGroup>> getByAlphabet() async {
    final songs = await _getSongs();

    final Map<String, List<Song>> map = {};

    for (final song in songs) {
      final key = _getGroupKey(song.title);
      map.putIfAbsent(key, () => []);
      map[key]!.add(song);
    }

    map.values.forEach((list) {
      list.sort((a, b) => a.title.compareTo(b.title));
    });

    final sortedKeys = _sortAlphabetKeys(map.keys.toList());

    return sortedKeys
        .map((k) => AlphabetGroup(letter: k, songs: map[k]!))
        .toList();
  }

  String _getGroupKey(String text) {
    if (text.isEmpty) return '#';

    final char = text.trim()[0];

    if (RegExp(r'[A-Za-z]').hasMatch(char)) {
      return char.toUpperCase();
    }

    if (RegExp(r'[0-9]').hasMatch(char)) {
      return '0-9';
    }

    return '#';
  }

  List<String> _sortAlphabetKeys(List<String> keys) {
    keys.sort((a, b) {
      if (a == '0-9') return -1;
      if (b == '0-9') return 1;
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });

    return keys;
  }
}