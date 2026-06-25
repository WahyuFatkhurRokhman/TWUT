import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/history_play_local_song.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/utils/navigation_utils.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryPlayLocalSong _historyService = HistoryPlayLocalSong(AppDatabase());
  List<Song> _historySongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    DataNotifier().historyNotifier.addListener(_loadHistory);
  }

  @override
  void dispose() {
    DataNotifier().historyNotifier.removeListener(_loadHistory);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistorySong();
    if (mounted) {
      setState(() {
        _historySongs = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _historySongs.isEmpty
              ? const Center(child: Text('No history yet', style: TextStyle(color: AppColors.textSecondary)))
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _historySongs.length,
                    itemBuilder: (context, index) {
                      final song = _historySongs[index];
                      return ListTile(
                        title: Text(song.title, style: const TextStyle(color: AppColors.textPrimary)),
                        subtitle: Text(song.artist, style: const TextStyle(color: AppColors.textSecondary)),
                        onTap: () async {
                          await AudioManager().playLocalSong(song);
                          if (context.mounted) {
                            NavigationUtil.slideUp(context, const MusicPlayerPage(), root: true);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
