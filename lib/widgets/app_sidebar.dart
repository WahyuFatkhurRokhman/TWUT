import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final bool isMobile;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Drawer(
        backgroundColor: AppColors.card,
        child: _buildContent(),
      );
    }
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      color: AppColors.card,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Row(
          children: [
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
        const SizedBox(height: 15),
        _sideItem(Icons.home_outlined, "Home", 0),
        _sideItem(Icons.folder_outlined, "Library", 1),
        _sideItem(Icons.smart_display_outlined, "Youtube", 2),
        _sideItem(Icons.history_outlined, "History", 3),
        const Spacer(),
      ],
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
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
