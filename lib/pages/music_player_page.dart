import 'package:flutter/material.dart';

import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/now_playing_media.dart';

import 'package:music_player/services/audio_manager.dart';

import 'package:music_player/utils/navigation_utils.dart';

import 'package:music_player/widgets/audio_progress_bar.dart';
import 'package:music_player/widgets/media_artwork.dart';
import 'package:music_player/widgets/queue_drawer.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more, size: 32),

          onPressed: () {
            NavigationUtil.popRoot(context);
          },
        ),

        elevation: 0,

        backgroundColor: Colors.transparent,

        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.queue_music),

                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),

      endDrawer: QueueDrawer(),

      body: ValueListenableBuilder<NowPlayingMedia?>(
        valueListenable: audio.currentMedia,

        builder: (_, media, __) {
          if (media == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              NavigationUtil.popRoot(context);
            });

            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                const Spacer(),

                _cover(media),

                const Spacer(),

                _songInfo(media),

                const Spacer(),

                AudioProgressBar(audio: audio, showTime: true),

                const SizedBox(height: 20),

                _controlsRow(audio),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cover(NowPlayingMedia media) {
    return Hero(
      tag: media.id,

      child: MediaArtwork(media: media, size: 250, radius: 20),
    );
  }

  Widget _songInfo(NowPlayingMedia media) {
    return Column(
      children: [
        Text(
          media.title,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(media.artist, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _controlsRow(AudioManager audio) {
    return Row(
      children: [
        SizedBox(
          width: 150,

          child: Align(
            alignment: Alignment.centerLeft,

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                _toggleRepeatMode(audio),

                const SizedBox(width: 4),

                _toggleShuffleMode(audio),
              ],
            ),
          ),
        ),

        Expanded(child: Center(child: _controls(audio))),

        SizedBox(
          width: 150,

          child: Align(alignment: Alignment.centerRight, child: _volume(audio)),
        ),
      ],
    );
  }

  Widget _toggleShuffleMode(AudioManager audio) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.queue.shuffleMode,

      builder: (_, enabled, __) {
        final color = enabled ? Colors.green : Colors.grey;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          width: 48,
          height: 48,

          child: IconButton(
            splashRadius: 24,

            onPressed: audio.queue.toggleShuffle,

            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),

              transitionBuilder: (child, anim) {
                return ScaleTransition(scale: anim, child: child);
              },

              child: Icon(
                Icons.shuffle,

                key: ValueKey(enabled),

                color: color,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toggleRepeatMode(AudioManager audio) {
    return ValueListenableBuilder<REPEAT_MODE>(
      valueListenable: audio.repeatMode,

      builder: (_, mode, __) {
        late IconData icon;

        late Color color;

        switch (mode) {
          case REPEAT_MODE.OFF:
            icon = Icons.repeat;
            color = Colors.grey;
            break;

          case REPEAT_MODE.ALL:
            icon = Icons.repeat;
            color = Colors.green;
            break;

          case REPEAT_MODE.ONE:
            icon = Icons.repeat_one;
            color = Colors.green;
            break;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          width: 48,
          height: 48,

          child: IconButton(
            splashRadius: 24,

            onPressed: audio.toggleRepeatMode,

            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),

              transitionBuilder: (child, anim) {
                return ScaleTransition(scale: anim, child: child);
              },

              child: Icon(icon, key: ValueKey(mode), color: color, size: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _controls(AudioManager audio) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,

      builder: (_, playing, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              iconSize: 48,

              icon: const Icon(Icons.skip_previous),

              onPressed: audio.playPrevious,
            ),

            IconButton(
              iconSize: 80,

              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),

              onPressed: audio.toggle,
            ),

            IconButton(
              iconSize: 48,

              icon: const Icon(Icons.skip_next),

              onPressed: audio.playNext,
            ),
          ],
        );
      },
    );
  }

  Widget _volume(AudioManager audio) {
    return ValueListenableBuilder<double>(
      valueListenable: audio.volume,

      builder: (_, vol, __) {
        IconData volumeIcon;

        if (vol == 0) {
          volumeIcon = Icons.volume_off;
        } else if (vol < 0.5) {
          volumeIcon = Icons.volume_down;
        } else {
          volumeIcon = Icons.volume_up;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              icon: Icon(volumeIcon, size: 20),

              onPressed: () {
                audio.setVolume(vol > 0 ? 0 : 0.5);
              },
            ),

            Expanded(
              child: Slider(
                min: 0,
                max: 1,

                value: vol,

                onChanged: audio.setVolume,
              ),
            ),
          ],
        );
      },
    );
  }
}
