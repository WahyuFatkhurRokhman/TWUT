import 'package:flutter/material.dart';

import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_response.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/pages/music_player_page.dart';

import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/youtube_service.dart';
import 'package:music_player/utils/navigation_utils.dart';

class YoutubeSearchDelegate extends SearchDelegate {
  final AudioManager audioManager = AudioManager();

  @override
  String? get searchFieldLabel => "Search YouTube Music";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox();

    return FutureBuilder<YtListResponse>(
      future: YoutubeService.search(query: query, type: YT_TYPE.VIDEO),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
          return const Center(
            child: Text(
              "No result found",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final results = snapshot.data!.results;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final song = results[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.thumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                song.channelTitle ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                // Capture SEBELUM close() — context akan deactivated setelah close
                final navigator = Navigator.of(context, rootNavigator: true);

                close(context, null);

                await audioManager.playYtQueue(
                  results.cast<YtSong>(),
                  startIndex: index,
                );

                navigator.push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MusicPlayerPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                            .animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOut),
                        ),
                        child: child,
                      );
                    },
                  ),
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
}