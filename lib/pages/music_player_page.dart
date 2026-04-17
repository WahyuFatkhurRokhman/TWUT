import 'package:flutter/material.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/time_utils.dart';
import 'package:music_player/widgets/queue_drawer.dart';
import '../services/audio_manager.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more, size: 32),
          onPressed: () => NavigationUtil.popRoot(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.queue_music),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: QueueDrawer(),
      body: ValueListenableBuilder<Song?>(
        valueListenable: audio.currentSong,
        builder: (_, song, __) {
          if (song == null) {
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
                _cover(song),
                const Spacer(),
                _songInfo(song),
                const Spacer(),
                _progress(audio),
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

  Widget _cover(Song song) {
    if (song.artwork != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          song.artwork!,
          width: 250,
          height: 250,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.music_note, size: 150, color: Colors.blueAccent),
    );
  }

  Widget _songInfo(Song song) {
    return Column(
      children: [
        Text(
          song.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(song.artist, style: const TextStyle(color: Colors.grey)),
        Text(song.album, style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _progress(AudioManager audio) {
    return ValueListenableBuilder<Duration>(
      valueListenable: audio.position,
      builder: (_, pos, __) {
        final max = audio.duration.value.inSeconds.toDouble();
        final current = pos.inSeconds.clamp(0, max.toInt()).toDouble();

        return Column(
          children: [
            Slider(
              min: 0,
              max: max > 0 ? max : 1,
              value: current,
              onChanged: (v) => audio.seek(v.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TimeUtils.formatDuration(pos)),
                Text(TimeUtils.formatDuration(audio.duration.value)),
              ],
            ),
          ],
        );
      },
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
        final tooltip = enabled ? "Shuffle On" : "Shuffle Off";

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          child: IconButton(
            tooltip: tooltip,
            splashRadius: 24,
            onPressed: audio.queue.toggleShuffle,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
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
        late String tooltip;

        switch (mode) {
          case REPEAT_MODE.OFF:
            icon = Icons.repeat;
            color = Colors.grey;
            tooltip = "Repeat Off";
            break;

          case REPEAT_MODE.ALL:
            icon = Icons.repeat;
            color = Colors.green;
            tooltip = "Repeat All";
            break;

          case REPEAT_MODE.ONE:
            icon = Icons.repeat_one;
            color = Colors.green;
            tooltip = "Repeat One";
            break;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          child: IconButton(
            tooltip: tooltip,
            splashRadius: 24,
            onPressed: audio.toggleRepeatMode,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
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
            // PREVIOUS
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.skip_previous),
              onPressed: audio.playPrevious,
            ),

            // PLAY / PAUSE
            IconButton(
              iconSize: 80,
              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
              onPressed: audio.toggle,
            ),

            // NEXT
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
                // Toggle mute/unmute
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
