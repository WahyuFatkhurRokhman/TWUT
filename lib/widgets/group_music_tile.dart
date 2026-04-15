import 'package:flutter/material.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/folder_group.dart';
import 'package:music_player/models/album_group.dart';
import 'package:music_player/models/artist_group.dart';

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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔥 ICON 50x50 FIX 1:1
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getIconColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLeadingIcon(),
                  color: _getIconColor(),
                  size: 26,
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: 100,
                child: Text(
                  groupMusic.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '${groupMusic.songCount} Lagu',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}