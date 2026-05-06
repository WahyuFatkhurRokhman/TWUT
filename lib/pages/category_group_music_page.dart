import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/services/music_service.dart';
import 'package:music_player/widgets/group_music_tile.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/pages/group_music_list_page.dart';
//import 'package:music_player/utils/group_music_helper.dart';

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

    // 🔥 TAMBAHKAN DI SINI
    if (widget.category != 'folder') {
      _musicService.selectedGroup.value = null;
    }
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
      // appBar: AppBar(
      //   title: Text(widget.category.toUpperCase()),
      //   actions: [
      //     ValueListenableBuilder<bool>(
      //       valueListenable: _musicService.isLoading,
      //       builder: (context, loading, _) {
      //         if (loading) {
      //           return const Padding(
      //             padding: EdgeInsets.all(12),
      //             child: SizedBox(
      //               width: 22,
      //               height: 22,
      //               child: CircularProgressIndicator(
      //                 strokeWidth: 2.2,
      //               ),
      //             ),
      //           );
      //         }

      //         return IconButton(
      //           icon: const Icon(Icons.refresh),
      //           onPressed: _musicService.refreshSongs,
      //         );
      //       },
      //     ),
      //   ],
      // ),
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

          return LayoutBuilder(
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
                itemCount: groups.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.2,
                ),
                itemBuilder: (context, index) {
                  final group = groups[index] as GroupMusic;
          
                  return GroupMusicTile(
                    groupMusic: group,
                    onTap: () {
                      _musicService.selectedGroup.value = group;
                  
                      // optional: debug / log
                      //debugPrint("Selected: ${getGroupTitle(group)}");
                  
                      _openGroup(group);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}