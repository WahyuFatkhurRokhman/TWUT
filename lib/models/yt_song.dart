import 'package:music_player/models/constant/YT_TYPE.dart';

class YtSong {
  final String id;
  final YT_TYPE type;
  final String title;
  final String thumbnail;
  final String? channelTitle;

  YtSong({
    required this.id,
    required this.type,
    required this.title,
    required this.thumbnail,
    this.channelTitle,
  });

  factory YtSong.fromJson(Map<String, dynamic> json) {
    return YtSong(
      id: json['id'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      channelTitle: json['channelTitle'],
    );
  }

  static YT_TYPE _parseType(String? type) {
    switch (type) {
      case 'video':
        return YT_TYPE.VIDEO;
      case 'playlist':
        return YT_TYPE.PLAYLIST;
      case 'channel':
        return YT_TYPE.CHANNEL;
      default:
        return YT_TYPE.VIDEO;
    }
  }

  static String _typeToString(YT_TYPE type) {
    switch (type) {
      case YT_TYPE.VIDEO:
        return "video";
      case YT_TYPE.PLAYLIST:
        return "playlist";
      case YT_TYPE.CHANNEL:
        return "channel";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'title': title,
      'thumbnail': thumbnail,
      'channelTitle': channelTitle,
    };
  }

  static List<YtSong> listFromJson(List<dynamic> data) {
    return data.map((e) => YtSong.fromJson(e)).toList();
  }
}