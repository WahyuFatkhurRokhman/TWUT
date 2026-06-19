import 'package:flutter/material.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final AppDatabase db;
  final Song song;

  const AddToPlaylistDialog({super.key, required this.db, required this.song});

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  late final PlaylistService _playlistService;
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _playlistService = PlaylistService(widget.db);
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _playlistService.getAllPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  Future<void> _createNewPlaylist() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Playlist Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama Playlist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Buat'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final id = await _playlistService.createPlaylist(name);
      await _playlistService.addSongToPlaylist(id, widget.song);
      
      if (mounted) {
        SnackbarUtil.showSuccess(context, message: 'Playlist "$name" berhasil dibuat');
        
        // Navigate to the detail page of the new playlist
        final playlist = await _playlistService.getPlaylistDetailById(id);
        if (playlist != null) {
          Navigator.pop(context); // Close dialog
          Navigator.pushNamed(
            context,
            AppRouter.playlistDetail,
            arguments: {'playlist': playlist},
          );
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambahkan ke Playlist'),
      content: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Buat Playlist Baru'),
                  onTap: _createNewPlaylist,
                ),
                ..._playlists.map((playlist) => ListTile(
                      title: Text(playlist.name),
                      onTap: () async {
                        final success = await _playlistService.addSongToPlaylist(playlist.id, widget.song);
                        if (!mounted) return;
                        if (success) {
                          SnackbarUtil.showSuccess(context, message: 'Lagu ditambahkan ke ${playlist.name}');
                          Navigator.pop(context);
                        } else {
                          SnackbarUtil.showError(context, message: 'Lagu sudah ada di playlist ini');
                        }
                      },
                    )),
              ],
            ),
    );
  }
}
