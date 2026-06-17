import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/pages/category_group_music_page.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/music_service.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/group_music_helper.dart';

class LocalPage extends StatefulWidget {
  const LocalPage({super.key});

  @override
  State<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  int _selectedIndex = 0;
  bool isInSubPage = false;
  String selectedFilter = "folder";
  GroupMusic? selectedFolder;
  AlbumGroup? selectedAlbum;
  ArtistGroup? selectedArtist;
  bool get isInFolderDetail =>
    selectedFilter == "folder" && musicService.selectedGroup.value != null;

  final List<String> _categories = [
    "folder",
    "album",
    "artist",
  ];

  final List<String> _labels = [
    "Folder",
    "Album",
    "Artists",
  ];

  MusicService get musicService => MusicService.instance;

//\  String get _currentCategory => _categories[_selectedIndex];
  String get _currentLabel => _labels[_selectedIndex];

  void _openCategory(int index) {
    setState(() {
      _selectedIndex = index;
    });

    NavigationUtil.noAnimationReplaceAndRemove(
      context,
      CategoryGroupMusicPage(
        category: _categories[index],
      ),
      root: false,
    );
  }

  void _openInitial() {
    NavigationUtil.fadeReplace(
      context,
      CategoryGroupMusicPage(category: _categories[_selectedIndex]),
      root: false,
    );
  }

  void resetSelection() {
    selectedFolder = null;
    selectedAlbum = null;
    selectedArtist = null;
  }

  void onFilterChanged(String filter) {
    selectedFilter = filter;
    _selectedIndex = _categories.indexOf(filter);

    resetSelection();
    musicService.selectedGroup.value = null;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInitial();
    });
  }
  

Widget _buildLeftSection() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // IconButton(
      //   onPressed: () {
      //     // reset saat back
      //     musicService.selectedGroup.value = null;

      //     if (NavigationUtil.nestedKey.currentState?.canPop() ?? false) {
      //       NavigationUtil.nestedKey.currentState?.pop();
      //     } else {
      //       Navigator.pop(context);
      //     }
      //   },
      //   icon: const Icon(Icons.arrow_back),
      // ),

      /// 🔥 INI YANG DIUBAH
      ValueListenableBuilder<GroupMusic?>(
        valueListenable: musicService.selectedGroup,
        builder: (context, group, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ✅ BACK BUTTON HANYA MUNCUL JIKA SUDAH MASUK
              if (group != null)
                IconButton(
                  onPressed: () {
                    musicService.selectedGroup.value = null;
                    resetSelection();

                    if (NavigationUtil.nestedKey.currentState?.canPop() ?? false) {
                      NavigationUtil.nestedKey.currentState?.pop();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),

              /// TITLE
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  group != null ? getGroupTitle(group) : _currentLabel,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      )
    ],
  );
}

Widget _buildMiddleSection() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_labels.length, (index) {
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            final filter = _categories[index];

            onFilterChanged(filter);

            // 🔥 DELAY BIAR BUILD SELESAI DULU
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _openCategory(index);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _labels[index],
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Widget _buildRightSection() {
  return ValueListenableBuilder<bool>(
    valueListenable: musicService.isLoading,
    builder: (context, isLoading, _) {
      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () async {
          await musicService.refreshSongs();
        },
      );
    },
  );
}

Widget buildTopBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: SizedBox(
      height: 48,
      child: Stack(
        children: [
          /// LEFT
          Align(
            alignment: Alignment.centerLeft,
            child: _buildLeftSection(),
          ),

          /// CENTER (FILTER TRUE CENTER)
          Align(
            alignment: Alignment.center,
            child: _buildMiddleSection(),
          ),

          /// RIGHT
          Align(
            alignment: Alignment.centerRight,
            child: _buildRightSection(),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF000000),
                Color(0xFF121212),
                Color(0xFF000000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              buildTopBar(),

              const SizedBox(height: 5),

              Expanded(
                child: Navigator(
                  key: NavigationUtil.nestedKey,
                  initialRoute: AppRouter.home,
                  onGenerateRoute: AppRouter.generateNestedRoute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
