import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/playlist_service.dart';

void main() {
  late AppDatabase db;
  late PlaylistService service;

  Song buildSong({
    String path = '/music/song1.mp3',
    String title = 'Song One',
  }) {
    return Song(
      path: path,
      title: title,
      artist: 'Artist',
      album: 'Album',
      duration: const Duration(seconds: 200),
    );
  }

  setUp(() {
    // Fresh in-memory database for every test so state never leaks between
    // tests.
 db = AppDatabase.forTesting(
  NativeDatabase.memory(
    setup: (rawDb) => rawDb.execute('PRAGMA foreign_keys = ON'),
  ),
);   service = PlaylistService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlaylistService', () {
    test('createPlaylist stores a new playlist and returns its id',
        () async {
      final id = await service.createPlaylist('My Playlist');

      expect(id, isNonZero);

      final playlists = await service.getAllPlaylists();
      expect(playlists, hasLength(1));
      expect(playlists.first.name, 'My Playlist');
    });

    test('getAllPlaylists returns an empty list initially', () async {
      final playlists = await service.getAllPlaylists();
      expect(playlists, isEmpty);
    });

    test('addSongToPlaylist adds a song and returns true', () async {
      final playlistId = await service.createPlaylist('Chill');

      final added = await service.addSongToPlaylist(playlistId, buildSong());

      expect(added, isTrue);

      final songs = await service.getSongsInPlaylist(playlistId);
      expect(songs, hasLength(1));
      expect(songs.first.songPath, '/music/song1.mp3');
      expect(songs.first.title, 'Song One');
    });

    test('addSongToPlaylist returns false for a duplicate song path',
        () async {
      final playlistId = await service.createPlaylist('Chill');

      final firstAdd = await service.addSongToPlaylist(playlistId, buildSong());
      final secondAdd = await service.addSongToPlaylist(playlistId, buildSong());

      expect(firstAdd, isTrue);
      expect(secondAdd, isFalse);

      final songs = await service.getSongsInPlaylist(playlistId);
      expect(songs, hasLength(1));
    });

    test('getSongsInPlaylist only returns songs for the given playlist',
        () async {
      final playlistA = await service.createPlaylist('A');
      final playlistB = await service.createPlaylist('B');

      await service.addSongToPlaylist(playlistA, buildSong(path: '/a1.mp3'));
      await service.addSongToPlaylist(playlistB, buildSong(path: '/b1.mp3'));

      final songsA = await service.getSongsInPlaylist(playlistA);
      final songsB = await service.getSongsInPlaylist(playlistB);

      expect(songsA.map((s) => s.songPath), ['/a1.mp3']);
      expect(songsB.map((s) => s.songPath), ['/b1.mp3']);
    });

    test('getPlaylistDetailById returns the matching playlist', () async {
      final id = await service.createPlaylist('Details');

      final playlist = await service.getPlaylistDetailById(id);

      expect(playlist, isNotNull);
      expect(playlist!.name, 'Details');
    });

    test('getPlaylistDetailById returns null for an unknown id', () async {
      final playlist = await service.getPlaylistDetailById(9999);
      expect(playlist, isNull);
    });

    test('renamePlaylist updates the playlist name', () async {
      final id = await service.createPlaylist('Old Name');

      await service.renamePlaylist(id, 'New Name');

      final playlist = await service.getPlaylistDetailById(id);
      expect(playlist!.name, 'New Name');
    });

    test('removeSongFromPlaylist deletes only the targeted song', () async {
      final id = await service.createPlaylist('Removable');
      await service.addSongToPlaylist(id, buildSong(path: '/keep.mp3'));
      await service.addSongToPlaylist(id, buildSong(path: '/remove.mp3'));

      await service.removeSongFromPlaylist(id, '/remove.mp3');

      final songs = await service.getSongsInPlaylist(id);
      expect(songs.map((s) => s.songPath), ['/keep.mp3']);
    });

    test('deletePlaylist removes the playlist and cascades its songs',
        () async {
      final id = await service.createPlaylist('To Delete');
      await service.addSongToPlaylist(id, buildSong());

      await service.deletePlaylist(id);

      final playlists = await service.getAllPlaylists();
      expect(playlists, isEmpty);

      final songs = await service.getSongsInPlaylist(id);
      expect(songs, isEmpty);
    });
  });
}
