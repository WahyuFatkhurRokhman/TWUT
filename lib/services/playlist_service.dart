import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:drift/drift.dart';

class PlaylistService {
  final AppDatabase _db;

  PlaylistService(this._db);

  // Create a new playlist
  Future<int> createPlaylist(String name) async {
    return await _db.into(_db.playlists).insert(PlaylistsCompanion.insert(name: name));
  }

  // Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    return await _db.select(_db.playlists).get();
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist(int playlistId, Song song) async {
    await _db.into(_db.playlistSongs).insert(PlaylistSongsCompanion.insert(
      playlistId: playlistId,
      songPath: song.path,
      title: song.title,
      artist: Value(song.artist),
      album: Value(song.album),
      durationMs: Value(song.duration?.inMilliseconds),
    ));
  }

  // Get songs in a playlist
  Future<List<PlaylistSong>> getSongsInPlaylist(int playlistId) async {
    final query = _db.select(_db.playlistSongs)..where((t) => t.playlistId.equals(playlistId));
    return await query.get();
  }

  // Delete a playlist
  Future<void> deletePlaylist(int playlistId) async {
    await (_db.delete(_db.playlists)..where((t) => t.id.equals(playlistId))).go();
  }
}
