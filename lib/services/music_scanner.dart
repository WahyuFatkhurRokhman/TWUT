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

    if (PlatformUtil.isWindows) {
      print('[Scanner] Windows mode');
      _runAsync(() => _scanWindows(sendPort));
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

  // ---------------------------------------------------------------------
  // ANDROID
  // ---------------------------------------------------------------------

  /// Cari semua root penyimpanan Android: internal + kartu SD/OTG eksternal.
  /// Di Android, setiap volume biasanya muncul sebagai folder di /storage,
  /// contoh: /storage/emulated/0 (internal) dan /storage/1AEF-2C11 (SD card).
  static Future<List<Directory>> _getAndroidRoots() async {
    final roots = <Directory>[];
    final seenRealPaths = <String>{};

    Future<void> tryAdd(Directory dir) async {
      try {
        if (!await dir.exists()) return;
        String real = dir.path;
        try {
          real = await dir.resolveSymbolicLinks();
        } catch (_) {}
        if (seenRealPaths.add(real)) {
          roots.add(dir);
        }
      } catch (_) {}
    }

    // Internal storage utama
    await tryAdd(Directory('/storage/emulated/0'));

    // Fallback lama, biasanya symlink ke internal (akan otomatis di-dedup)
    await tryAdd(Directory('/sdcard'));

    // Deteksi semua volume lain: kartu SD eksternal, OTG USB, dll.
    try {
      final storageDir = Directory('/storage');
      if (await storageDir.exists()) {
        await for (final entity
        in storageDir.list(followLinks: false)) {
          if (entity is! Directory) continue;

          final name = entity.uri.pathSegments
              .where((s) => s.isNotEmpty)
              .lastOrNull ??
              '';

          // 'emulated' sudah ditangani di atas, 'self' bukan volume nyata
          if (name == 'emulated' || name == 'self') continue;

          await tryAdd(entity);
        }
      }
    } catch (e) {
      print('[Scanner] Tidak bisa membaca /storage: $e');
    }

    return roots;
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

    final visitedPaths = <String>{};
    int scannedFiles = 0;
    int foundSongs = 0;

    Future<void> scanDirectory(Directory dir) async {
      try {
        await for (final entity in dir.list(followLinks: false)) {
          try {
            final path = entity.path.toLowerCase();

            if (entity is Directory) {
              if (_shouldSkipAndroidDirectory(path)) continue;
              if (_isHiddenFolder(entity)) continue;

              String actualPath = entity.path;
              try {
                actualPath = await entity.resolveSymbolicLinks();
              } catch (_) {}
              if (!visitedPaths.add(actualPath)) continue;

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
      final roots = await _getAndroidRoots();

      print('[Scanner] Root ditemukan: ${roots.map((r) => r.path).toList()}');

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

  static bool _shouldSkipAndroidDirectory(String path) {
    return path.contains('/android/data') ||
        path.contains('/android/obb') ||
        path.contains('/android/media') ||
        path.contains('/.thumbnails') ||
        path.contains('/cache') ||
        path.contains('/tmp') ||
        path.contains('/temp');
  }

  // ---------------------------------------------------------------------
  // WINDOWS (multi-partisi / multi-drive)
  // ---------------------------------------------------------------------

  /// Cari semua drive letter yang tersedia (C:, D:, E:, ...).
  /// Termasuk partisi tambahan dan removable drive (flashdisk, HDD eksternal).
  static List<Directory> _getWindowsDriveRoots() {
    final roots = <Directory>[];

    for (int code = 'A'.codeUnitAt(0); code <= 'Z'.codeUnitAt(0); code++) {
      final letter = String.fromCharCode(code);
      final dir = Directory('$letter:\\');
      try {
        if (dir.existsSync()) {
          roots.add(dir);
        }
      } catch (_) {
        // Drive tidak siap (mis. CD-ROM kosong), lewati saja
      }
    }

    return roots;
  }

  static Future<void> _scanWindows(SendPort sendPort) async {
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

    int scannedFiles = 0;
    int foundSongs = 0;

    void scanDirectory(Directory dir, {required bool isSystemDrive}) {
      try {
        final entities = dir.listSync(followLinks: true);

        for (final entity in entities) {
          try {
            final path = entity.path.toLowerCase();

            if (_shouldSkipWindowsPath(path, isSystemDrive: isSystemDrive)) {
              continue;
            }

            if (entity is Directory && _isHiddenFolder(entity)) continue;

            String actualPath = entity.path;
            try {
              actualPath = entity.resolveSymbolicLinksSync();
            } catch (_) {}

            if (!visitedPaths.add(actualPath)) continue;

            if (entity is Directory) {
              scanDirectory(entity, isSystemDrive: isSystemDrive);
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

    try {
      final systemDrive =
      (Platform.environment['SystemDrive'] ?? 'C:').toUpperCase();
      final roots = _getWindowsDriveRoots();

      print('[Scanner] Drive ditemukan: ${roots.map((r) => r.path).toList()}');

      for (final root in roots) {
        final driveLetter = root.path.toUpperCase().replaceAll('\\', '');
        final isSystemDrive = driveLetter == systemDrive;

        // Drive sistem: hanya scan folder Users agar tidak menyentuh
        // file sistem Windows. Drive/partisi lain: scan seluruh root,
        // karena biasanya berisi data pengguna (musik, dokumen, dll).
        if (isSystemDrive) {
          final usersDir = Directory('${root.path}Users');
          if (usersDir.existsSync()) {
            scanDirectory(usersDir, isSystemDrive: true);
          }
        } else {
          scanDirectory(root, isSystemDrive: false);
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

  static bool _shouldSkipWindowsPath(String path, {required bool isSystemDrive}) {
    const commonSkip = [
      '\\appdata',
      'application data',
      '.cache',
      'node_modules',
      '\\test',
      '\\lib',
      '\\temp',
      '\$recycle.bin',
      'system volume information',
    ];

    if (commonSkip.any((skip) => path.contains(skip))) return true;

    if (isSystemDrive) {
      const systemOnlySkip = [
        '\\users\\all users',
        '\\users\\default',
        '\\windows',
        '\\program files',
        '\\programdata',
      ];
      if (systemOnlySkip.any((skip) => path.contains(skip))) return true;
    }

    return false;
  }

  // ---------------------------------------------------------------------
  // LINUX / lainnya (fallback lama)
  // ---------------------------------------------------------------------

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

            if (entity is Directory && _isHiddenFolder(entity)) continue;

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

  /// Cek apakah nama folder diawali titik, mis. `.thumbnails`, `.trash`,
  /// `.config`, `.git`, dll. Folder seperti ini biasanya hidden/system
  /// dan tidak relevan untuk hasil scan musik.
  static bool _isHiddenFolder(Directory dir) {
    final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull;
    return name != null && name.startsWith('.');
  }

  static AudioMetadata? _safeReadMetadata(File file) {
    try {
      return readMetadata(file, getImage: false);
    } catch (e) {
      print('[Scanner] Metadata error: ${file.path}');
      return null;
    }
  }

  static Directory _getRootDirectory() {
    if (PlatformUtil.isLinux) return Directory('/home');
    throw UnsupportedError('Platform tidak didukung');
  }

  static List<String> _getSkipFolders() {
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

extension _LastOrNullExt<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}