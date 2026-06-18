import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:music_player/services/youtube_player_manager.dart';

class YoutubeMiniPlayer extends StatelessWidget {
  const YoutubeMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 1,
      child: YoutubePlayer(
        controller: YoutubePlayerManager().controller,
      ),
    );
  }
}