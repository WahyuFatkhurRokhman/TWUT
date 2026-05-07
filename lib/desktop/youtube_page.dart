import 'package:flutter/material.dart';
import 'package:music_player/desktop/youtube_search_delegate.dart';
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
