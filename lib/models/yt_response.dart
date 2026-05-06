import 'package:music_player/models/yt_song.dart';

class YtListResponse {
  final List<YtSong> results;
  final String? nextPageToken;
  final String? prevPageToken;

  YtListResponse({
    required this.results,
    this.nextPageToken,
    this.prevPageToken,
  });

  factory YtListResponse.fromJson(Map<String, dynamic> json) {
    return YtListResponse(
      results: YtSong.listFromJson(json['results'] ?? []),
      nextPageToken: json['nextPageToken'],
      prevPageToken: json['prevPageToken'],
    );
  }
}
class YtChannel {
  final String id;
  final String title;
  final String thumbnail;
  final String subscriberCount;

  YtChannel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.subscriberCount,
  });

  factory YtChannel.fromJson(Map<String, dynamic> json) {
    return YtChannel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      subscriberCount: json['subscriberCount'] ?? '0',
    );
  }
}
class YtChannelResponse {
  final YtChannel channel;
  final List<YtSong> playlists;

  YtChannelResponse({
    required this.channel,
    required this.playlists,
  });

  factory YtChannelResponse.fromJson(Map<String, dynamic> json) {
    return YtChannelResponse(
      channel: YtChannel.fromJson(json['channel']),
      playlists: YtSong.listFromJson(json['playlists'] ?? []),
    );
  }
}