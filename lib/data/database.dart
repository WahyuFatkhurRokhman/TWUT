import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'table/playlists.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Playlists, PlaylistSongs])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'music_player');
  }
}
