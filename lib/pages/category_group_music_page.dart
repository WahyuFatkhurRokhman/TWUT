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
  State<CategoryGroupMusicPage> createState() => _CategoryGroupMusicPageState();
}

class _CategoryGroupMusicPageState extends State<CategoryGroupMusicPage> {
  final MusicService _musicService = MusicService();

  List<GroupMusic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant CategoryGroupMusicPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    List<GroupMusic> result;

    switch (widget.category) {
      case 'folder':
        result = await _musicService.getByFolder();
        break;
      case 'album':
        result = await _musicService.getByAlbum();
        break;
      case 'artist':
        result = await _musicService.getByArtist();
        break;
      default:
        result = [];
    }

    setState(() {
      _groups = result;
      _isLoading = false;
    });
  }

  void _openGroup(GroupMusic group) {
    NavigationUtil.slideLeft(
      context,
      GroupMusicListPage(groupMusic: group),
      root: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _groups.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 120,
        ),
        itemBuilder: (context, index) {
          final group = _groups[index];
          return GroupMusicTile(
            groupMusic: group,
            onTap: () => _openGroup(group),
          );
        },
      ),
    );
  }
}