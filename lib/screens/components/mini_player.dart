import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/song.dart';
import '../display_screen.dart'; // Make sure this imports your DisplayMusic screen correctly
import 'audio_provider.dart'; // Import your AudioProvider class

class MiniPlayer extends StatelessWidget {
  final List<Song> songList; // Song list to pass
  final int currentIndex; // Current song index

  MiniPlayer({required this.songList, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return audioProvider.currentSong != null
        ? SizedBox(
          height: 65.0,
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display the current song's name

                InkWell(
                  onTap: () {
                    // Navigate to DisplayMusic screen and pass the song list and current index
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayMusic(
                          songList: songList, // Pass the song list
                          initialIndex: currentIndex, // Pass the current song index
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Image.network(
                        audioProvider.currentSong!.imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0 ,top: 2 ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 230,
                              // Giới hạn độ rộng của Text để điều chỉnh hiển thị tên bài hát
                              child: Text(
                                audioProvider.currentSong!.name,
                                style: const TextStyle(

                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                // Giới hạn tên bài hát chỉ hiển thị 1 dòng
                                overflow: TextOverflow.ellipsis, // Thêm dấu ba chấm nếu tên quá dài
                              ),
                            ),
                            Text(
                              audioProvider.currentSong!.author,
                              style: TextStyle( fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Consumer<AudioProvider>(
                      builder: (context, audioProvider, child) {
                        return IconButton(
                          onPressed: () async {
                            await audioProvider.toggleFavorite(audioProvider.currentSong!);
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: audioProvider.isFavorited ? Colors.red : Theme.of(context).colorScheme.inverseSurface,
                          ),
                          iconSize: 26,
                        );
                      },
                    ),

                    IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 26,
                      ),
                      onPressed: () {
                        // Toggle play/pause
                        if (audioProvider.isPlaying) {
                          audioProvider.pauseSong();
                        } else {
                          audioProvider.resumeSong();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        : SizedBox.shrink(); // If no song is playing, return an empty widget
  }
}
