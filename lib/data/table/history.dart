import 'package:drift/drift.dart';
import 'package:music_player/data/table/playlists.dart';

class LocalSongHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songPath => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant('Unknown Artist'))();
  TextColumn get album => text().withDefault(const Constant('Unknown Album'))();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}
