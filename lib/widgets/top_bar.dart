import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  /// Optional widgets (biar fleksibel, bukan kaku kayak beton)
  final Widget? center;
  final Widget? right;

  const TopBar({
    super.key,
    required this.title,
    this.onBack,
    this.center,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            /// 🔙 LEFT (Back + Title)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  if (onBack != null)
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_back),
                    //   onPressed: onBack,
                    // ),

                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🎯 CENTER (optional: filter, dll)
            if (center != null)
              Expanded(
                flex: 3,
                child: Center(child: center),
              ),

            /// 🔼 RIGHT (optional: refresh, action, dll)
            ?right,
          ],
        ),
      ),
    );
  }
}