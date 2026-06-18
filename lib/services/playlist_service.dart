import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:drift/drift.dart';
import 'package:music_player/utils/data_notifier.dart';

class PlaylistService {
  final AppDatabase _db;

  PlaylistService(this._db);

  // Create a new playlist
  Future<int> createPlaylist(String name) async {
    final id = await _db.into(_db.playlists).insert(PlaylistsCompanion.insert(name: name));
    DataNotifier().notifyPlaylistChanged();
    return id;
  }

  // Get all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    return await _db.select(_db.playlists).get();
  }

  // Add a song to a playlist
  Future<bool> addSongToPlaylist(int playlistId, Song song) async {
    // Check if song already exists in this playlist
    final existing = await (_db.select(_db.playlistSongs)
      ..where((t) => t.playlistId.equals(playlistId) & t.songPath.equals(song.path)))
        .getSingleOrNull();

    if (existing != null) {
      return false; // Already exists
    }

    await _db.into(_db.playlistSongs).insert(PlaylistSongsCompanion.insert(
      playlistId: playlistId,
      songPath: song.path,
      title: song.title,
      artist: Value(song.artist),
      album: Value(song.album),
      durationMs: Value(song.duration?.inMilliseconds),
    ));
    DataNotifier().notifyPlaylistChanged();
    return true; // Added
  }

  // Get songs in a playlist
  Future<List<PlaylistSong>> getSongsInPlaylist(int playlistId) async {
    final query = _db.select(_db.playlistSongs)..where((t) => t.playlistId.equals(playlistId));
    return await query.get();
  }


  // Rename a playlist
  Future<void> renamePlaylist(int playlistId, String newName) async {
    await (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId)))
        .write(PlaylistsCompanion(name: Value(newName)));
    DataNotifier().notifyPlaylistChanged();
  }

  // Remove a song from a playlist
  Future<void> removeSongFromPlaylist(int playlistId, String songPath) async {
    await (_db.delete(_db.playlistSongs)
      ..where((t) => t.playlistId.equals(playlistId) & t.songPath.equals(songPath)))
        .go();
    DataNotifier().notifyPlaylistChanged();
  }

  // Delete a playlist (Cascading delete handles PlaylistSongs)
  Future<void> deletePlaylist(int playlistId) async {
    await (_db.delete(_db.playlists)..where((t) => t.id.equals(playlistId))).go();
    DataNotifier().notifyPlaylistChanged();
  }
}
