import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/auth/login_screen.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:music/utils/dialog_permission.dart';
import 'package:provider/provider.dart';

import '../themes/colors.dart';
import '../utils/user_preferences.dart';
import 'components/audio_provider.dart';
import 'menu/navigation_menu.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userFuture = UserPreferences.getYourName();



  @override
  void initState() {
    super.initState();
    UserPreferences.isLogin();

  }

  void _logout()async  {
    // Xóa thông tin đăng nhập của người dùng
    UserPreferences.removeUser();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.stopSong();
    // Chuyển tới trang đăng nhập và xóa hết stack màn hình trước đó
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.id, (route) => false);
  }

  // Hàm hiển thị dialog xác nhận đăng xuất
  void _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xff333333),
            title: const Text('Confirm', style: TextStyle(color: Colors.white)),
            content: const Text('Do you want to logout?',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại nếu hủy
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                  _logout(); // Thực hiện đăng xuất
                },
                child:
                    const Text('Logout', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(

                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [

            Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                ),
                FutureBuilder(
                    future: userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Hi there!',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold));
                      } else {
                        return Text('Hi, ${snapshot.data}!',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold));
                      }
                    }),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationMenu(
                        indexScreen: 2), // Chuyển sang màn hình Liked Tracks
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Liked tracks', style: TextStyle(fontSize: 18)),
                  Icon(Icons.keyboard_arrow_right, size: 28),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationMenu(indexScreen: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Your upload', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8), // Khoảng cách giữa text và icon
                  Icon(Icons.keyboard_arrow_right, size: 28),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                DialogPermission().DialogChangeNameUser(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Change your name', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8), // Khoảng cách giữa text và icon
                  Icon(Icons.keyboard_arrow_right, size: 28),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                DialogPermission().DialogChangePassword(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Change password', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8), // Khoảng cách giữa text và icon
                  Icon(Icons.keyboard_arrow_right, size: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark mode',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  Switch(
                    value: themeProvider.isDarkMode,
                    // Connects to the variable
                    activeColor: Colors.white,
                    // Customize the active color
                    inactiveThumbColor: Colors.black,
                    // Customize the inactive thumb color
                    inactiveTrackColor: Colors.white,
                    activeTrackColor: Colors.grey,

                    onChanged: (value) {
                      setState(() {
                        themeProvider.toggleTheme(); // Change the theme
                        UserPreferences.saveStateDarkMode(
                            value); // Save the state
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Sign out',
                      style: TextStyle(color: Colors.redAccent, fontSize: 20)),
                  SizedBox(width: 8), // Khoảng cách giữa text và icon
                  Icon(Icons.keyboard_arrow_right, color: Colors.red, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
