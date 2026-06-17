import 'package:drift/drift.dart';

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get songPath => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown Artist'))();
  TextColumn get album => text().withDefault(const Constant('Unknown Album'))();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get songOrder => integer().nullable()();
}
