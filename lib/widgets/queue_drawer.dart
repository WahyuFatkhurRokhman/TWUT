import 'package:flutter/material.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/utils/snackbar_util.dart';
import '../services/play_queue.dart';
import 'queue_list_tile.dart';

class QueueDrawer extends StatefulWidget {
  const QueueDrawer({super.key});

  @override
  State<QueueDrawer> createState() => _QueueDrawerState();
}

class _QueueDrawerState extends State<QueueDrawer> {
  final AudioManager audio = AudioManager();
  late final PlayQueue queue = audio.queue;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActive();
    });
  }

  void _scrollToActive() {
    final current = queue.currentIndex.value;

    if (current < 0 || !scrollController.hasClients) return;

    const itemHeight = 72.0; // sesuaikan jika tinggi tile berbeda
    final offset = current * itemHeight;

    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onRemove(BuildContext context, int index) async {
    final song = queue.songs[index];

    final isCurrent = queue.currentSong == song;
    final isLastSong = queue.songs.length == 1;

    if (isLastSong) {
      await audio.stopAndClearCurrent();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (isCurrent) {
      await audio.playNext();
    }

    queue.removeAt(index);

    SnackbarUtil.showSuccess(
      context,
      message: '${song.title} berhasil dihapus dari antrian.',
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Menutup antrian?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              queue.clear();
              await audio.stopAndClearCurrent();

              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              SnackbarUtil.showSuccess(
                context,
                message: "Berhasil menutup antrian",
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daftar Putar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _confirmClear(context);
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<List>(
                valueListenable: queue.queue,
                builder: (_, songs, __) {
                  return ValueListenableBuilder<int>(
                    valueListenable: queue.currentIndex,
                    builder: (_, current, __) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToActive();
                      });

                      return ReorderableListView.builder(
                        scrollController: scrollController,
                        buildDefaultDragHandles: false,
                        itemCount: songs.length,
                        onReorder: queue.reorder,
                        itemBuilder: (context, index) {
                          final song = songs[index];

                          return Container(
                            key: ValueKey(song.path),
                            child: QueueListTile(
                              song: song,
                              isActive: index == current,
                              onTap: () async {
                                await audio.playAt(index);
                              },
                              onRemove: () {
                                _onRemove(context, index);
                              },
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
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