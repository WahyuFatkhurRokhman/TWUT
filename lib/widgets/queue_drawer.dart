import 'package:flutter/material.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/services/audio_manager.dart';
import 'package:music_player/services/play_queue.dart';
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

      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (isCurrent) {
      await _audio.playNext();
    }

    _queue.removeAt(index);

    if (context.mounted) {
      SnackbarUtil.showSuccess(
        context,
        message: '${media.title} berhasil dihapus dari antrian.',
      );
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Menutup antrian?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              _queue.clear();
              await _audio.stopAndClearCurrent();

              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              if (context.mounted) {
                SnackbarUtil.showSuccess(
                  context,
                  message: 'Berhasil menutup antrian',
                );
              }
            },
            child: const Text('Hapus'),
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
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Putar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus antrian',
                    onPressed: () => _confirmClear(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Queue list
            Expanded(
              child: ValueListenableBuilder<List<NowPlayingMedia>>(
                valueListenable: _queue.queue,
                builder: (_, medias, __) {
                  if (medias.isEmpty) {
                    return const Center(
                      child: Text(
                        'Antrian kosong',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ValueListenableBuilder<int>(
                    valueListenable: _queue.currentIndex,
                    builder: (_, currentIndex, __) {
                      WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToActive(),
                      );

                      return ReorderableListView.builder(
                        scrollController: _scrollController,
                        buildDefaultDragHandles: false,
                        itemCount: medias.length,
                        onReorder: _queue.reorder,
                        itemBuilder: (context, index) {
                          final media = medias[index];
                          final isActive = index == currentIndex;

                          return Container(
                            key: ValueKey('${media.sourceId}_$index'),
                            child: QueueListTile(
                              media: media,
                              isActive: isActive,
                              onTap: () => _audio.playAt(index),
                              onRemove: () => _onRemove(context, index),
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