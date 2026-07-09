import 'package:flutter/material.dart';
import 'package:music_player/routes/app_router.dart';

class PlaylistNavigator extends StatelessWidget {
  const PlaylistNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: AppRouter.playlistPage,
      onGenerateRoute: AppRouter.generatePlaylistRoute,
    );
  }
}
