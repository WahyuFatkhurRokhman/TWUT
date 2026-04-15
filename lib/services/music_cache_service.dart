import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';

class MusicCacheService {

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final twutDir = Directory('${dir.path}/Twut');

    if (!await twutDir.exists()) {
      await twutDir.create(recursive: true);
    }

    return File('${twutDir.path}/music_cache.json');
  }

  static Future<void> saveSongs(List<Song> songs) async {
    final file = await _getFile();

    final jsonList = songs.map((s) => s.toJson()).toList();

    await file.writeAsString(jsonEncode(jsonList));
  }

  static Future<List<Song>> loadSongs() async {
    final file = await _getFile();

    if (!await file.exists()) return [];

    final content = await file.readAsString();

    final jsonList = jsonDecode(content) as List<dynamic>;

    return jsonList
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}