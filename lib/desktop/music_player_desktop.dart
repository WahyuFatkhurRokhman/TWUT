// import 'package:flutter/material.dart';
// import 'package:music_player/models/constant/REPEAT_MODE.dart';
// import 'package:music_player/models/song.dart';
// import 'package:music_player/services/audio_manager.dart';

// class MusicPlayerDesktop extends StatefulWidget {
//   const MusicPlayerDesktop({super.key});

//   @override
//   State<MusicPlayerDesktop> createState() => _MusicPlayerDesktopState();
// }

// class _MusicPlayerDesktopState extends State<MusicPlayerDesktop> {
//   final audio = AudioManager();

//   @override
//   void initState() {
//     super.initState();
//     audio.init();
//   }

//   String formatDuration(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       body: Row(
//         children: [
//           // 🎚️ SIDEBAR
//           Container(
//             width: 220,
//             color: Colors.black,
//             child: const Center(
//               child: Text("🎧 Music Player",
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ),

//           // 🎼 MAIN
//           Expanded(
//             child: Column(
//               children: [
//                 // 🔹 SONG LIST
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: audio.queue.songs.length,
//                     itemBuilder: (context, index) {
//                       final song = audio.queue.songs[index];

//                       return ListTile(
//                         title: Text(song.title,
//                             style: const TextStyle(color: Colors.white)),
//                         subtitle: Text(song.artist,
//                             style: const TextStyle(color: Colors.grey)),
//                         onTap: () => audio.playAt(index),
//                       );
//                     },
//                   ),
//                 ),

//                 // 🔻 PLAYER BAR
//                 Container(
//                   height: 120,
//                   padding: const EdgeInsets.all(12),
//                   color: Colors.black,
//                   child: Column(
//                     children: [
//                       // 🎵 SONG INFO
//                       ValueListenableBuilder<Song?>(
//                         valueListenable: audio.currentSong,
//                         builder: (_, song, __) {
//                           return Text(
//                             song != null
//                                 ? "${song.title} - ${song.artist}"
//                                 : "No song playing",
//                             style: const TextStyle(color: Colors.white),
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 8),

//                       // ⏱️ PROGRESS BAR
//                       ValueListenableBuilder<Duration>(
//                         valueListenable: audio.position,
//                         builder: (_, pos, __) {
//                           return ValueListenableBuilder<Duration>(
//                             valueListenable: audio.duration,
//                             builder: (_, dur, __) {
//                               final max =
//                                   dur.inSeconds > 0 ? dur.inSeconds : 1;

//                               return Column(
//                                 children: [
//                                   Slider(
//                                     value: pos.inSeconds
//                                         .clamp(0, max)
//                                         .toDouble(),
//                                     max: max.toDouble(),
//                                     onChanged: (value) {
//                                       audio.seek(value.toInt());
//                                     },
//                                   ),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(formatDuration(pos),
//                                           style: const TextStyle(
//                                               color: Colors.white)),
//                                       Text(formatDuration(dur),
//                                           style: const TextStyle(
//                                               color: Colors.white)),
//                                     ],
//                                   )
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                       ),

//                       // 🎮 CONTROLS
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.skip_previous,
//                                 color: Colors.white),
//                             onPressed: audio.playPrevious,
//                           ),

//                           ValueListenableBuilder<bool>(
//                             valueListenable: audio.isPlaying,
//                             builder: (_, playing, __) {
//                               return IconButton(
//                                 icon: Icon(
//                                   playing
//                                       ? Icons.pause
//                                       : Icons.play_arrow,
//                                   color: Colors.white,
//                                   size: 32,
//                                 ),
//                                 onPressed: audio.toggle,
//                               );
//                             },
//                           ),

//                           IconButton(
//                             icon: const Icon(Icons.skip_next,
//                                 color: Colors.white),
//                             onPressed: audio.playNext,
//                           ),

//                           const SizedBox(width: 20),

//                           // 🔁 REPEAT
//                           ValueListenableBuilder<REPEAT_MODE>(
//                             valueListenable: audio.repeatMode,
//                             builder: (_, mode, __) {
//                               IconData icon;
//                               switch (mode) {
//                                 case REPEAT_MODE.ALL:
//                                   icon = Icons.repeat;
//                                   break;
//                                 case REPEAT_MODE.ONE:
//                                   icon = Icons.repeat_one;
//                                   break;
//                                 default:
//                                   icon = Icons.repeat;
//                               }

//                               return IconButton(
//                                 icon: Icon(icon,
//                                     color: mode == REPEAT_MODE.OFF
//                                         ? Colors.grey
//                                         : Colors.white),
//                                 onPressed: audio.toggleRepeatMode,
//                               );
//                             },
//                           ),

//                           // 🔊 VOLUME
//                           ValueListenableBuilder<double>(
//                             valueListenable: audio.volume,
//                             builder: (_, vol, __) {
//                               return SizedBox(
//                                 width: 120,
//                                 child: Slider(
//                                   value: vol,
//                                   onChanged: audio.setVolume,
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }