import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/login_screen.dart';

class UserPreferences  {
  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';

  static Future<void> saveUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // lấy userID
  static Future<String> getUserID() async {
    String userID = '';
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (user.docs.isNotEmpty) {
      userID = user.docs[0].id;
    }
    return userID;
  }

  static Future<String> getYourName() async {
    String name = '';
    final prefs = await SharedPreferences.getInstance();
    final FirebaseFirestore _store = FirebaseFirestore.instance;

    final username = prefs.getString(_keyUsername);
    final user = await _store
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (user.docs.isNotEmpty) {
      name = user.docs[0]['name'];
    }
    return name;
  }

  // get Name via userID
  static Future<String> getName(String userID) async {
    String name = '';
    final FirebaseFirestore _store = FirebaseFirestore.instance;
    final user = await _store.collection('users').doc(userID).get();
    if (user.exists) {
      name = user['name'];
    }
    return name;
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
  }
  // hàm isLogin để kiểm tra xem người dùng đã đăng nhập hay chưa
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUsername) && prefs.containsKey(_keyPassword);
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    // Chờ hàm isLoginFuture hoàn thành
    var isLogin = await UserPreferences.isLogin();
    if (!isLogin) {
      Navigator.pushNamed(context, LoginScreen.id);
    }
  }
  static void saveStateDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    print('isDarkMode: $isDarkMode');
  }
  static Future<bool?> getSavedDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode');
  }
}