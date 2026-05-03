import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class SidebarDesktop extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const SidebarDesktop({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      color: AppColors.card,// lebih gelap biar kontras
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // 🔥 Logo + Title
          Row(
            children: const [
              Icon(Icons.graphic_eq, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                "Musicplayer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // const SizedBox(height: 30),

          // 🔎 DISCOVER
          // const Text(
          //   "DISCOVER",
          //   style: TextStyle(
          //     color: Colors.white54,
          //     fontSize: 11,
          //     letterSpacing: 1.2,
          //   ),
          // ),

          const SizedBox(height: 15),

          _sideItem(Icons.home_outlined, "Home", 0),
          _sideItem(Icons.folder_outlined, "Local", 1),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _sideItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight:
                    isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}