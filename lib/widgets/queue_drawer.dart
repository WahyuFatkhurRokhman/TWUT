import 'package:flutter/material.dart';
import 'package:music_player/models/constant/PLAYBACK_SOURCE.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/play_queue.dart';
import 'package:music_player/utils/navigation_utils.dart';
import 'package:music_player/utils/snackbar_util.dart';
import 'queue_list_tile.dart';

class QueueDrawer extends StatefulWidget {
  const QueueDrawer({super.key});

  @override
  State<QueueDrawer> createState() => _QueueDrawerState();
}

class _QueueDrawerState extends State<QueueDrawer> {
  final AudioManager _audio = AudioManager();
  late final PlayQueue _queue = _audio.queue;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  void _scrollToActive() {
    final current = _queue.currentIndex.value;
    if (current < 0 || !_scrollController.hasClients) return;

    const itemHeight = 72.0;
    final offset = (current * itemHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onRemove(BuildContext context, int index) async {
    final medias = _queue.queue.value;
    if (index < 0 || index >= medias.length) return;

    final media = medias[index];
    final isCurrent = index == _queue.currentIndex.value;
    final isLastSong = medias.length == 1;

    if (isLastSong) {
      await _audio.stopAndClearCurrent();
      if (context.mounted) {
        NavigationUtil.pop(context);
      }
    } else if (isCurrent) {
      await _audio.playNext();
    }

    _queue.removeAt(index);

    if (context.mounted) {
      SnackbarUtil.showSuccess(
        context,
        message: '${media.title} dihapus dari antrian.',
      );
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Antrian?'),
        content: const Text('Ini akan menghentikan musik dan menghapus daftar putar lokal.'),
        actions: [
          TextButton(
            onPressed: () => NavigationUtil.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              NavigationUtil.pop(context); // Tutup dialog

              _queue.clear();
              await _audio.stopAndClearCurrent();

              if (context.mounted) {
                // Tutup drawer
                NavigationUtil.pop(context);
                
                SnackbarUtil.showSuccess(
                  context,
                  message: 'Antrian berhasil dikosongkan',
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Antrian Lokal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    tooltip: 'Kosongkan antrian',
                    onPressed: () => _confirmClear(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ValueListenableBuilder<List<NowPlayingMedia>>(
                valueListenable: _queue.queue,
                builder: (_, medias, _) {
                  if (medias.isEmpty) {
                    return const Center(
                      child: Text('Antrian kosong', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ValueListenableBuilder<int>(
                    valueListenable: _queue.currentIndex,
                    builder: (_, currentIndex, _) {
                      return ReorderableListView.builder(
                        scrollController: _scrollController,
                        buildDefaultDragHandles: false,
                        itemCount: medias.length,
                        onReorder: _queue.reorder,
                        itemBuilder: (context, index) {
                          final media = medias[index];
                          final isActive = index == currentIndex && _audio.activeSource.value == PlaybackSource.local;

                          return Container(
                            key: ValueKey('${media.sourceId}_$index'),
                            child: QueueListTile(
                              media: media,
                              isActive: isActive,
                              onTap: () => _audio.playAt(index),
                              onRemove: () => _onRemove(context, index),
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle, color: Colors.grey),
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
