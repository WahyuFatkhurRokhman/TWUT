import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/services/music_service.dart';
import 'package:music_player/widgets/group_music_tile.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/pages/group_music_list_page.dart';

class CategoryGroupMusicPage extends StatefulWidget {
  final String category; // folder / album / artist

  const CategoryGroupMusicPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryGroupMusicPage> createState() =>
      _CategoryGroupMusicPageState();
}

class _CategoryGroupMusicPageState extends State<CategoryGroupMusicPage> {
  final MusicService _musicService = MusicService.instance;

  @override
  void initState() {
    super.initState();
    _musicService.loadSongs();
  }

  /// ambil notifier sesuai kategori
  ValueNotifier<List<dynamic>> _groupNotifier() {
    switch (widget.category) {
      case 'folder':
        return _musicService.folderGroup;

      case 'album':
        return _musicService.albumGroup;

      case 'artist':
        return _musicService.artistGroup;

      default:
        return ValueNotifier([]);
    }
  }

  void _openGroup(GroupMusic group) {
    NavigationUtil.noAnimation(
      context,
      GroupMusicListPage(groupMusic: group),
      root: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _groupNotifier();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _musicService.isLoading,
            builder: (context, loading, _) {
              if (loading) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                    ),
                  ),
                );
              }

              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _musicService.refreshSongs,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<dynamic>>(
        valueListenable: notifier,
        builder: (context, groups, _) {
          if (_musicService.isLoading.value && groups.isEmpty) {
            return const Center(
              child: Text("Sedang memindai file lokal..."),
            );
          }

          if (groups.isEmpty) {
            return const Center(
              child: Text("Tidak ada data"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 120,
            ),
            itemBuilder: (context, index) {
              final group = groups[index] as GroupMusic;

              return GroupMusicTile(
                groupMusic: group,
                onTap: () => _openGroup(group),
              );
            },
          );
        },
      ),
    );
  }
}