import 'package:flutter/material.dart';
import 'package:music_player/models/song.dart';
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
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.queue_music),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),
      endDrawer: QueueDrawer(),
      body: ValueListenableBuilder<Song?>(
        valueListenable: audio.currentSong,
        builder: (_, song, __) {
          if (song == null) {
            return const Center(child: Text("No song playing"));
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
                _controls(audio),
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
      child: const Icon(
        Icons.music_note,
        size: 150,
        color: Colors.blueAccent,
      ),
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
        Text(song.album,
            style: const TextStyle(fontStyle: FontStyle.italic)),
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

  Widget _controls(AudioManager audio) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,
      builder: (_, playing, __) {
        return ValueListenableBuilder<int>(
          valueListenable: audio.queue.currentIndex,
          builder: (context, _, __) {
            final isLast = audio.queue.isLast;
            final isFirst = audio.queue.isFirst;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ⏮ PREVIOUS
                IconButton(
                  iconSize: 48,
                  icon: Icon(
                    Icons.skip_previous,
                    color: isFirst ? Colors.grey.withOpacity(0.4) : null,
                  ),
                  onPressed: isFirst ? null : audio.playPrevious,
                ),

                // ⏯ PLAY / PAUSE
                ValueListenableBuilder<bool>(
                  valueListenable: audio.isPlaying,
                  builder: (context, playing, _) {
                    return IconButton(
                      iconSize: 80,
                      icon: Icon(
                        playing
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      onPressed: audio.toggle,
                    );
                  },
                ),

                // ⏭ NEXT
                IconButton(
                  iconSize: 48,
                  icon: Icon(
                    Icons.skip_next,
                    color: isLast ? Colors.grey.withOpacity(0.4) : null,
                  ),
                  onPressed: isLast ? null : audio.playNext,
                ),
              ],
            );
          },
        );
      },
    );
  }
}