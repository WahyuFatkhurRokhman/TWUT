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

  Future<List<String>> getFrequentlyPlayedSongPaths() async {
    final query = _db.selectOnly(_db.localSongHistory)
      ..addColumns([_db.localSongHistory.songPath, _db.localSongHistory.songPath.count()])
      ..groupBy([_db.localSongHistory.songPath])
      ..where(_db.localSongHistory.songPath.count().isBiggerThan(const Constant(3)))
      ..limit(5);

    
    final results = await query.get();
    return results.map((row) => row.read(_db.localSongHistory.songPath)!).toList();
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