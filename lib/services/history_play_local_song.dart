import 'package:drift/drift.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';

class HistoryPlayLocalSong {
  final AppDatabase _db;

  HistoryPlayLocalSong(this._db);

  Future<void> addPlaylist(Playlist playlist) async {
    await _db.into(_db.playlistHistory).insert(PlaylistHistoryCompanion(
      playlistId: Value(playlist.id),
      playedAt: Value(DateTime.now()),
    ));
  }

  Future<void> addSong(Song song) async {
    await _db.into(_db.localSongHistory).insert(LocalSongHistoryCompanion(
      songPath: Value(song.path),
      playedAt: Value(DateTime.now()),
    ));
  }

  Future<List<Playlist>> getHistoryPlaylist() async {
    final query = _db.select(_db.playlistHistory).join([
      innerJoin(
        _db.playlists,
        _db.playlists.id.equalsExp(_db.playlistHistory.playlistId),
      ),
    ]);
    query.orderBy([OrderingTerm.desc(_db.playlistHistory.playedAt)]);
    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.playlists)).toList();
  }

  Future<List<String>> getHistorySongPaths() async {
    final query = _db.select(_db.localSongHistory)
      ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]);
    final list = await query.get();
    return list.map((row) => row.songPath).toList();
  }

  // menampilkan 5 terakhir
  Future<List<Playlist>> getRecentPlaylist() async {
    final query = _db.select(_db.playlistHistory).join([
      innerJoin(
        _db.playlists,
        _db.playlists.id.equalsExp(_db.playlistHistory.playlistId),
      ),
    ]);
    query.orderBy([OrderingTerm.desc(_db.playlistHistory.playedAt)]);
    query.limit(5);
    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.playlists)).toList();
  }

  // menampilkan 5 terakhir
  Future<List<String>> getRecentSongPaths() async {
    final query = _db.select(_db.localSongHistory)
      ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
      ..limit(5);
    final list = await query.get();
    return list.map((row) => row.songPath).toList();
  }
}