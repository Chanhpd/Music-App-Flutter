import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../model/song.dart';
import '../../utils/user_preferences.dart';

class AudioProvider with ChangeNotifier {

  final AudioPlayer _audioPlayer = AudioPlayer();
   List<Song> _songList = [];
  Song? _currentSong;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = 0;
  bool isFavorited = false; // Manage favorite state

  bool _isRepeating = false; // Manage repeat state

  AudioProvider() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeating) {
        playSong(_currentSong);
        print('Repeating $isRepeating');
      } else {
        nextSong();
      }
    });
  }

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  Song? get currentSong => _currentSong;
  Duration get duration => _duration;
  Duration get position => _position;
  int get currentIndex => _currentIndex;
  List<Song> get songList => _songList;
  bool get isRepeating => _isRepeating;



  // Set song list
  void setSongList(List<Song> songs) {
    _songList = songs;
    notifyListeners();
  }

  // Play a song
  void playSong(Song? song) async {
    // reset the state of the position
    _position = Duration.zero;
    notifyListeners();

    if (song == null) return; // Add null check
    _currentSong = song;
    await _audioPlayer.play(UrlSource(song.mp3Url));
    isPlaying = true;




    notifyListeners();

  }

  // Pause the current song
  void pauseSong() async {
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  // Resume the current song
  void resumeSong() async {
    await _audioPlayer.resume();
    isPlaying = true;
    notifyListeners();
  }

  // Toggle between play and pause
  void togglePlayPause() {
    if (isPlaying) {
      pauseSong();
    } else {
      resumeSong();
    }
  }

  // Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    _position = position;
    notifyListeners();
  }

  // Play the next song
  void nextSong() {
    _position = Duration.zero;
    notifyListeners(); // This ensures the Slider UI resets
    if (_songList.isEmpty) return; // Add null check
    if (_currentIndex < _songList.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Loop back to the first song
    }
    playSong(_songList[_currentIndex]);
    _currentSong = _songList[_currentIndex];
    notifyListeners();
  }

  // Play the previous song
  void previousSong() {
    _position = Duration.zero;
    notifyListeners(); // This ensures the Slider UI resets

    if (_songList.isEmpty) return; // Add null check
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _songList.length - 1; // Go to the last song
    }
    playSong(_songList[_currentIndex]);
    _currentSong = _songList[_currentIndex];
    notifyListeners();
  }

  // Stop the song
  void stopSong() async {
    await _audioPlayer.stop();
    isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  // Method to toggle favorite
  Future<void> toggleFavorite(Song song) async {
    final userId = await UserPreferences.getUserID();
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final songId = song.id;

    if (snapshot.exists) {
      List<dynamic> favoriteSongs = snapshot.data()?['favoriteSongs'] ?? [];

      if (favoriteSongs.contains(songId)) {
        favoriteSongs.remove(songId); // Remove song from favorites
        isFavorited = false;
      } else {
        favoriteSongs.add(songId); // Add song to favorites
        isFavorited = true;
      }
      // Update Firestore
      await userRef.update({'favoriteSongs': favoriteSongs});
      notifyListeners(); // Notify listeners to update UI
    }
  }

  // Method to check if a song is favorited
  Future<void> checkFavorite(Song song) async {
    final userId = await UserPreferences.getUserID();
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final songId = song.id;

    if (snapshot.exists) {
      List<dynamic> favoriteSongs = snapshot.data()?['favoriteSongs'] ?? [];

      if (favoriteSongs.contains(songId)) {
        isFavorited = true;
      } else {
        isFavorited = false;
      }
      notifyListeners(); // Notify listeners to update UI
    }
  }

  //shuffleSongs
  void shuffleSongs() {
    _songList.shuffle();
    playSong(_songList[_currentIndex]);
    notifyListeners();
  }

  // repeatSong
  void repeatSong() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }
}
