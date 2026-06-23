import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/time_utils.dart';

class AudioProgressBar extends StatefulWidget {
  final AudioManager audio;

  final bool showTime;

  const AudioProgressBar({
    super.key,
    required this.audio,
    this.showTime = true,
  });

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  final ValueNotifier<double?> _dragValue = ValueNotifier(null);

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  bool _wasPlaying = false;

  @override
  void dispose() {
    _dragValue.dispose();
    _isDragging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: widget.audio.position,

      builder: (_, pos, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: widget.audio.duration,

          builder: (_, dur, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isDragging,

              builder: (_, isDragging, _) {
                return ValueListenableBuilder<double?>(
                  valueListenable: _dragValue,

                  builder: (_, dragValue, _) {
                    final max = dur.inMilliseconds.toDouble();

                    final safeMax = max <= 0 ? 1.0 : max;

                    final current = pos.inMilliseconds.toDouble().clamp(
                      0.0,
                      safeMax,
                    );

                    final baseValue = isDragging
                        ? (dragValue ?? current)
                        : current;

                    final smoothValue =
                        lerpDouble(current, baseValue, 0.25) ?? baseValue;

                    return Column(
                      children: [
                        SliderTheme(
                          data: const SliderThemeData(
                            trackHeight: 3,

                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),

                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 0,
                            ),
                          ),

                          child: Slider(
                            min: 0,
                            max: safeMax,

                            value: smoothValue.clamp(0.0, safeMax),

                            onChangeStart: (v) async {
                              _isDragging.value = true;

                              _dragValue.value = v;

                              _wasPlaying = widget.audio.isPlaying.value;

                              if (_wasPlaying) {
                                await widget.audio.pause();
                              }
                            },

                            onChanged: (v) {
                              _dragValue.value = v;
                            },

                            onChangeEnd: (v) async {
                              await widget.audio.seek(
                                Duration(milliseconds: v.toInt()),
                              );

                              if (_wasPlaying) {
                                await widget.audio.resume();
                              }

                              _isDragging.value = false;

                              _dragValue.value = null;
                            },
                          ),
                        ),

                        if (widget.showTime)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
