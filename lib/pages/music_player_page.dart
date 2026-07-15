import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:music_player/models/constant/PLAYBACK_SOURCE.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:music_player/widgets/audio_progress_bar.dart';
import 'package:music_player/widgets/media_artwork.dart';
import 'package:music_player/widgets/queue_drawer.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  // Tidak lagi membuat YoutubePlayerController sendiri di sini — pakai
  // controller yang sama dengan yang dipakai YoutubePlayerManager untuk
  // play/pause/seek, supaya video yang tampil = video yang benar-benar
  // dikontrol oleh AudioManager (sebelumnya ada 2 controller terpisah,
  // sehingga video "diam" walau perintah play sukses terkirim).

  double _volumeBeforeMute = 1.0;

  void _toggleMute(AudioManager audio) {
    if (audio.volume.value > 0) {
      _volumeBeforeMute = audio.volume.value;
      audio.setVolume(0);
    } else {
      audio.setVolume(_volumeBeforeMute == 0 ? 1.0 : _volumeBeforeMute);
    }
  }

  IconData _volumeIcon(double vol) {
    if (vol == 0) return Icons.volume_off_rounded;
    if (vol < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

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
      body: ValueListenableBuilder<NowPlayingMedia?>(
        valueListenable: audio.currentMedia,
        builder: (_, media, _) {
          if (media == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) NavigationUtil.popRoot(context);
            });
            return const SizedBox();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _playerMainView(media),
                      const SizedBox(height: 24),
                      _songInfo(media),
                      const SizedBox(height: 24),
                      AudioProgressBar(audio: audio, showTime: true),
                      const SizedBox(height: 20),
                      _controlsRow(audio),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _playerMainView(NowPlayingMedia media) {
    if (media.isYoutube && PlatformUtil.isDesktop) {
      return _youtubeDesktopPlaceholder(media);
    }

    if (media.isYoutube && PlatformUtil.isAndroid) {
      // Tidak bikin YoutubePlayer widget baru di sini. Video-nya sudah
      // diputar oleh instance YoutubeMiniPlayer yang permanen di
      // main_layout.dart (nempel ke controller yang sama). Satu controller
      // youtube_player_iframe cuma boleh nempel ke SATU PlatformView —
      // kalau dipasang dobel (di sini + di main_layout), Android bakal
      // crash: "PlatformView#getView() was already added to a parent view".
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black26,
            alignment: Alignment.center,
            child: ValueListenableBuilder<bool>(
              valueListenable: AudioManager().youtube.isLoading,
              builder: (_, loading, _) {
                if (loading) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white70),
                      SizedBox(height: 12),
                      Text(
                        "Memuat video...",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  );
                }
                return const Icon(
                  Icons.ondemand_video,
                  size: 56,
                  color: Colors.white70,
                );
              },
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < 300 ? constraints.maxWidth : 300.0;
        return Hero(
          tag: media.id,
          child: MediaArtwork(media: media, size: size, radius: 20),
        );
      },
    );
  }

  Widget _youtubeDesktopPlaceholder(NowPlayingMedia media) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black26,
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<bool>(
            valueListenable: AudioManager().youtube.isLoading,
            builder: (_, loading, _) {
              if (loading) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white70),
                    SizedBox(height: 12),
                    Text(
                      "Membuka browser...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.ondemand_video,
                    size: 56,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Diputar di browser bawaan",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(
                        "https://www.youtube.com/watch?v=${media.sourceId}",
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text("Buka lagi di browser"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _songInfo(NowPlayingMedia media) {
    return Column(
      children: [
        Text(
          media.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          media.artist,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _controlsRow(AudioManager audio) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = MediaQuery.of(context).size.width >= 800;
        // Volume slider cuma masuk akal di Windows/Linux, karena di sana
        // aplikasi benar-benar mengatur volume output-nya sendiri. Di
        // Android, volume diatur lewat tombol fisik/sistem, jadi slider
        // ini tidak ditampilkan sama sekali — walaupun layarnya lebar
        // (mis. tablet), tetap tidak muncul karena baseline-nya platform,
        // bukan lebar layar.
        final showVolume = PlatformUtil.isDesktop;

        if (isWideLayout) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [_toggleRepeatMode(audio), _toggleShuffleMode(audio)],
              ),
              Flexible(
                child: _mainPlaybackControls(audio, isDesktop: isWideLayout),
              ),
              if (showVolume)
                _volumeControl(audio)
              else
                const SizedBox(width: 48),
            ],
          );
        } else {
          // MOBILE: Left (Shuffle), Center (Controls), Right (Repeat). No Volume.
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _toggleShuffleMode(audio),
              Flexible(
                child: _mainPlaybackControls(audio, isDesktop: isWideLayout),
              ),
              _toggleRepeatMode(audio),
            ],
          );
        }
      },
    );
  }

  Widget _mainPlaybackControls(AudioManager audio, {required bool isDesktop}) {
    final double prevNextSize = isDesktop ? 42 : 36;
    final double playSize = isDesktop ? 72 : 64;

    return ValueListenableBuilder<PlaybackSource>(
      valueListenable: audio.activeSource,
      builder: (_, source, _) {
        // Youtube diputar single-video (tanpa antrean), jadi next/prev
        // tidak berlaku dan tombolnya dinonaktifkan (bukan disembunyikan,
        // biar layout tetap konsisten).
        final navEnabled = source != PlaybackSource.youtube;

        return ValueListenableBuilder<bool>(
          valueListenable: audio.isPlaying,
          builder: (_, playing, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: audio.isLoading,
              builder: (_, loading, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: prevNextSize,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: navEnabled ? audio.playPrevious : null,
                    ),
                    if (loading)
                      SizedBox(
                        width: playSize,
                        height: playSize,
                        child: Padding(
                          padding: EdgeInsets.all(playSize * 0.28),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        iconSize: playSize,
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: audio.toggle,
                      ),
                    IconButton(
                      iconSize: prevNextSize,
                      icon: const Icon(Icons.skip_next),
                      onPressed: navEnabled ? audio.playNext : null,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _toggleShuffleMode(AudioManager audio) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.queue.shuffleMode,
      builder: (_, enabled, _) => IconButton(
        onPressed: audio.queue.toggleShuffle,
        icon: Icon(Icons.shuffle, color: enabled ? Colors.green : Colors.grey),
      ),
    );
  }

  Widget _toggleRepeatMode(AudioManager audio) {
    return ValueListenableBuilder<REPEAT_MODE>(
      valueListenable: audio.repeatMode,
      builder: (_, mode, _) {
        IconData icon = Icons.repeat;
        Color color = Colors.grey;
        if (mode == REPEAT_MODE.ALL) color = Colors.green;
        if (mode == REPEAT_MODE.ONE) {
          icon = Icons.repeat_one;
          color = Colors.green;
        }
        return IconButton(
          onPressed: audio.toggleRepeatMode,
          icon: Icon(icon, color: color),
        );
      },
    );
  }

  Widget _volumeControl(AudioManager audio) {
    return ValueListenableBuilder<double>(
      valueListenable: audio.volume,
      builder: (_, vol, _) {
        return PopupMenuButton<void>(
          tooltip: "Volume",
          icon: Icon(_volumeIcon(vol), color: Colors.grey),
          padding: EdgeInsets.zero,
          offset: const Offset(0, -190),
          constraints: const BoxConstraints(maxWidth: 56),
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              enabled: true,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 40,
                height: 170,
                child: StatefulBuilder(
                  builder: (context, setPopupState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<double>(
                          valueListenable: audio.volume,
                          builder: (_, currentVol, _) => Text(
                            "${(currentVol * 100).round()}%",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: ValueListenableBuilder<double>(
                              valueListenable: audio.volume,
                              builder: (_, currentVol, _) => Slider(
                                min: 0,
                                max: 1,
                                value: currentVol,
                                onChanged: (v) {
                                  audio.setVolume(v);
                                  if (v > 0) _volumeBeforeMute = v;
                                },
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: audio.volume,
                          builder: (_, currentVol, _) => IconButton(
                            splashRadius: 18,
                            icon: Icon(_volumeIcon(currentVol), size: 18),
                            onPressed: () => _toggleMute(audio),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
