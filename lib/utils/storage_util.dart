import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageUtil {
  static Future<Directory> getAppDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final twutDir = Directory(p.join(docDir.path, 'Twut'));
    if (!await twutDir.exists()) {
      await twutDir.create(recursive: true);
    }
    return twutDir;
  }

  static Future<String> getDatabasePath(String dbName) async {
    final dir = await getAppDirectory();
    return p.join(dir.path, dbName);
  }

  static Future<Directory> getCacheDirectory() async {
    final baseDir = await getAppDirectory();
    final cacheDir = Directory(p.join(baseDir.path, 'cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }
}
