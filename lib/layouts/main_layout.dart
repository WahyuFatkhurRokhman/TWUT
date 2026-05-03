// import 'package:flutter/material.dart';
// import 'package:music_player/pages/category_group_music_page.dart';
// import 'package:music_player/routes/main_route.dart';
// import 'package:music_player/utils/navigation_utils.dart';
// import 'package:music_player/widgets/mini_player.dart';

// class MainLayout extends StatefulWidget {
//   const MainLayout({super.key});

//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   int _selectedIndex = 0;

//   final List<String> _categories = [
//     'folder',
//     'album',
//     'artist',
//   ];

//   void _openCategory(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     NavigationUtil.noAnimationReplaceAndRemove(
//       context,
//       CategoryGroupMusicPage(
//         category: _categories[index],
//       ),
//       root: false,
//     );
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       NavigationUtil.fadeReplace(
//         context,
//         CategoryGroupMusicPage(category: _categories[0]),
//         root: false,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Row(
//                 children: [
//                   NavigationRail(
//                     selectedIndex: _selectedIndex,
//                     onDestinationSelected: _openCategory,
//                     labelType: NavigationRailLabelType.all,
//                     destinations: const [
//                       NavigationRailDestination(
//                         icon: Icon(Icons.folder_open),
//                         label: Text('Folder'),
//                       ),
//                       NavigationRailDestination(
//                         icon: Icon(Icons.album),
//                         label: Text('Album'),
//                       ),
//                       NavigationRailDestination(
//                         icon: Icon(Icons.person),
//                         label: Text('Artis'),
//                       ),
//                     ],
//                   ),

//                   const VerticalDivider(thickness: 1, width: 1),

//                   Expanded(
//                     child: Navigator(
//                       key: NavigationUtil.nestedKey,
//                       initialRoute: MainRoute.home,
//                       onGenerateRoute: MainRoute.generateRoute,
//                       onUnknownRoute: MainRoute.onUnknownRoute,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const MiniPlayer(),
//           ],
//         ),
//       ),
//     );
//   }
// }