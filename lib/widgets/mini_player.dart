import 'package:flutter/material.dart';

import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/now_playing_media.dart';

import 'package:music_player/pages/music_player_page.dart';

import 'package:music_player/services/audio_manager.dart';

import 'package:music_player/utils/navigation_utils.dart';

import 'package:music_player/widgets/audio_progress_bar.dart';
import 'package:music_player/widgets/media_artwork.dart';

class MiniPlayer extends StatelessWidget {
  MiniPlayer({super.key});

  final audio = AudioManager();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 18,
      color: theme.colorScheme.surface,

      child: InkWell(
        onTap: () {
          NavigationUtil.slideUp(context, const MusicPlayerPage());
        },

        child: SafeArea(
          top: false,

          child: ValueListenableBuilder<NowPlayingMedia?>(
            valueListenable: audio.currentMedia,

            builder: (_, media, __) {
              if (media == null) {
                return const SizedBox();
              }

              return SizedBox(
                height: 108,

                child: Column(
                  children: [
                    AudioProgressBar(audio: audio, showTime: false),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),

                        child: Stack(
                          children: [
                            // LEFT
                            Align(
                              alignment: Alignment.centerLeft,

                              child: SizedBox(
                                width: 300,

                                child: _songInfo(media, theme),
                              ),
                            ),

                            // CENTER
                            Align(
                              alignment: Alignment.center,

                              child: _controls(),
                            ),

                            // RIGHT
                            Align(
                              alignment: Alignment.centerRight,

                              child: SizedBox(
                                width: 220,

                                child: _rightSection(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _songInfo(NowPlayingMedia media, ThemeData theme) {
    return Row(
      children: [
        Hero(
          tag: media.id,

          child: MediaArtwork(media: media, size: 58, radius: 12),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                media.title,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                media.artist,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _controls() {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,

      builder: (_, playing, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              splashRadius: 20,

              icon: const Icon(Icons.skip_previous_rounded),

              onPressed: audio.playPrevious,
            ),

            const SizedBox(width: 4),

            Container(
              width: 46,
              height: 46,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),

              child: IconButton(
                splashRadius: 24,
                iconSize: 28,
                color: Colors.white,

                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),

                onPressed: audio.toggle,
              ),
            ),

            const SizedBox(width: 4),

            IconButton(
              splashRadius: 20,

              icon: const Icon(Icons.skip_next_rounded),

              onPressed: audio.playNext,
            ),
          ],
        );
      },
    );
  }

  Widget _rightSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        _repeat(),

        _shuffle(),

        const SizedBox(width: 6),

        SizedBox(width: 130, child: _volume()),
      ],
    );
  }

  Widget _shuffle() {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.queue.shuffleMode,

      builder: (_, enabled, __) {
        return IconButton(
          splashRadius: 20,

          icon: Icon(
            Icons.shuffle_rounded,
            size: 20,
            color: enabled ? Colors.green : Colors.grey,
          ),

          onPressed: audio.queue.toggleShuffle,
        );
      },
    );
  }

  Widget _repeat() {
    return ValueListenableBuilder<REPEAT_MODE>(
      valueListenable: audio.repeatMode,

      builder: (_, mode, __) {
        IconData icon = Icons.repeat_rounded;

        Color color = Colors.grey;

        if (mode == REPEAT_MODE.ALL) {
          color = Colors.green;
        } else if (mode == REPEAT_MODE.ONE) {
          icon = Icons.repeat_one_rounded;
          color = Colors.green;
        }

        return IconButton(
          splashRadius: 20,

          icon: Icon(icon, size: 20, color: color),

          onPressed: audio.toggleRepeatMode,
        );
      },
    );
  }

  Widget _volume() {
    return ValueListenableBuilder<double>(
      valueListenable: audio.volume,

      builder: (_, vol, __) {
        return Row(
          children: [
            Icon(
              vol == 0
                  ? Icons.volume_off_rounded
                  : vol < .5
                  ? Icons.volume_down_rounded
                  : Icons.volume_up_rounded,

              size: 18,
              color: Colors.grey,
            ),

            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,

                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),

                  overlayShape: SliderComponentShape.noOverlay,
                ),

                child: Slider(
                  min: 0,
                  max: 1,

                  value: vol,

                  onChanged: audio.setVolume,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
