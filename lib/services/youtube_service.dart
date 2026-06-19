import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_response.dart';
import 'package:music_player/services/api_service.dart';

class YoutubeService {
  static Future<YtListResponse> search({
    required String query,
    YT_TYPE type = YT_TYPE.VIDEO,
    String? pageToken,
  }) async {
    final response = await ApiService.get(
      "/search",
      queryParams: {
        "q": query,
        "type": _typeToString(type),
        "pageToken": ?pageToken,
      },
    );

    return YtListResponse.fromJson(response);
  }

  static Future<YtListResponse> getPlaylistItems({
    required String playlistId,
    String? pageToken,
  }) async {
    final response = await ApiService.get(
      "/playlist/$playlistId",
      queryParams: {
        "pageToken": ?pageToken,
      },
    );

    return YtListResponse.fromJson(response);
  }

  static Future<YtChannelResponse> getChannelDetail({
    required String channelId,
  }) async {
    final response = await ApiService.get(
      "/channel/$channelId",
    );

    return YtChannelResponse.fromJson(response);
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
}