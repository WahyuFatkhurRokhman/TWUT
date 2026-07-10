import 'package:flutter/material.dart';
import 'package:music_player/routes/app_router.dart';

class PlaylistNavigator extends StatelessWidget {
  const PlaylistNavigator({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: AppRouter.playlistPage,
      onGenerateRoute: AppRouter.generatePlaylistRoute,
    );
  }
}
