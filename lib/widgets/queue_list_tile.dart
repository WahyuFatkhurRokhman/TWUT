import 'package:flutter/material.dart';
import '../models/song.dart';

class QueueListTile extends StatefulWidget {
  final Song song;
  final bool isActive;
  final VoidCallback? onRemove; // 🔥 callback hapus
  final VoidCallback? onTap;
  final Widget? dragHandle;

  const QueueListTile({
    super.key,
    required this.song,
    this.isActive = false,
    this.onRemove,
    this.onTap,
    this.dragHandle,
  });

  @override
  State<QueueListTile> createState() => _QueueListTileState();
}

class _QueueListTileState extends State<QueueListTile> {
  bool isHovering = false;
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => isDragging = true),
      onPointerUp: (_) => setState(() => isDragging = false),
      onPointerCancel: (_) => setState(() => isDragging = false),

      child: MouseRegion(
        cursor: isDragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,

        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() {
          isHovering = false;
          isDragging = false;
        }),

        child: Opacity(
          opacity: isDragging ? 0.6 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isHovering
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent,
              border: const Border(
                bottom: BorderSide(color: Colors.black12, width: 0.5),
              ),
            ),
            child: ListTile(
              onTap: widget.onTap,

              leading: widget.isActive
                  ? const Icon(Icons.equalizer, color: Colors.green)
                  : widget.dragHandle,

              title: Text(
                widget.song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              subtitle: Text(
                widget.song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'remove') {
                    widget.onRemove?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Hapus dari antrian'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
