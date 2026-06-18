import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/widgets/playlist_tile.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistService _playlistService = PlaylistService(AppDatabase());
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    DataNotifier().playlistNotifier.addListener(_loadPlaylists);
  }

  @override
  void dispose() {
    DataNotifier().playlistNotifier.removeListener(_loadPlaylists);
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _playlistService.getAllPlaylists();
    if (mounted) {
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    }
  }

  void _navigateToPlaylist(Playlist playlist) {
    Navigator.pushNamed(
      context,
      AppRouter.playlistDetail,
      arguments: {
        'playlist': playlist,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
          ? const Center(
              child: Text(
                'No playlists yet',
                style: TextStyle(color: Colors.white60),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;

                if (constraints.maxWidth > 1400) {
                  crossAxisCount = 6;
                } else if (constraints.maxWidth > 1000) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 700) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _playlists.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.2,
                  ),
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    
                    return PlaylistTile(
                      title: playlist.name,
                      onTap: () => _navigateToPlaylist(playlist),
                      onMoreTap: () {
                        // Implement more menu logic here
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
