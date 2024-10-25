import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.black, // Màu nền cho AppBar
    iconTheme: IconThemeData(color: Colors.white), // Màu của icon trong AppBar
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Màu chữ tiêu đề
  ),
  scaffoldBackgroundColor: Colors.black54, // Màu nền chính của ứng dụng

  textTheme: TextTheme(
    bodyMedium : TextStyle(color: Colors.white),
  ),

  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor:  Color(0xff121212),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
  ),

  colorScheme: ColorScheme.dark(
    background: Colors.grey[900],
    primary:Colors.white,
    secondary: Colors.black54,
    inversePrimary: Colors.black54,
    outline: Colors.grey,
    inverseSurface: Colors.white,
  ),
);