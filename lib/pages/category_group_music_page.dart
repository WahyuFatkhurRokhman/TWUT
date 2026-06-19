import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/widgets/group_music_tile.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/pages/group_music_list_page.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/local_provider.dart';

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
  late LocalProvider _localProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _localProvider = Provider.of<LocalProvider>(context, listen: false);
      _localProvider.loadSongs();
    });

    // 🔥 TAMBAHKAN DI SINI
    if (widget.category != 'folder') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _localProvider.selectedGroup.value = null;
      });
    }
  }

  ValueNotifier<List<dynamic>> _groupNotifier() {
    switch (widget.category) {
      case 'folder':
        return _localProvider.folderGroup;

      case 'album':
        return _localProvider.albumGroup;

      case 'artist':
        return _localProvider.artistGroup;

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
    _localProvider = Provider.of<LocalProvider>(context);
    final notifier = _groupNotifier();

    return Scaffold(
      body: ValueListenableBuilder<List<dynamic>>(
        valueListenable: notifier,
        builder: (context, groups, _) {
          if (_localProvider.isLoading.value && groups.isEmpty) {
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
                      _localProvider.selectedGroup.value = group;

                  
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
