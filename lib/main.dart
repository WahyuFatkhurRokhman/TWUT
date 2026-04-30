import 'package:flutter/material.dart';
import 'package:music_player/routes/root_route.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/platform_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformUtil.ensureSupported();

  print("Running on: ${PlatformUtil.name}");
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
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: RootRoute.mainLayout,
      onGenerateRoute: RootRoute.generateRoute,
    );
  }
}