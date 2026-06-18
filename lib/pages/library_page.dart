import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/pages/category_group_music_page.dart';
import 'package:music_player/pages/playlist_page.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/services/music_service.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/group_music_helper.dart';


class NavigatorObserverProxy extends NavigatorObserver {
  final VoidCallback onPop;
  final VoidCallback onPush;

  NavigatorObserverProxy({required this.onPop, required this.onPush});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPush();
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}
class LibraryPageState extends State<LibraryPage> {
  int _selectedIndex = 0;
  bool isInSubPage = false;

  // Track subpage title
  final ValueNotifier<String?> subPageTitle = ValueNotifier(null);

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
    "playlist",
  ];

  final List<String> _labels = [
    "Folder",
    "Album",
    "Artists",
    "Playlists",
  ];

  MusicService get musicService => MusicService.instance;

  String get _currentLabel => _labels[_selectedIndex];

  void _onNavigationChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _openCategory(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final category = _categories[index];

    if (category == "playlist") {
      NavigationUtil.noAnimationReplaceAndRemove(
        context,
        const PlaylistPage(),
        root: false,
      );
    } else {
      NavigationUtil.noAnimationReplaceAndRemove(
        context,
        CategoryGroupMusicPage(
          category: category,
        ),
        root: false,
      );
    }
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
  }

  @override
  void dispose() {
    subPageTitle.dispose();
    super.dispose();
  }


  Widget _buildLeftSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<GroupMusic?>(
          valueListenable: musicService.selectedGroup,
          builder: (context, group, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: subPageTitle,
              builder: (context, title, _) {
                final canPop = group != null || title != null || (NavigationUtil.nestedKey.currentState?.canPop() ?? false);
                
                String displayTitle = _currentLabel;
                if (group != null) {
                  displayTitle = getGroupTitle(group);
                } else if (title != null) {
                  displayTitle = title;
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canPop)
                      IconButton(
                        onPressed: () {
                          musicService.selectedGroup.value = null;
                          subPageTitle.value = null; // Clear title
                          resetSelection();

                          if (NavigationUtil.nestedKey.currentState?.canPop() ?? false) {
                            NavigationUtil.nestedKey.currentState?.pop();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        displayTitle,
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
            Align(
              alignment: Alignment.centerLeft,
              child: _buildLeftSection(),
            ),
            Align(
              alignment: Alignment.center,
              child: _buildMiddleSection(),
            ),
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
                  onGenerateRoute: AppRouter.generateLibraryRoute,
                  observers: [
                    NavigatorObserverProxy(
                      onPop: _onNavigationChanged,
                      onPush: _onNavigationChanged,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
