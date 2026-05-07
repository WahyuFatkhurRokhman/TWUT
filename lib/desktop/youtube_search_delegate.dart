import 'package:flutter/material.dart';
import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/services/youtube_service.dart';

class YoutubeSearchDelegate extends SearchDelegate {
  List<dynamic> results = [];
  bool isLoading = false;

  Future<void> _search() async {
    if (query.trim().isEmpty) return;

    isLoading = true;

    final response = await YoutubeService.search(
      query: query,
      type: YT_TYPE.VIDEO,
    );

    results = response.results;

    isLoading = false;
  }

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
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
          results.clear();
          showSuggestions(context);
        },
      ),
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
    return FutureBuilder(
      future: _search(),
      builder: (context, snapshot) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];

            final snippet = item.snippet;
            final thumbnail = snippet.thumbnails.high.url;

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnail,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                snippet.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                snippet.channelTitle ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                /// TODO: play music
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text(
        "Search music...",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}