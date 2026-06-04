import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicScanner {
  static Future<bool> hasPermissions() async {
    if (!PlatformUtil.isAndroid) return true;

    if (await Permission.audio.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    return false;
  }

  /// Tampilkan pop-up izin storage bawaan Android.
  /// Kembalikan true jika izin diberikan.
  static Future<bool> requestPermissions() async {
    if (!PlatformUtil.isAndroid) return true;

    // Android 13+ (API 33) menggunakan READ_MEDIA_AUDIO
    // Di bawahnya menggunakan READ_EXTERNAL_STORAGE
    
    // Kita request keduanya, permission_handler akan menangani sesuai versi OS
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.audio,
    ].request();

    return statuses[Permission.storage]?.isGranted == true || 
           statuses[Permission.audio]?.isGranted == true;
  }

  static void scanMusicStream(SendPort sendPort) {
    print('[Scanner] Start');

    if (PlatformUtil.isAndroid) {
      print('[Scanner] Android mode');
      _runAsync(() => _scanAndroid(sendPort));
      return;
    }

    print('[Scanner] Desktop mode');
    _scanDesktop(sendPort);
  }

  static void _runAsync(Future<void> Function() fn) {
    fn().catchError((e) {
      print('[Scanner] Unhandled error: $e');
    });
  }

  static Future<void> _scanAndroid(SendPort sendPort) async {
    final stopwatch = Stopwatch()..start();

    const allowedExtensions = [
      '.mp3',
      '.wav',
      '.m4a',
      '.flac',
      '.aac',
      '.ogg',
      '.opus',
    ];

    int scannedFiles = 0;
    int foundSongs = 0;

    Future<void> scanDirectory(Directory dir) async {
      try {
        await for (final entity in dir.list(followLinks: false)) {
          try {
            final path = entity.path.toLowerCase();

            if (entity is Directory) {
              if (_shouldSkipAndroidDirectory(path)) continue;
              await scanDirectory(entity);
              continue;
            }

            if (entity is! File) continue;

            scannedFiles++;

            if (scannedFiles % 100 == 0) {
              print('[Scanner] scanned=$scannedFiles found=$foundSongs');
            }

            if (!allowedExtensions.any(path.endsWith)) continue;

            final stat = entity.statSync();
            if (stat.size <= 1024) continue;

            final metadata = _safeReadMetadata(entity);

            final title = metadata?.title?.trim().isNotEmpty == true
                ? metadata!.title!
                : entity.uri.pathSegments.last;

            foundSongs++;

            sendPort.send(
              Song(
                path: entity.path,
                title: title,
                artist: metadata?.artist ?? 'Unknown Artist',
                album: metadata?.album ?? 'Unknown Album',
                duration: metadata?.duration,
              ),
            );
          } catch (e) {
            print('[Scanner] File error: $e');
          }
        }
      } catch (e) {
        print('[Scanner] Directory skipped: ${dir.path}');
      }
    }

    try {
      final roots = [
        Directory('/storage/emulated/0'),
        Directory('/sdcard'),
      ];

      for (final root in roots) {
        if (await root.exists()) {
          await scanDirectory(root);
        }
      }

      stopwatch.stop();
      print('[Scanner] Finished in ${stopwatch.elapsedMilliseconds} ms');
      print('[Scanner] scanned=$scannedFiles found=$foundSongs');
    } catch (e) {
      print('[Scanner] Fatal error: $e');
    } finally {
      sendPort.send(null);
    }
  }

  static void _scanDesktop(SendPort sendPort) {
    final root = _getRootDirectory();
    final stopwatch = Stopwatch()..start();
    final visitedPaths = <String>{};

    const allowedExtensions = [
      '.mp3',
      '.wav',
      '.m4a',
      '.flac',
      '.aac',
      '.ogg',
      '.opus',
    ];

    final skipFolders = _getSkipFolders();

    int scannedFiles = 0;
    int foundSongs = 0;

    void scanDirectory(Directory dir) {
      try {
        final entities = dir.listSync(followLinks: true);

        for (final entity in entities) {
          try {
            final path = entity.path.toLowerCase();

            if (skipFolders.any(
                  (skip) => path.contains(skip.toLowerCase()),
            )) {
              continue;
            }

            String actualPath = entity.path;
            try {
              actualPath = entity.resolveSymbolicLinksSync();
            } catch (_) {}

            if (!visitedPaths.add(actualPath)) continue;

            if (entity is Directory) {
              scanDirectory(entity);
              continue;
            }

            if (entity is! File) continue;

            scannedFiles++;

            if (scannedFiles % 100 == 0) {
              print('[Scanner] scanned=$scannedFiles found=$foundSongs');
            }

            if (!allowedExtensions.any(path.endsWith)) continue;

            if (entity.statSync().size <= 1024) continue;

            final metadata = _safeReadMetadata(entity);

            final title = metadata?.title?.trim().isNotEmpty == true
                ? metadata!.title!
                : entity.uri.pathSegments.last;

            foundSongs++;

            sendPort.send(
              Song(
                path: entity.path,
                title: title,
                artist: metadata?.artist ?? 'Unknown Artist',
                album: metadata?.album ?? 'Unknown Album',
                duration: metadata?.duration,
              ),
            );
          } catch (e) {
            print('[Scanner] Item error: $e');
          }
        }
      } catch (e) {
        print('[Scanner] Directory error: ${dir.path}');
      }
    }

    scanDirectory(root);

    stopwatch.stop();
    print('[Scanner] Finished in ${stopwatch.elapsedMilliseconds} ms');
    print('[Scanner] scanned=$scannedFiles found=$foundSongs');

    sendPort.send(null);
  }

  static AudioMetadata? _safeReadMetadata(File file) {
    try {
      return readMetadata(file, getImage: false);
    } catch (e) {
      print('[Scanner] Metadata error: ${file.path}');
      return null;
    }
  }

  static bool _shouldSkipAndroidDirectory(String path) {
    return path.contains('/android/data') ||
        path.contains('/android/obb') ||
        path.contains('/android/media') ||
        path.contains('/.thumbnails') ||
        path.contains('/cache') ||
        path.contains('/tmp') ||
        path.contains('/temp');
  }

  static Directory _getRootDirectory() {
    if (PlatformUtil.isWindows) return Directory(r'C:\Users');
    if (PlatformUtil.isLinux) return Directory('/home');
    throw UnsupportedError('Platform tidak didukung');
  }

  static List<String> _getSkipFolders() {
    if (PlatformUtil.isWindows) {
      return [
        r'C:\Users\All Users',
        r'C:\Users\Default',
        r'C:\Windows',
        r'C:\Program Files',
        r'C:\Program Files (x86)',
        r'C:\ProgramData',
        r'\AppData\Local\',
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

    return [];
  }
}
