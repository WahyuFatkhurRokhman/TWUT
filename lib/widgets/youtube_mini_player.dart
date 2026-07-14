import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:music_player/services/youtube_player_manager.dart';
import 'package:music_player/utils/platform_util.dart';

class YoutubeMiniPlayer extends StatelessWidget {
  const YoutubeMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Di Windows/Linux, YouTube diputar lewat browser bawaan OS (bukan
    // webview di dalam app), jadi tidak perlu widget player sama sekali.
    if (!PlatformUtil.isAndroid) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 1,
      height: 1,
      child: YoutubePlayer(
        controller: YoutubePlayerManager().controller,
      ),
    );
  }
}