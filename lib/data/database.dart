
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:music_player/utils/storage_util.dart';
import 'table/playlists.dart';
import 'table/history.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Playlists, PlaylistSongs, LocalSongHistory, PlaylistHistory])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'music_player', native: DriftNativeOptions(
      databaseDirectory: () => StorageUtil.getAppDirectory(),
    ));
  }
}
