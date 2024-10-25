import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.white, // Màu nền cho AppBar
    iconTheme: IconThemeData(color: Colors.white), // Màu của icon trong AppBar
    titleTextStyle: TextStyle(color: Colors.black), // Màu chữ tiêu đề
  ),

  scaffoldBackgroundColor: Colors.grey[50], // Màu nền chính của ứng dụng

  textTheme: TextTheme(
    bodyMedium : TextStyle(color: Colors.black),
  ),



  iconTheme: IconThemeData(
    color: Colors.black,
  ),

  colorScheme: ColorScheme.light(
    background: Colors.grey[50],
    primary: Colors.black,
    secondary: Colors.white,
    outline: Colors.black54,

    inversePrimary: Colors.black54,
    inverseSurface: Colors.grey,
  ),
);