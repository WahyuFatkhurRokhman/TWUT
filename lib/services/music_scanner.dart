import 'dart:io';
import 'dart:isolate';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../models/song.dart';
import '../utils/platform_util.dart';

class MusicScanner {
  static void scanMusicStream(SendPort sendPort) {
    final Directory dir = _getRootDirectory();

    final Set<String> visitedPaths = {};
    final allowedExtensions = ['.mp3', '.wav', '.m4a', '.flac'];

    final skipFolders = _getSkipFolders();

    final allowedFolders = [
      'music',
      'downloads',
      'documents',
      'desktop',
      'videos',
      'onedrive',
    ];

    void scanDirectory(Directory directory) {
      try {
        final entities = directory.listSync(followLinks: true);

        for (final entity in entities) {
          try {
            final entityPathLower = entity.path.toLowerCase();

            /// skip folder tertentu
            if (skipFolders.any(
                  (skip) => entityPathLower.contains(skip.toLowerCase()),
            )) {
              continue;
            }

            /// resolve symlink biar tidak loop
            String actualPath = entity.path;

            try {
              actualPath = entity.resolveSymbolicLinksSync();
            } catch (_) {}

            if (visitedPaths.contains(actualPath)) continue;
            visitedPaths.add(actualPath);

            if (entity is File &&
                allowedExtensions.any(
                      (ext) => entity.path.toLowerCase().endsWith(ext),
                )) {
              if (entity.statSync().size <= 1024) continue;

              final parentFolder = entity.parent.path.toLowerCase();

              final isAllowed =
                  allowedFolders.any(
                        (allowed) => parentFolder.contains(allowed),
                  ) ||
                      ['music', 'song', 'audio', 'playlist']
                          .any((kw) => parentFolder.contains(kw));

              if (!isAllowed) continue;

              final metadata = readMetadata(entity, getImage: false);

              final title =
              metadata.title?.trim().isNotEmpty == true
                  ? metadata.title!
                  : entity.path.split(Platform.pathSeparator).last;

              final song = Song(
                path: entity.path,
                title: title,
                artist: metadata.artist ?? 'Unknown Artist',
                album: metadata.album ?? 'Unknown Album',
                duration: metadata.duration,
              );

              sendPort.send(song);
            } else if (entity is Directory) {
              scanDirectory(entity);
            }
          } catch (_) {}
        }
      } catch (_) {}
    }

    scanDirectory(dir);

    sendPort.send(null);
  }

  static Directory _getRootDirectory() {
    if (PlatformUtil.isWindows) {
      return Directory('C:\\Users');
    }

    if (PlatformUtil.isLinux) {
      return Directory('/home');
    }

    if (PlatformUtil.isAndroid) {
      return Directory('/storage/emulated/0');
    }

    throw UnsupportedError("Platform tidak didukung");
  }

  static List<String> _getSkipFolders() {
    if (PlatformUtil.isWindows) {
      return [
        'C:\\Users\\All Users',
        'C:\\Users\\Default',
        'C:\\Windows',
        'C:\\Program Files',
        'C:\\Program Files (x86)',
        'C:\\ProgramData',
        '\\AppData\\Local\\',
        'Application Data',
        '.cache',
        'node_modules',
        'test',
        'lib',
        'temp',

    ];
    }

    if (PlatformUtil.isLinux) {
      return [
        '/proc',
        '/sys',
        '/dev',
        '/run',
        '.cache',
        'node_modules',
        'test',
        'lib',
        'temp',
      ];
    }

    if (PlatformUtil.isAndroid) {
      return [
        '/android/data',
        '/android/obb',
        '/cache',
        'test',
        'lib',
        'temp',
      ];
    }

    return [];
  }
}