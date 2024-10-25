import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/add_song_screen.dart';
import 'package:music/screens/all_sound_screen.dart';
import 'package:music/screens/auth/login_screen.dart';
import 'package:music/screens/auth/register_screen.dart';
import 'package:music/screens/components/audio_provider.dart';
import 'package:music/screens/display_screen.dart';
import 'package:music/screens/display_list_sound.dart';
import 'package:music/screens/liked_tracks_screen.dart';
import 'package:music/screens/menu/navigation_menu.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MusicApp());
}

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Theme Provider
        ChangeNotifierProvider(create: (context) => AudioProvider()), // Audio Provider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: LoginScreen.id,
            theme: themeProvider.themeData,  // Use theme data from the provider
            themeMode: ThemeMode.system,     // Adapt to system light/dark mode
            routes: {
              LoginScreen.id: (context) => const LoginScreen(),
              RegisterScreen.id: (context) => const RegisterScreen(),
              DisplayMusic.id: (context) => const ListSoundScreen(),
              ListSoundScreen.id: (context) => const ListSoundScreen(),
              NavigationMenu.id: (context) => const NavigationMenu(),
              LikedTracksScreen.id: (context) => const LikedTracksScreen(),
              AllSoundScreen.id: (context) => const AllSoundScreen(),
              AddNewSongScreen.id: (context) => const AddNewSongScreen(),
            },
          );
        },
      ),
    );
  }
}
