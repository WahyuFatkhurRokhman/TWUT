import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/now_playing_media.dart';

import 'package:music_player/pages/music_player_page.dart';

import 'package:music_player/services/audio_manager.dart';

import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/platform_util.dart';

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
        onTap: () =>
            NavigationUtil.push(context, const MusicPlayerPage(), root: true,
                transition: PageTransition.slideUp),
        child: SafeArea(
          top: false,
          child: ValueListenableBuilder<NowPlayingMedia?>(
            valueListenable: audio.currentMedia,
            builder: (_, media, _) {
              if (media == null) return const SizedBox();

              // YouTube di-treat info-only di semua platform: di Android
              // videonya tetap main inline via WebView (makanya masih ada
              // tombol "berhenti"), tapi mini player tidak menampilkan
              // kontrol play/pause/seek/skip — kontrol lengkap hanya ada
              // di MusicPlayerPage. Di Windows/Linux videonya lepas ke
              // browser eksternal jadi memang dari awal tidak ada kontrol.
              if (media.isYoutube) {
                return _youtubeInfoBar(context, media, theme);
              }

              return SizedBox(
                height: 108,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;

                    return Column(
                      children: [
                        AudioProgressBar(audio: audio, showTime: false),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Stack(
                              children: [
                                // LEFT: Song Info
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: isDesktop ? 300 : constraints
                                        .maxWidth * 0.5,
                                    child: _songInfo(media, theme),
                                  ),
                                ),

                                // CENTER / RIGHT: Controls
                                Align(
                                  alignment: isDesktop
                                      ? Alignment.center
                                      : Alignment.centerRight,
                                  child: _controls(),
                                ),

                                // RIGHT: Volume (Desktop only)
                                if (isDesktop)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: 100,
                                      child: _rightSection(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Bar info-only untuk YouTube — dipakai di semua platform.
  /// Tidak ada kontrol play/pause/seek/skip di sini; kontrol lengkap
  /// (khusus Android, karena Desktop memang tidak bisa dikontrol sama
  /// sekali) hanya tersedia di MusicPlayerPage.
  Widget _youtubeInfoBar(BuildContext context, NowPlayingMedia media,
      ThemeData theme) {
    final isDesktop = PlatformUtil.isDesktop;

    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Hero(
              tag: media.id,
              child: MediaArtwork(media: media, size: 48, radius: 10),
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
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<bool>(
                    valueListenable: audio.isLoading,
                    builder: (_, loading, _) {
                      if (loading) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isDesktop ? "Membuka browser..." : "Memuat video...",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        );
                      }
                      return ValueListenableBuilder<bool>(
                        valueListenable: audio.isPlaying,
                        builder: (_, playing, _) {
                          final label = isDesktop
                              ? "Diputar di browser"
                              : (playing ? "Sedang diputar" : "Dijeda");
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.ondemand_video, size: 13, color: Colors
                                  .grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            if (isDesktop)
              IconButton(
                splashRadius: 20,
                tooltip: "Buka lagi di browser",
                icon: const Icon(Icons.open_in_browser),
                onPressed: () =>
                    launchUrl(
                      Uri.parse(
                          "https://www.youtube.com/watch?v=${media.sourceId}"),
                      mode: LaunchMode.externalApplication,
                    ),
              ),
            IconButton(
              splashRadius: 20,
              tooltip: "Berhenti",
              icon: const Icon(Icons.close_rounded),
              onPressed: audio.stopAndClearCurrent,
            ),
          ],
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

      builder: (_, playing, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: audio.isLoading,
          builder: (_, loading, _) {
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

                  child: loading
                      ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                      : IconButton(
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
      },
    );
  }

  Widget _rightSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _repeat(),
        _shuffle(),
      ],
    );
  }

  Widget _shuffle() {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.queue.shuffleMode,

      builder: (_, enabled, _) {
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

      builder: (_, mode, _) {
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

}