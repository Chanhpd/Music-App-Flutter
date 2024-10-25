import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/song.dart';
import 'components/audio_provider.dart';

class DisplayMusic extends StatefulWidget {
  static const String id = 'display_music';

  final List<Song> songList; // Danh sách bài hát
  final int initialIndex; // Vị trí của bài hát hiện tại

  const DisplayMusic(
      {super.key, required this.songList, required this.initialIndex});

  @override
  State<DisplayMusic> createState() => _DisplayMusicState();
}

class _DisplayMusicState extends State<DisplayMusic>
    with SingleTickerProviderStateMixin {

  late AudioProvider audioProvider; // Khởi tạo AudioPlayer

  @override
  void initState() {
    super.initState();

    audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Start playing the selected song
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.setSongList(
          widget.songList); // Set the list of songs in the provider
      audioProvider.playSong(widget
          .songList[widget.initialIndex]); // Start playing the initial song
      audioProvider.checkFavorite(widget.songList[widget.initialIndex]);
    });
  }

  @override
  void dispose() {
    // audioProvider.dispose(); // Hủy AudioPlayer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            // Navigate back and show the mini-player
            Navigator.pop(context);
            return false; // Prevent the default back button behavior
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(
                'P L A Y I N G',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              iconTheme: IconThemeData(
                color: Theme.of(context)
                    .colorScheme
                    .primary, // Đặt màu icon (bao gồm nút "Back")
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(4, 4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              audioProvider.currentSong!.imageUrl,
                              width: double.infinity,
                              // height = width để hiển thị hình vuông
                              height: MediaQuery.of(context).size.width - 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  audioProvider.currentSong!.name,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    audioProvider.currentSong!.author,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Consumer<AudioProvider>(
                                        builder: (context, audioProvider, child) {
                                          return IconButton(
                                            onPressed: () async {
                                              // Toggle the favorite status of the current song
                                              await audioProvider.toggleFavorite(widget.songList[widget.initialIndex]);
                                            },
                                            icon: Icon(
                                              Icons.favorite,
                                              color: audioProvider.isFavorited ? Colors.red : Colors.grey,
                                            ),
                                            iconSize: 24,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(audioProvider.position),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16),
                        ),

                        IconButton(
                          onPressed: () {
                            audioProvider.shuffleSongs();
                          },
                          icon: const Icon(Icons.shuffle),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 28,
                        ),
                        IconButton(
                          onPressed: () {
                            audioProvider.repeatSong();
                           print( audioProvider.isRepeating);
                          },
                          icon: const Icon(Icons.repeat),
                          color: audioProvider.isRepeating ? Colors.blue : Theme.of(context).colorScheme.primary,
                          iconSize: 28,
                        ),

                        // Thời gian hiện tại
                        Text(
                          formatDuration(audioProvider.duration),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16),
                        ),
                        // Thời lượng nhạc
                      ],
                    ),
                  ),
                  // Slider on top of the waveform
                  SliderTheme(
                    data: SliderThemeData(
                        thumbColor: Colors.blue,
                        overlayColor: Colors.transparent,
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.grey[500],
                        trackHeight: 3,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 8)),
                    child: Slider(
                      min: 0,
                      max: (audioProvider.duration.inMilliseconds > 0)
                          ? audioProvider.duration.inMilliseconds.toDouble()
                          : 1.0,
                      value: (audioProvider.position.inMilliseconds <= audioProvider.duration.inMilliseconds)
                          ? audioProvider.position.inMilliseconds.toDouble()
                          : 0,
                      onChanged: (value) async {
                        final position = Duration(milliseconds: value.toInt());
                        await audioProvider.seek(position); // Adjust audio position
                         audioProvider.resumeSong(); // Resume the audio
                      },
                    ),
                  ),

                  // Thanh tiến trình
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: audioProvider.previousSong,
                        icon: const Icon(Icons.skip_previous),
                        color: Theme.of(context).colorScheme.primary,
                        iconSize: 48,
                      ),
                      IconButton(
                        icon: Icon(audioProvider.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled),
                        iconSize: 64,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: audioProvider
                            .togglePlayPause, // Khi nhấn sẽ phát/dừng nhạc
                      ),
                      IconButton(
                        onPressed: audioProvider.nextSong,
                        icon: const Icon(Icons.skip_next),
                        color: Theme.of(context).colorScheme.primary,
                        iconSize: 48,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Định dạng thời gian (mm:ss)
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}
