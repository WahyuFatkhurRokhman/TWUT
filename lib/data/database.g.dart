// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Playlist copyWith({int? id, String? name, DateTime? createdAt}) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songPathMeta = const VerificationMeta(
    'songPath',
  );
  @override
  late final GeneratedColumn<String> songPath = GeneratedColumn<String>(
    'song_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown Artist'),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown Album'),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songOrderMeta = const VerificationMeta(
    'songOrder',
  );
  @override
  late final GeneratedColumn<int> songOrder = GeneratedColumn<int>(
    'song_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playlistId,
    songPath,
    title,
    artist,
    album,
    durationMs,
    songOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSong> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_path')) {
      context.handle(
        _songPathMeta,
        songPath.isAcceptableOrUnknown(data['song_path']!, _songPathMeta),
      );
    } else if (isInserting) {
      context.missing(_songPathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('song_order')) {
      context.handle(
        _songOrderMeta,
        songOrder.isAcceptableOrUnknown(data['song_order']!, _songOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSong(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      songPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      songOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_order'],
      ),
    );
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class PlaylistSong extends DataClass implements Insertable<PlaylistSong> {
  final int id;
  final int playlistId;
  final String songPath;
  final String title;
  final String artist;
  final String album;
  final int? durationMs;
  final int? songOrder;
  const PlaylistSong({
    required this.id,
    required this.playlistId,
    required this.songPath,
    required this.title,
    required this.artist,
    required this.album,
    this.durationMs,
    this.songOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['song_path'] = Variable<String>(songPath);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || songOrder != null) {
      map['song_order'] = Variable<int>(songOrder);
    }
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      songPath: Value(songPath),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      songOrder: songOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(songOrder),
    );
  }

  factory PlaylistSong.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSong(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      songPath: serializer.fromJson<String>(json['songPath']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      songOrder: serializer.fromJson<int?>(json['songOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'songPath': serializer.toJson<String>(songPath),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'songOrder': serializer.toJson<int?>(songOrder),
    };
  }

  PlaylistSong copyWith({
    int? id,
    int? playlistId,
    String? songPath,
    String? title,
    String? artist,
    String? album,
    Value<int?> durationMs = const Value.absent(),
    Value<int?> songOrder = const Value.absent(),
  }) => PlaylistSong(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    songPath: songPath ?? this.songPath,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    songOrder: songOrder.present ? songOrder.value : this.songOrder,
  );
  PlaylistSong copyWithCompanion(PlaylistSongsCompanion data) {
    return PlaylistSong(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songPath: data.songPath.present ? data.songPath.value : this.songPath,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      songOrder: data.songOrder.present ? data.songOrder.value : this.songOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSong(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songPath: $songPath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('songOrder: $songOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playlistId,
    songPath,
    title,
    artist,
    album,
    durationMs,
    songOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSong &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.songPath == this.songPath &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.songOrder == this.songOrder);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<String> songPath;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int?> durationMs;
  final Value<int?> songOrder;
  const PlaylistSongsCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.songPath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.songOrder = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    required String songPath,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.songOrder = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songPath = Value(songPath),
       title = Value(title);
  static Insertable<PlaylistSong> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<String>? songPath,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<int>? songOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (songPath != null) 'song_path': songPath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (songOrder != null) 'song_order': songOrder,
    });
  }

  PlaylistSongsCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<String>? songPath,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<int?>? durationMs,
    Value<int?>? songOrder,
  }) {
    return PlaylistSongsCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      songPath: songPath ?? this.songPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      songOrder: songOrder ?? this.songOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (songPath.present) {
      map['song_path'] = Variable<String>(songPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (songOrder.present) {
      map['song_order'] = Variable<int>(songOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('songPath: $songPath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('songOrder: $songOrder')
          ..write(')'))
        .toString();
  }
}

class $LocalSongHistoryTable extends LocalSongHistory
    with TableInfo<$LocalSongHistoryTable, LocalSongHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSongHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _songPathMeta = const VerificationMeta(
    'songPath',
  );
  @override
  late final GeneratedColumn<String> songPath = GeneratedColumn<String>(
    'song_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown Artist'),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown Album'),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    songPath,
    title,
    artist,
    album,
    durationMs,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_song_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSongHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_path')) {
      context.handle(
        _songPathMeta,
        songPath.isAcceptableOrUnknown(data['song_path']!, _songPathMeta),
      );
    } else if (isInserting) {
      context.missing(_songPathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSongHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSongHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $LocalSongHistoryTable createAlias(String alias) {
    return $LocalSongHistoryTable(attachedDatabase, alias);
  }
}

class LocalSongHistoryData extends DataClass
    implements Insertable<LocalSongHistoryData> {
  final int id;
  final String songPath;
  final String title;
  final String artist;
  final String album;
  final int? durationMs;
  final DateTime playedAt;
  const LocalSongHistoryData({
    required this.id,
    required this.songPath,
    required this.title,
    required this.artist,
    required this.album,
    this.durationMs,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_path'] = Variable<String>(songPath);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  LocalSongHistoryCompanion toCompanion(bool nullToAbsent) {
    return LocalSongHistoryCompanion(
      id: Value(id),
      songPath: Value(songPath),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      playedAt: Value(playedAt),
    );
  }

  factory LocalSongHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSongHistoryData(
      id: serializer.fromJson<int>(json['id']),
      songPath: serializer.fromJson<String>(json['songPath']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songPath': serializer.toJson<String>(songPath),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  LocalSongHistoryData copyWith({
    int? id,
    String? songPath,
    String? title,
    String? artist,
    String? album,
    Value<int?> durationMs = const Value.absent(),
    DateTime? playedAt,
  }) => LocalSongHistoryData(
    id: id ?? this.id,
    songPath: songPath ?? this.songPath,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    playedAt: playedAt ?? this.playedAt,
  );
  LocalSongHistoryData copyWithCompanion(LocalSongHistoryCompanion data) {
    return LocalSongHistoryData(
      id: data.id.present ? data.id.value : this.id,
      songPath: data.songPath.present ? data.songPath.value : this.songPath,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSongHistoryData(')
          ..write('id: $id, ')
          ..write('songPath: $songPath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, songPath, title, artist, album, durationMs, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSongHistoryData &&
          other.id == this.id &&
          other.songPath == this.songPath &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.playedAt == this.playedAt);
}

class LocalSongHistoryCompanion extends UpdateCompanion<LocalSongHistoryData> {
  final Value<int> id;
  final Value<String> songPath;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int?> durationMs;
  final Value<DateTime> playedAt;
  const LocalSongHistoryCompanion({
    this.id = const Value.absent(),
    this.songPath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  LocalSongHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String songPath,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playedAt = const Value.absent(),
  }) : songPath = Value(songPath),
       title = Value(title);
  static Insertable<LocalSongHistoryData> custom({
    Expression<int>? id,
    Expression<String>? songPath,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songPath != null) 'song_path': songPath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  LocalSongHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? songPath,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<int?>? durationMs,
    Value<DateTime>? playedAt,
  }) {
    return LocalSongHistoryCompanion(
      id: id ?? this.id,
      songPath: songPath ?? this.songPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songPath.present) {
      map['song_path'] = Variable<String>(songPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSongHistoryCompanion(')
          ..write('id: $id, ')
          ..write('songPath: $songPath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistHistoryTable extends PlaylistHistory
    with TableInfo<$PlaylistHistoryTable, PlaylistHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistId, playedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $PlaylistHistoryTable createAlias(String alias) {
    return $PlaylistHistoryTable(attachedDatabase, alias);
  }
}

class PlaylistHistoryData extends DataClass
    implements Insertable<PlaylistHistoryData> {
  final int id;
  final int playlistId;
  final DateTime playedAt;
  const PlaylistHistoryData({
    required this.id,
    required this.playlistId,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  PlaylistHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlaylistHistoryCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      playedAt: Value(playedAt),
    );
  }

  factory PlaylistHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistHistoryData(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  PlaylistHistoryData copyWith({
    int? id,
    int? playlistId,
    DateTime? playedAt,
  }) => PlaylistHistoryData(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    playedAt: playedAt ?? this.playedAt,
  );
  PlaylistHistoryData copyWithCompanion(PlaylistHistoryCompanion data) {
    return PlaylistHistoryData(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistHistoryData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistHistoryData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.playedAt == this.playedAt);
}

class PlaylistHistoryCompanion extends UpdateCompanion<PlaylistHistoryData> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<DateTime> playedAt;
  const PlaylistHistoryCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  PlaylistHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    this.playedAt = const Value.absent(),
  }) : playlistId = Value(playlistId);
  static Insertable<PlaylistHistoryData> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  PlaylistHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<DateTime>? playedAt,
  }) {
    return PlaylistHistoryCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistHistoryCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $LocalSongHistoryTable localSongHistory = $LocalSongHistoryTable(
    this,
  );
  late final $PlaylistHistoryTable playlistHistory = $PlaylistHistoryTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playlists,
    playlistSongs,
    localSongHistory,
    playlistHistory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_songs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_history', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSong>>
  _playlistSongsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongs,
    aliasName: 'playlists__id__playlist_songs__playlist_id',
  );

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager(
      $_db,
      $_db.playlistSongs,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaylistHistoryTable, List<PlaylistHistoryData>>
  _playlistHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistHistory,
    aliasName: 'playlists__id__playlist_history__playlist_id',
  );

  $$PlaylistHistoryTableProcessedTableManager get playlistHistoryRefs {
    final manager = $$PlaylistHistoryTableTableManager(
      $_db,
      $_db.playlistHistory,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongsRefs(
    Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistHistoryRefs(
    Expression<bool> Function($$PlaylistHistoryTableFilterComposer f) f,
  ) {
    final $$PlaylistHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistHistory,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistHistoryTableFilterComposer(
            $db: $db,
            $table: $db.playlistHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playlistSongsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongs,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistHistoryRefs<T extends Object>(
    Expression<T> Function($$PlaylistHistoryTableAnnotationComposer a) f,
  ) {
    final $$PlaylistHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistHistory,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({
            bool playlistSongsRefs,
            bool playlistHistoryRefs,
          })
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  PlaylistsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playlistSongsRefs = false, playlistHistoryRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongsRefs) db.playlistSongs,
                    if (playlistHistoryRefs) db.playlistHistory,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongsRefs)
                        await $_getPrefetchedData<
                          Playlist,
                          $PlaylistsTable,
                          PlaylistSong
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._playlistSongsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistHistoryRefs)
                        await $_getPrefetchedData<
                          Playlist,
                          $PlaylistsTable,
                          PlaylistHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$PlaylistsTableReferences
                              ._playlistHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlaylistsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playlistId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistSongsRefs, bool playlistHistoryRefs})
    >;
typedef $$PlaylistSongsTableCreateCompanionBuilder =
    PlaylistSongsCompanion Function({
      Value<int> id,
      required int playlistId,
      required String songPath,
      required String title,
      Value<String> artist,
      Value<String> album,
      Value<int?> durationMs,
      Value<int?> songOrder,
    });
typedef $$PlaylistSongsTableUpdateCompanionBuilder =
    PlaylistSongsCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<String> songPath,
      Value<String> title,
      Value<String> artist,
      Value<String> album,
      Value<int?> durationMs,
      Value<int?> songOrder,
    });

final class $$PlaylistSongsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSong> {
  $$PlaylistSongsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_songs__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songOrder => $composableBuilder(
    column: $table.songOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songOrder => $composableBuilder(
    column: $table.songOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songPath =>
      $composableBuilder(column: $table.songPath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get songOrder =>
      $composableBuilder(column: $table.songOrder, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongsTable,
          PlaylistSong,
          $$PlaylistSongsTableFilterComposer,
          $$PlaylistSongsTableOrderingComposer,
          $$PlaylistSongsTableAnnotationComposer,
          $$PlaylistSongsTableCreateCompanionBuilder,
          $$PlaylistSongsTableUpdateCompanionBuilder,
          (PlaylistSong, $$PlaylistSongsTableReferences),
          PlaylistSong,
          PrefetchHooks Function({bool playlistId})
        > {
  $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<String> songPath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> songOrder = const Value.absent(),
              }) => PlaylistSongsCompanion(
                id: id,
                playlistId: playlistId,
                songPath: songPath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                songOrder: songOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                required String songPath,
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> songOrder = const Value.absent(),
              }) => PlaylistSongsCompanion.insert(
                id: id,
                playlistId: playlistId,
                songPath: songPath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                songOrder: songOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistSongsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn: $$PlaylistSongsTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongsTable,
      PlaylistSong,
      $$PlaylistSongsTableFilterComposer,
      $$PlaylistSongsTableOrderingComposer,
      $$PlaylistSongsTableAnnotationComposer,
      $$PlaylistSongsTableCreateCompanionBuilder,
      $$PlaylistSongsTableUpdateCompanionBuilder,
      (PlaylistSong, $$PlaylistSongsTableReferences),
      PlaylistSong,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$LocalSongHistoryTableCreateCompanionBuilder =
    LocalSongHistoryCompanion Function({
      Value<int> id,
      required String songPath,
      required String title,
      Value<String> artist,
      Value<String> album,
      Value<int?> durationMs,
      Value<DateTime> playedAt,
    });
typedef $$LocalSongHistoryTableUpdateCompanionBuilder =
    LocalSongHistoryCompanion Function({
      Value<int> id,
      Value<String> songPath,
      Value<String> title,
      Value<String> artist,
      Value<String> album,
      Value<int?> durationMs,
      Value<DateTime> playedAt,
    });

class $$LocalSongHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSongHistoryTable> {
  $$LocalSongHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSongHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSongHistoryTable> {
  $$LocalSongHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songPath => $composableBuilder(
    column: $table.songPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSongHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSongHistoryTable> {
  $$LocalSongHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get songPath =>
      $composableBuilder(column: $table.songPath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$LocalSongHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSongHistoryTable,
          LocalSongHistoryData,
          $$LocalSongHistoryTableFilterComposer,
          $$LocalSongHistoryTableOrderingComposer,
          $$LocalSongHistoryTableAnnotationComposer,
          $$LocalSongHistoryTableCreateCompanionBuilder,
          $$LocalSongHistoryTableUpdateCompanionBuilder,
          (
            LocalSongHistoryData,
            BaseReferences<
              _$AppDatabase,
              $LocalSongHistoryTable,
              LocalSongHistoryData
            >,
          ),
          LocalSongHistoryData,
          PrefetchHooks Function()
        > {
  $$LocalSongHistoryTableTableManager(
    _$AppDatabase db,
    $LocalSongHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSongHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSongHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSongHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songPath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => LocalSongHistoryCompanion(
                id: id,
                songPath: songPath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songPath,
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => LocalSongHistoryCompanion.insert(
                id: id,
                songPath: songPath,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSongHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSongHistoryTable,
      LocalSongHistoryData,
      $$LocalSongHistoryTableFilterComposer,
      $$LocalSongHistoryTableOrderingComposer,
      $$LocalSongHistoryTableAnnotationComposer,
      $$LocalSongHistoryTableCreateCompanionBuilder,
      $$LocalSongHistoryTableUpdateCompanionBuilder,
      (
        LocalSongHistoryData,
        BaseReferences<
          _$AppDatabase,
          $LocalSongHistoryTable,
          LocalSongHistoryData
        >,
      ),
      LocalSongHistoryData,
      PrefetchHooks Function()
    >;
typedef $$PlaylistHistoryTableCreateCompanionBuilder =
    PlaylistHistoryCompanion Function({
      Value<int> id,
      required int playlistId,
      Value<DateTime> playedAt,
    });
typedef $$PlaylistHistoryTableUpdateCompanionBuilder =
    PlaylistHistoryCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<DateTime> playedAt,
    });

final class $$PlaylistHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlaylistHistoryTable,
          PlaylistHistoryData
        > {
  $$PlaylistHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_history__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistHistoryTable> {
  $$PlaylistHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistHistoryTable> {
  $$PlaylistHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistHistoryTable> {
  $$PlaylistHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistHistoryTable,
          PlaylistHistoryData,
          $$PlaylistHistoryTableFilterComposer,
          $$PlaylistHistoryTableOrderingComposer,
          $$PlaylistHistoryTableAnnotationComposer,
          $$PlaylistHistoryTableCreateCompanionBuilder,
          $$PlaylistHistoryTableUpdateCompanionBuilder,
          (PlaylistHistoryData, $$PlaylistHistoryTableReferences),
          PlaylistHistoryData,
          PrefetchHooks Function({bool playlistId})
        > {
  $$PlaylistHistoryTableTableManager(
    _$AppDatabase db,
    $PlaylistHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => PlaylistHistoryCompanion(
                id: id,
                playlistId: playlistId,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                Value<DateTime> playedAt = const Value.absent(),
              }) => PlaylistHistoryCompanion.insert(
                id: id,
                playlistId: playlistId,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistHistoryTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistHistoryTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistHistoryTable,
      PlaylistHistoryData,
      $$PlaylistHistoryTableFilterComposer,
      $$PlaylistHistoryTableOrderingComposer,
      $$PlaylistHistoryTableAnnotationComposer,
      $$PlaylistHistoryTableCreateCompanionBuilder,
      $$PlaylistHistoryTableUpdateCompanionBuilder,
      (PlaylistHistoryData, $$PlaylistHistoryTableReferences),
      PlaylistHistoryData,
      PrefetchHooks Function({bool playlistId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistSongsTableTableManager get playlistSongs =>
      $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
  $$LocalSongHistoryTableTableManager get localSongHistory =>
      $$LocalSongHistoryTableTableManager(_db, _db.localSongHistory);
  $$PlaylistHistoryTableTableManager get playlistHistory =>
      $$PlaylistHistoryTableTableManager(_db, _db.playlistHistory);
}
