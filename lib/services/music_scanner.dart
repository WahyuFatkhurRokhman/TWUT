import 'dart:io';
import 'dart:isolate';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../models/song.dart';

class MusicScanner {
  static void scanMusicStream(SendPort sendPort) {
    final dir = Directory('C:\\Users');

    final Set<String> visitedPaths = {};
    final allowedExtensions = ['.mp3', '.wav', '.m4a', '.flac'];

    final skipFolders = [
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

    final allowedFolders = [
      'Music',
      'Downloads',
      'Documents',
      'Desktop',
      'Videos',
      'OneDrive',
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
                        (allowed) =>
                        parentFolder.contains(allowed.toLowerCase()),
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

              /// kirim satu per satu realtime
              sendPort.send(song);
            }

            /// folder lanjut scan
            else if (entity is Directory) {
              scanDirectory(entity);
            }
          } catch (_) {}
        }
      } catch (_) {}
    }

    scanDirectory(dir);

    /// tanda selesai
    sendPort.send(null);
  }
}