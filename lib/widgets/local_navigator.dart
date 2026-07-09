import 'package:flutter/material.dart';
import 'package:music_player/pages/local_page.dart';
import 'package:music_player/routes/app_router.dart';
import 'package:music_player/utils/navigation_utils.dart';

class LocalNavigator extends StatefulWidget {
  const LocalNavigator({super.key});

  @override
  State<LocalNavigator> createState() => _LocalNavigatorState();
}

class _LocalNavigatorState extends State<LocalNavigator> {
  // Simple listener to handle navigation changes if needed
  void _onNavigationChanged(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Implement if needed for bottom bar or other UI updates
  }
@override
Widget build(BuildContext context) {
  return const LocalPage();
}
}

// Simple Proxy Observer to help with navigation observation
// ... (rest is fine)

class NavigatorObserverProxy extends NavigatorObserver {
  final Function(Route<dynamic>, Route<dynamic>?) onPop;
  final Function(Route<dynamic>, Route<dynamic>?) onPush;

  NavigatorObserverProxy({required this.onPop, required this.onPush});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onPush(route, previousRoute);
  }
}
