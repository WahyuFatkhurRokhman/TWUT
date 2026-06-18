import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';
import 'package:music_player/utils/group_music_helper.dart';

class GroupMusicTile extends StatelessWidget {
  final GroupMusic groupMusic;
  final VoidCallback onTap;

  const GroupMusicTile({
    super.key,
    required this.groupMusic,
    required this.onTap,
  });

  IconData _getLeadingIcon() {
    if (groupMusic is FolderGroup) return Icons.folder;
    if (groupMusic is AlbumGroup) return Icons.album;
    if (groupMusic is ArtistGroup) return Icons.person;
    return Icons.library_music; // Default untuk AlphabetGroup atau lainnya
  }

  Color _getIconColor() {
    if (groupMusic is FolderGroup) return Colors.amber;
    if (groupMusic is AlbumGroup) return Colors.blue;
    if (groupMusic is ArtistGroup) return Colors.green;
    return Colors.purple;
  }

@override
Widget build(BuildContext context) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        // 🌌 Gradient gelap elegan
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // 🎵 ICON BOX (kiri)
          Container(
            width: 70,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Icon(
              _getLeadingIcon(),
              color: _getIconColor(),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // 📀 TEXT AREA
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGroupTitle(groupMusic),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  '${groupMusic.songCount} Lagu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}