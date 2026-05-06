import 'package:flutter/material.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/time_utils.dart';
import '../services/audio_manager.dart';
import 'dart:ui';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {

  final ValueNotifier<double?> _dragValue = ValueNotifier(null);
  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  @override
  void dispose() {
    _dragValue.dispose();
    _isDragging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = AudioManager();
    final theme = Theme.of(context);

    return Material(
      elevation: 18,
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () {
          NavigationUtil.slideUp(context, MusicPlayerPage());
        },
        child: SafeArea(
          top: false,
          child: ValueListenableBuilder<Song?>(
            valueListenable: audio.currentSong,
            builder: (_, song, __) {
              if (song == null) return const SizedBox();

              return SizedBox(
                height: 108,
                child: Column(
                  children: [
                    _progressBar(audio),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Stack(
                          children: [
                            // 🔹 LEFT: Song info
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 300, // opsional, biar stabil
                                child: _songInfo(song, theme),
                              ),
                            ),

                            // 🔹 CENTER: Controls (ABSOLUTE CENTER)
                            Align(
                              alignment: Alignment.center,
                              child: _controls(audio),
                            ),

                            // 🔹 RIGHT: Volume, repeat, dll
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 220, // opsional
                                child: _rightSection(audio),
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

  Widget _songInfo(Song song, ThemeData theme) {
    return Row(
      children: [
        Hero(
          tag: song.path,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: song.artwork != null
                ? Image.memory(
              song.artwork!,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            )
                : Container(
              width: 58,
              height: 58,
              color: theme.colorScheme.primary.withOpacity(.08),
              child: const Icon(Icons.music_note_rounded),
            ),
          ),
        ),

        const SizedBox(width: 12),

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
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
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
                  playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
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

  Widget _rightSection(AudioManager audio) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _repeat(audio),
        _shuffle(audio),

        const SizedBox(width: 6),

        SizedBox(
          width: 130,
          child: _volume(audio),
        ),
      ],
    );
  }

  Widget _shuffle(AudioManager audio) {
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

  Widget _repeat(AudioManager audio) {
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
          icon: Icon(
            icon,
            size: 20,
            color: color,
          ),
          onPressed: audio.toggleRepeatMode,
        );
      },
    );
  }

  Widget _volume(AudioManager audio) {
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

Widget _progressBar(AudioManager audio) {
  return ValueListenableBuilder<Duration>(
    valueListenable: audio.position,
    builder: (_, pos, __) {
      return ValueListenableBuilder<Duration>(
        valueListenable: audio.duration,
        builder: (_, dur, __) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isDragging,
            builder: (_, isDragging, __) {
              return ValueListenableBuilder<double?>(
                valueListenable: _dragValue,
                builder: (_, dragValue, __) {
                  
                  final max = dur.inMilliseconds.toDouble();
                  final safeMax = max <= 0 ? 1.0 : max;

                  final current =
                      pos.inMilliseconds.toDouble().clamp(0.0, safeMax);

                  // 🔥 Smooth transition
                  final baseValue = isDragging
                      ? (dragValue ?? 0)
                      : current;

                  final smoothValue = lerpDouble(
                    _dragValue.value ?? current,
                    baseValue,
                    0.25, // semakin kecil = makin smooth
                  ) ?? baseValue;

                  return Column(
                    children: [
                      SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 3,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 5,
                          ),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 0),
                        ),
                        child: Slider(
                          min: 0,
                          max: safeMax,
                          value: smoothValue.clamp(0.0, safeMax),

                          onChangeStart: (v) {
                            _isDragging.value = true;
                            _dragValue.value = v;
                            audio.pause();
                          },

                          onChanged: (v) {
                            _dragValue.value = v;
                          },

                          onChangeEnd: (v) async {
                            if (dur.inMilliseconds == 0) return;

                            await audio.seek(Duration(milliseconds: v.toInt()));
                            await audio.resume();

                            _isDragging.value = false;
                            _dragValue.value = null;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TimeUtils.formatDuration(pos),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              TimeUtils.formatDuration(dur),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}
}