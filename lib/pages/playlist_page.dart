import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/pages/playlist_detail_page.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/data_notifier.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';
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
    NavigationUtil.noAnimation(context, PlaylistDetailPage(playlist:
    playlist), root: false);
  }

  Future<void> _renamePlaylist(Playlist playlist) async {
    final controller = TextEditingController(text: playlist.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Playlist'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Simpan')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _playlistService.renamePlaylist(playlist.id, newName);
      if (mounted) SnackbarUtil.showSuccess(context, message: 'Playlist diubah menjadi "$newName"');
    }
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Playlist?'),
        content: Text('Anda yakin ingin menghapus playlist "${playlist.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await _playlistService.deletePlaylist(playlist.id);
      if (mounted) SnackbarUtil.showSuccess(context, message: 'Playlist "${playlist.name}" dihapus');
    }
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
                      onRename: () => _renamePlaylist(playlist),
                      onDelete: () => _deletePlaylist(playlist),
                    );
                  },
                );
              },
            ),
    );
  }
}
