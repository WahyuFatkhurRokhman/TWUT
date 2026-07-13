import 'package:flutter/material.dart';
import 'package:music_player/config/app_colors.dart';

class AppSidebar extends StatefulWidget {
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
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return Drawer(
        backgroundColor: AppColors.card,
        child: _buildContent(),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 280 : 100,
      // Increased expanded width to 280
      padding: const EdgeInsets.all(16),
      color: AppColors.card,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: _isExpanded
              ? Row(
            children: [
              Image.asset('assets/images/app_icon.png', width: 32, height: 32),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Musicplayer",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                    Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () => setState(() => _isExpanded = false),
              ),
            ],
          )
              : Center(
            child: IconButton(
              icon: const Icon(
                  Icons.chevron_right, color: AppColors.textSecondary),
              onPressed: () => setState(() => _isExpanded = true),
            ),
          ),
        ),

        const SizedBox(height: 15),


        const SizedBox(height: 15),
        _sideItem(Icons.home_outlined, "Home", 0),
        _sideItem(Icons.folder_outlined, "Local", 1),
        _sideItem(Icons.playlist_play_outlined, "Playlists", 4),
        _sideItem(Icons.smart_display_outlined, "Youtube", 2),
        _sideItem(Icons.history_outlined, "History", 3),
        const Spacer(),
      ],
    );
  }


  Widget _sideItem(IconData icon, String label, int index) {
    final isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onSelect(index),
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.accent.withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppColors.accent : AppColors
                      .textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
