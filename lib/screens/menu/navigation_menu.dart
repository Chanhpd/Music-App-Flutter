import 'package:flutter/material.dart';

import 'package:music/screens/display_list_sound.dart';
import 'package:music/screens/display_your_sound.dart';
import 'package:music/screens/liked_tracks_screen.dart';
import 'package:music/screens/profile_screen.dart';
import 'package:music/screens/search_screen.dart';
import 'package:provider/provider.dart';

import '../../model/song.dart';
import '../../themes/colors.dart';
import '../../themes/theme_provider.dart';
import '../../utils/user_preferences.dart';
import '../components/audio_provider.dart';
import '../components/mini_player.dart';

class NavigationMenu extends StatefulWidget {
  static const String id = 'navigation_menu';
  final int indexScreen;

  const NavigationMenu({super.key, this.indexScreen = 0});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0; // Index của trang hiện tại

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserPreferences.isLogin();

    _currentIndex = widget.indexScreen;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? isDarkMode = await UserPreferences.getSavedDarkMode();
      if (isDarkMode != null) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        themeProvider.isDarkMode = isDarkMode;
      }
    });

  }

  final List<Widget> _screens = [
    ListSoundScreen(),
    SearchScreen(),
    LikedTracksScreen(),
    DisplayYourSound(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final List<Song> songList = audioProvider.songList;
    final int currentIndex = audioProvider.currentSong != null
        ? songList.indexOf(audioProvider.currentSong!)
        : -1; // Return -1 if currentSong is null

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        children: [
          Padding(
            padding: songList.isNotEmpty && currentIndex != -1
                ? const EdgeInsets.only(bottom: 65)
                : EdgeInsets.zero, // Không padding khi MiniPlayer không tồn tại
            child: _screens[_currentIndex], // Nội dung chính được đẩy lên để không bị che
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(
              songList: songList,
              currentIndex: currentIndex,
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }
  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          backgroundColor: AppColors.backgroundNavigation,
          icon: const Icon(Icons.home, color: Colors.white),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          backgroundColor: AppColors.backgroundNavigation,
          icon: const Icon(Icons.search, color: Colors.white),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          backgroundColor: AppColors.backgroundNavigation,
          icon: const Icon(Icons.favorite, color: Colors.white),
          label: 'Liked Tracks',
        ),
        BottomNavigationBarItem(
          backgroundColor: AppColors.backgroundNavigation,
          icon: const Icon(Icons.library_music, color: Colors.white),
          label: 'Your Library',
        ),
        BottomNavigationBarItem(
          backgroundColor: AppColors.backgroundNavigation,
          icon: const Icon(Icons.person, color: Colors.white),
          label: 'Profile',
        ),
      ],
    );
  }

}
