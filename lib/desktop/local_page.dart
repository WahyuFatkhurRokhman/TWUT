// import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';
import 'package:music_player/pages/category_group_music_page.dart';
import 'package:music_player/routes/main_route.dart';
import 'package:music_player/utils/navigation_utils.dart';
// import 'package:music_player/widgets/mini_player.dart';
// import 'package:path/path.dart' as p;
// import 'package:music_player/models/song.dart';
// import 'package:music_player/services/music_scanner.dart';

class LocalPage extends StatefulWidget {
  const LocalPage({super.key});

  @override
  State<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    "folder",
    "album",
    "artist",
  ];

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationUtil.fadeReplace(
        context,
        CategoryGroupMusicPage(category: _categories[0]),
        root: false,
      );
    });
  }

Widget _buildTopFilter() {
  final labels = ["folder", "album", "artis"];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });

              _openCategory(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent            // 🟢 aktif
                    : AppColors.surface,          // 🌑 nonaktif
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.black              // kontras di hijau
                      : AppColors.textPrimary,    // putih di abu
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}
//   Widget _buildSearchBar() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20),
//     child: Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: TextField(
//         style: TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           hintText: "Search music...",
//           hintStyle: TextStyle(color: Colors.grey),
//           border: InputBorder.none,
//           prefixIcon: Icon(Icons.search, color: Colors.grey),
//         ),
//       ),
//     ),
//   );
// }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
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
              // decoration: const BoxDecoration(
              //   color: AppColors.card,
              //   borderRadius: const BorderRadius.vertical(
              //     bottom: Radius.circular(16),
              //     ),
              //   ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopFilter(),
                    const SizedBox(height: 5),

                    // _buildSearchBar(), // ✅ SEARCH MASUK SINI

                    // const SizedBox(height: 16),

                    Expanded(
                      child: Navigator(
                        key: NavigationUtil.nestedKey,
                        initialRoute: MainRoute.home,
                        onGenerateRoute: MainRoute.generateRoute,
                        onUnknownRoute: MainRoute.onUnknownRoute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }