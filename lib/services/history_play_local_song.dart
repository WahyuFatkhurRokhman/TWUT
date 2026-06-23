import 'package:drift/drift.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/utils/data_notifier.dart';

class HistoryPlayLocalSong {
  final AppDatabase _db;

  HistoryPlayLocalSong(this._db);

  Future<void> clearSongHistory() async {
    await _db.delete(_db.localSongHistory).go();
    DataNotifier().notifyHistoryChanged();
  }

  Future<void> clearPlaylistHistory() async {
    await _db.delete(_db.playlistHistory).go();
    DataNotifier().notifyHistoryChanged();
  }

  Future<void> addPlaylist(int playlistId) async {
    await _db
        .into(_db.playlistHistory)
        .insert(
          PlaylistHistoryCompanion(
            playlistId: Value(playlistId),
            playedAt: Value(DateTime.now()),
          ),
        );
    DataNotifier().notifyHistoryChanged();
  }

  Future<void> addSong(Song song) async {
    await _db
        .into(_db.localSongHistory)
        .insert(
          LocalSongHistoryCompanion(
            songPath: Value(song.path),
            title: Value(song.title),
            artist: Value(song.artist),
            album: Value(song.album),
            durationMs: Value(song.duration?.inMilliseconds),
            playedAt: Value(DateTime.now()),
          ),
        );
    DataNotifier().notifyHistoryChanged();
  }

  Future<List<Song>> getHistorySong() async {
    final query = _db.select(_db.localSongHistory)
      ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]);
    final list = await query.get();
    return list
        .map(
          (row) => Song(
            path: row.songPath,
            title: row.title,
            artist: row.artist,
            album: row.album,
            duration: row.durationMs != null
                ? Duration(milliseconds: row.durationMs!)
                : null,
          ),
        )
        .toList();
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

  Future<List<Song>> getRecentSongs() async {
    final lastPlayed = _db.localSongHistory.playedAt.max();

    final query = _db.selectOnly(_db.localSongHistory)
      ..addColumns([
        _db.localSongHistory.songPath,
        _db.localSongHistory.title,
        _db.localSongHistory.artist,
        _db.localSongHistory.album,
        _db.localSongHistory.durationMs,
        _db.localSongHistory.songPath.count(),
        lastPlayed,
      ])
      ..groupBy([
        _db.localSongHistory.songPath,
        _db.localSongHistory.title,
        _db.localSongHistory.artist,
        _db.localSongHistory.album,
        _db.localSongHistory.durationMs,
      ])
      ..orderBy([
        OrderingTerm.desc(lastPlayed),
        OrderingTerm.desc(_db.localSongHistory.songPath.count()),
      ])
      ..limit(5);

    final list = await query.get();
    return list
        .map(
          (row) => Song(
            path: row.read(_db.localSongHistory.songPath)!,
            title: row.read(_db.localSongHistory.title)!,
            artist: row.read(_db.localSongHistory.artist)!,
            album: row.read(_db.localSongHistory.album)!,
            duration: row.read(_db.localSongHistory.durationMs) != null
                ? Duration(
                    milliseconds: row.read(_db.localSongHistory.durationMs)!,
                  )
                : null,
          ),
        )
        .toList();
  }

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

  Future<List<Song>> getFrequentlyPlayedSongs() async {
    final lastPlayed = _db.localSongHistory.playedAt.max();

    final query = _db.selectOnly(_db.localSongHistory)
      ..addColumns([
        _db.localSongHistory.songPath,
        _db.localSongHistory.title,
        _db.localSongHistory.artist,
        _db.localSongHistory.album,
        _db.localSongHistory.durationMs,
        _db.localSongHistory.songPath.count(),
        lastPlayed,
      ])
      ..groupBy([
        _db.localSongHistory.songPath,
        _db.localSongHistory.title,
        _db.localSongHistory.artist,
        _db.localSongHistory.album,
        _db.localSongHistory.durationMs,
      ])
      ..orderBy([
        OrderingTerm.desc(lastPlayed),
        OrderingTerm.desc(_db.localSongHistory.songPath.count()),
      ]);

    final results = await query.get();
    return results
        .where(
          (row) => (row.read(_db.localSongHistory.songPath.count()) as int) > 3,
        )
        .take(5)
        .map(
          (row) => Song(
            path: row.read(_db.localSongHistory.songPath)!,
            title: row.read(_db.localSongHistory.title)!,
            artist: row.read(_db.localSongHistory.artist)!,
            album: row.read(_db.localSongHistory.album)!,
            duration: row.read(_db.localSongHistory.durationMs) != null
                ? Duration(
                    milliseconds: row.read(_db.localSongHistory.durationMs)!,
                  )
                : null,
          ),
        )
        .toList();
  }
}
