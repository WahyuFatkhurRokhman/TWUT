import 'package:flutter/material.dart';
import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_response.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/youtube_service.dart';
import 'package:music_player/utils/navigation_utils.dart';

class YoutubeSearchDelegate extends SearchDelegate {
  final AudioManager audioManager = AudioManager();
  bool _isPlaying = false; // Flag to prevent multiple taps

  @override
  String? get searchFieldLabel => "Cari di YouTube Music";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox();

    return FutureBuilder<YtListResponse>(
      future: YoutubeService.search(query: query, type: YT_TYPE.VIDEO),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
          return const Center(child: Text("Hasil tidak ditemukan", style: TextStyle(color: Colors.white54)));
        }

        final results = snapshot.data!.results;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final song = results[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(song.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
              ),
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(song.channelTitle ?? "YouTube", style: const TextStyle(color: Colors.white70)),
              onTap: () async {
                close(context, null);

                // Play the song
                await audioManager.playYtSong(song);

                NavigationUtil.push(
                  context,
                  const MusicPlayerPage(),
                  transition: PageTransition.slideUp,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();

  @override
  void close(BuildContext context, Object? result) {
    _isPlaying = false; // Reset flag when closing
    super.close(context, result);
  }
}