import 'package:flutter/material.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/utils/navigation_utils.dart';
import '../services/audio_manager.dart';
import '../models/song.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();

    return ValueListenableBuilder<Song?>(
      valueListenable: audio.currentSong,
      builder: (_, song, __) {
        if (song == null) return const SizedBox();

        return GestureDetector(
          onTap: () => NavigationUtil.slideUp(context, MusicPlayerPage(), root: true),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: const Border(
                top: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: Colors.white),
                const SizedBox(width: 10),

                /// INFO LAGU
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                /// PLAY / PAUSE
                ValueListenableBuilder<bool>(
                  valueListenable: audio.isPlaying,
                  builder: (_, playing, __) {
                    return IconButton(
                      iconSize: 32,
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: audio.toggle,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}