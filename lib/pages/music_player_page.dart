import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/navigation_utils.dart';
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
    if (media.isYoutube && _ytController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _ytController!,
            aspectRatio: 16 / 9,
          ),
        ),
      );
    }

    return Hero(
      tag: media.id,
      child: MediaArtwork(media: media, size: 300, radius: 20),
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
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _toggleRepeatMode(audio),
              _toggleShuffleMode(audio),
            ],
          ),
        ),
        _mainPlaybackControls(audio),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _volumeControl(audio),
          ),
        ),
      ],
    );
  }

  Widget _mainPlaybackControls(AudioManager audio) {
    return ValueListenableBuilder<bool>(
      valueListenable: audio.isPlaying,
      builder: (_, playing, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 42,
              icon: const Icon(Icons.skip_previous),
              onPressed: audio.playPrevious,
            ),
            IconButton(
              iconSize: 72,
              icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
              onPressed: audio.toggle,
            ),
            IconButton(
              iconSize: 42,
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
    return IconButton(
      icon: const Icon(Icons.volume_up, color: Colors.grey),
      onPressed: () {
        // Implementasi volume slider popup atau toggle mute
      },
    );
  }
}
