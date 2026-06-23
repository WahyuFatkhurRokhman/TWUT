import 'dart:io';
import 'dart:isolate';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/music_cache_service.dart';
import 'package:music_player/services/music_scanner.dart';

class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  ReceivePort? _receivePort;
  Isolate? _isolate;

  final Map<String, FolderGroup> _folderMap = {};
  final Map<String, ArtistGroup> _artistMap = {};
  final Map<String, AlbumGroup> _albumMap = {};

  bool _isLoading = false;
  bool _isScanned = false;
  bool get isLoading => _isLoading;
  bool get isScanned => _isScanned;

  Future<void> loadSongs({
    required Function(Song) onSongInserted,
    required Function(List<FolderGroup>) onFolderGroupsUpdated,
    required Function(List<ArtistGroup>) onArtistGroupsUpdated,
    required Function(List<AlbumGroup>) onAlbumGroupsUpdated,
    required Function(bool) onLoadingChanged,
    required Function(bool) onScannedChanged,
    required Function() onScanFinished,
    required Future<List<Song>> Function() getSongsList,
  }) async {
    if (_isLoading || _isScanned) return;

    _reset();
    _isLoading = true;
    onLoadingChanged(true);

    /// ===============================
    /// LOAD DARI CACHE DULU
    /// ===============================
    final cacheSongs = await MusicCacheService.loadSongs();

    if (cacheSongs.isNotEmpty) {
      for (final song in cacheSongs) {
        _insertSongRealtime(song, onSongInserted, onFolderGroupsUpdated, onArtistGroupsUpdated, onAlbumGroupsUpdated);
      }

      _isLoading = false;
      onLoadingChanged(false);
      _isScanned = true;
      onScannedChanged(true);
      onScanFinished();
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
        _finishScan(onScanFinished, onLoadingChanged, onScannedChanged, getSongsList);
        return;
      }

      if (data is Song) {
        _insertSongRealtime(data, onSongInserted, onFolderGroupsUpdated, onArtistGroupsUpdated, onAlbumGroupsUpdated);
      }
    });
  }

  void _insertSongRealtime(
    Song song,
    Function(Song) onSongInserted,
    Function(List<FolderGroup>) onFolderGroupsUpdated,
    Function(List<ArtistGroup>) onArtistGroupsUpdated,
    Function(List<AlbumGroup>) onAlbumGroupsUpdated,
  ) {
    onSongInserted(song);

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

    onFolderGroupsUpdated(_folderMap.values.toList());

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

    onArtistGroupsUpdated(_artistMap.values.toList());

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

    onAlbumGroupsUpdated(_albumMap.values.toList());
  }

  Future<void> _finishScan(
    Function() onScanFinished,
    Function(bool) onLoadingChanged,
    Function(bool) onScannedChanged,
    Future<List<Song>> Function() getSongsList,
  ) async {
    _isLoading = false;
    onLoadingChanged(false);
    _isScanned = true;
    onScannedChanged(true);

    /// simpan ke cache setelah scan selesai
    final songs = await getSongsList();
    await MusicCacheService.saveSongs(songs);

    onScanFinished();

    _receivePort?.close();
    _receivePort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  Future<void> refreshSongs({
    required Function(Song) onSongInserted,
    required Function(List<FolderGroup>) onFolderGroupsUpdated,
    required Function(List<ArtistGroup>) onArtistGroupsUpdated,
    required Function(List<AlbumGroup>) onAlbumGroupsUpdated,
    required Function(bool) onLoadingChanged,
    required Function(bool) onScannedChanged,
    required Function() onScanFinished,
    required Future<List<Song>> Function() getSongsList,
  }) async {
    await MusicCacheService.clear(); // hapus cache
    stopScan();
    _reset();
    await loadSongs(
      onSongInserted: onSongInserted,
      onFolderGroupsUpdated: onFolderGroupsUpdated,
      onArtistGroupsUpdated: onArtistGroupsUpdated,
      onAlbumGroupsUpdated: onAlbumGroupsUpdated,
      onLoadingChanged: onLoadingChanged,
      onScannedChanged: onScannedChanged,
      onScanFinished: onScanFinished,
      getSongsList: getSongsList,
    );
  }

  void stopScan() {
    _receivePort?.close();
    _receivePort = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _isLoading = false;
  }

  void _reset() {
    _folderMap.clear();
    _artistMap.clear();
    _albumMap.clear();

    _isScanned = false;
  }

  void dispose() {
    stopScan();
  }
}
