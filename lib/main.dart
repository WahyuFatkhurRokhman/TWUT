import 'package:flutter/material.dart';
import 'package:music_player/config/app_theme.dart';
import 'package:music_player/routes/root_route.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/platform_util.dart';
import 'package:flutter/material.dart';

import 'package:music_player/config/app_theme.dart';
import 'package:music_player/routes/root_route.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/platform_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformUtil.ensureSupported();

  debugPrint("Running on: ${PlatformUtil.name}");
  AudioManager().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Library',
      theme: AppTheme.darkTheme,
      initialRoute: RootRoute.mainLayout,
      onGenerateRoute: RootRoute.generateRoute,
    );
  }
}