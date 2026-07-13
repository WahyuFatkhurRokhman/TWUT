import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  YoutubePlayerController? _ytController;
  String? _lastVideoId;

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  void _initYoutubeController(String videoId) {
    // Windows/Linux tidak punya implementasi webview yang didukung untuk
    // youtube_player_iframe, jadi video sudah diputar via browser bawaan
    // OS (lihat YoutubePlayerManager). Tidak perlu controller di sini.
    if (!PlatformUtil.isAndroid) return;

    if (_lastVideoId == videoId) return;
    _lastVideoId = videoId;

    _ytController?.close();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false, // Kita kontrol lewat AudioManager
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: true, // Mute video karena audio diputar lewat just_audio
      ),
    );
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

          if (media.isYoutube) {
            _initYoutubeController(media.sourceId);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                _playerMainView(media),
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

  Widget _playerMainView(NowPlayingMedia media) {
    if (media.isYoutube && PlatformUtil.isDesktop) {
      return _youtubeDesktopPlaceholder(media);
    }

    if (media.isYoutube && _ytController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _ytController!, aspectRatio: 16 / 9),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.ondemand_video, size: 56, color: Colors.white70),
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
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        if (isDesktop) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [_toggleRepeatMode(audio), _toggleShuffleMode(audio)],
              ),
              Flexible(
                child: _mainPlaybackControls(audio, isDesktop: isDesktop),
              ),
              _volumeControl(audio),
            ],
          );
        } else {
          // MOBILE: Left (Shuffle), Center (Controls), Right (Repeat). No Volume.
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _toggleShuffleMode(audio),
              Flexible(
                child: _mainPlaybackControls(audio, isDesktop: isDesktop),
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

    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,
      builder: (_, playing, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: prevNextSize,
              icon: const Icon(Icons.skip_previous),
              onPressed: audio.playPrevious,
            ),
            IconButton(
              iconSize: playSize,
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
              ),
              onPressed: audio.toggle,
            ),
            IconButton(
              iconSize: prevNextSize,
              icon: const Icon(Icons.skip_next),
              onPressed: audio.playNext,
            ),
          ],
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
    return PopupMenuButton<void>(
      tooltip: "Volume",
      icon: ValueListenableBuilder<double>(
        valueListenable: audio.volume,
        builder: (_, vol, _) {
          return Icon(
            vol == 0
                ? Icons.volume_off_rounded
                : vol < 0.5
                ? Icons.volume_down_rounded
                : Icons.volume_up_rounded,
            color: Colors.grey,
          );
        },
      ),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: 180,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        audio.volume.value == 0
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        final newVol = audio.volume.value == 0 ? 1.0 : 0.0;
                        audio.setVolume(newVol);
                        setMenuState(() {});
                      },
                    ),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: audio.volume.value,
                        onChanged: (value) {
                          audio.setVolume(value);
                          setMenuState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
