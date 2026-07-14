import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/music_cache_service.dart';

/// Fake implementation of the path_provider platform channel so
/// [StorageUtil.getAppDirectory] resolves to a temp folder during tests.
class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProviderPlatform(this.tempPath);

  final String tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('music_cache_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Song buildSong({String path = '/music/song1.mp3'}) {
    return Song(
      path: path,
      title: 'Song One',
      artist: 'Artist',
      album: 'Album',
      duration: const Duration(seconds: 180),
    );
  }

  group('MusicCacheService', () {
    test('loadSongs returns an empty list when no cache file exists',
        () async {
      final songs = await MusicCacheService.loadSongs();
      expect(songs, isEmpty);
    });

    test('saveSongs persists songs that can be read back with loadSongs',
        () async {
      final original = [
        buildSong(path: '/music/a.mp3'),
        buildSong(path: '/music/b.mp3'),
      ];

      await MusicCacheService.saveSongs(original);
      final loaded = await MusicCacheService.loadSongs();

      expect(loaded.length, 2);
      expect(loaded[0].path, '/music/a.mp3');
      expect(loaded[0].title, 'Song One');
      expect(loaded[0].artist, 'Artist');
      expect(loaded[0].album, 'Album');
      expect(loaded[0].duration, const Duration(seconds: 180));
      expect(loaded[1].path, '/music/b.mp3');
    });

    test('saveSongs overwrites any previously cached data', () async {
      await MusicCacheService.saveSongs([buildSong(path: '/music/old.mp3')]);
      await MusicCacheService.saveSongs([buildSong(path: '/music/new.mp3')]);

      final loaded = await MusicCacheService.loadSongs();

      expect(loaded.length, 1);
      expect(loaded.first.path, '/music/new.mp3');
    });

    test('clear removes the cache file so loadSongs returns empty', () async {
      await MusicCacheService.saveSongs([buildSong()]);
      expect(await MusicCacheService.loadSongs(), isNotEmpty);

      await MusicCacheService.clear();

      expect(await MusicCacheService.loadSongs(), isEmpty);
    });

    test('clear is a no-op (does not throw) when there is nothing to clear',
        () async {
      await expectLater(MusicCacheService.clear(), completes);
    });
  });
}
