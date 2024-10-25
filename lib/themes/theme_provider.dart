import 'package:flutter/material.dart';

import 'dark_mode.dart';
import 'light_mode.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set isDarkMode(bool value) { //
    _themeData = value ? darkMode : lightMode;
    notifyListeners();
  }
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if(_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    // in ra tên theme hiện tại

    notifyListeners();
  }
}