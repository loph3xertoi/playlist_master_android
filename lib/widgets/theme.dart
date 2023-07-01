import 'package:flutter/material.dart';

enum MyThemeKeys { light, dark }

class MyThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    appBarTheme: AppBarTheme(
      color: Color(0xff171d49),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.grey,
      cursorColor: Color(0xff171d49),
      selectionHandleColor: Color(0xff005e91),
    ),
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        focusColor: Colors.blueAccent,
        splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey,
    brightness: Brightness.dark,
    highlightColor: Colors.white,
    backgroundColor: Colors.black54,
    textSelectionTheme: TextSelectionThemeData(selectionColor: Colors.grey),
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.light:
        return lightTheme;
      case MyThemeKeys.dark:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}
