import 'package:flutter/material.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/snackbar_util.dart';
import '../services/play_queue.dart';
import 'queue_list_tile.dart';

class QueueDrawer extends StatelessWidget {
  final AudioManager audio = AudioManager();
  late final PlayQueue queue = audio.queue;

  QueueDrawer({super.key});

  void _onRemove(BuildContext context, index) async {
    final song = queue.songs[index];
    if(queue.currentSong == song){
      audio.playNext();
    }

    queue.removeAt(index);
    SnackbarUtil.showSuccess(context, message: '${song.title} berhasil dihapus dari antrian.');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Antrian",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<List>(
                valueListenable: queue.queue,
                builder: (_, songs, __) {
                  return ValueListenableBuilder<int>(
                    valueListenable: queue.currentIndex,
                    builder: (_, current, __) {
                      return ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: songs.length,
                        onReorder: queue.reorder,

                        itemBuilder: (context, index) {
                          final song = songs[index];

                          return ReorderableDragStartListener(
                            key: ValueKey('$index-${song.path}'),
                            index: index,

                            child: Container(
                              color: Colors.transparent,
                              child: QueueListTile(
                                song: song,
                                isActive: index == current,
                                onRemove: () => _onRemove(context, index),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}