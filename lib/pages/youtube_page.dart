import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/pages/youtube_search_delegate.dart';

class YoutubePage extends StatelessWidget {
  const YoutubePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Youtube", style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
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
                  color: AppColors.textSecondary,
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
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 22,
              ),

              SizedBox(width: 10),

              Text(
                "Search songs, albums, artists",
                style: TextStyle(
                  color: AppColors.textSecondary,
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
