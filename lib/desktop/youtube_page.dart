import 'package:flutter/material.dart';
import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_response.dart';
import 'package:music_player/services/youtube_service.dart';

class YoutubePage extends StatelessWidget {
  const YoutubePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Youtube"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// SEARCH BUTTON
          buildSearchButton(context),

          const SizedBox(height: 24),

          const Expanded(
            child: Center(
              child: Text(
                "Search your favorite music",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SEARCH BAR
  Widget buildSearchButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showSearch(
            context: context,
            delegate: YoutubeSearchDelegate(),
          );
        },
        child: Container(
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.search,
                color: Colors.white70,
                size: 22,
              ),

              SizedBox(width: 10),

              Text(
                "Search songs, albums, artists",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YoutubeSearchDelegate extends SearchDelegate {
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

  /// ACTIONS
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  /// BACK BUTTON
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  /// SEARCH RESULT
  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          "Type something...",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return FutureBuilder<YtListResponse>(
      future: YoutubeService.search(
        query: query,
        type: YT_TYPE.VIDEO,
      ),

      builder: (context, snapshot) {
        /// LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        /// ERROR
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        /// EMPTY
        if (!snapshot.hasData ||
            snapshot.data!.results.isEmpty) {
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
            final item = results[index];

            final thumbnail = item.thumbnail;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnail,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                item.channelTitle ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              onTap: () {
                /// TODO PLAY MUSIC
                debugPrint(item.title);
              },
            );
          },
        );
      },
    );
  }

  /// SUGGESTIONS
  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text(
        "Search music...",
        style: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }
}