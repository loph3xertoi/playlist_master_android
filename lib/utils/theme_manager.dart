import 'package:flutter/material.dart';

import 'storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final List<Color> _homepageBgColors = [
    Color(0xFF75B6F8),
    Color(0xFFD3EAFF),
    Color(0xFFF1F8FF),
    Color(0xFFFFFFFF),
    Color(0xFFFFEED9),
  ];

  final List<Color> _playlistDetailPageBgColors = [
    Color(0xFF1B3142),
    Color(0xFF355467),
    Color(0xFF5E777A),
    Color(0xFFCE8B46),
  ];

  final List<Color> _playerPageBackgroundColors = [
    Color(0xFF011934),
    Color(0xFF092B47),
    Color(0xFF142B41),
    Color(0xFF393747),
  ];

  final List<Color> _darkHomepageBgColors = [
    Color(0xFF011934),
    Color(0xFF092B47),
    Color(0xFF142B41),
    Color(0xFF393747),
    Color(0xFF393747),
  ];

  final List<Color> _darkPlaylistDetailPageBgColors = [
    Color(0xFF011934),
    Color(0xFF092B47),
    Color(0xFF142B41),
    Color(0xFF393747),
  ];

  final List<Color> _darkSongPlayerPageBgColors = [
    Color(0xFF393747),
    Color(0xFF142B41),
    Color(0xFF092B47),
    Color(0xFF011934),
  ];

  List<Color>? _homepageBg;
  List<Color>? _detailLibraryPageBg;
  List<Color>? _playerPageBackground;

  List<Color>? get homepageBg => _homepageBg;

  List<Color>? get detailLibraryPageBg => _detailLibraryPageBg;

  List<Color>? get playerPageBackground => _playerPageBackground;

  final lightTheme = ThemeData(
    useMaterial3: true,
    // primaryColorDark: Colors.amber,
    // primaryColorLight: Colors.transparent,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.white,
      onPrimary: Color(0x42000000),
      secondary: Color(0xFFF0E6E9),
      onSecondary: Colors.black87,
      tertiary: const Color.fromARGB(181, 0, 0, 0),
      onTertiary: const Color.fromARGB(47, 0, 0, 0),
      background: Colors.white,
      primaryContainer: Colors.white,
      onPrimaryContainer: Color(0xFFF7F6F9),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Color(0x42000000),
      selectionColor: Colors.black26,
      selectionHandleColor: Color(0xFF212121),
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 12.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.black54,
      ),
      titleSmall: TextStyle(
        fontSize: 11.0,
        fontFamily: 'Roboto',
        color: Colors.black54,
      ),

      bodyLarge: TextStyle(
        fontSize: 13.0,
        fontFamily: 'Roboto',
        height: 1.2,
        color: Color(0xBF000000),
      ),
      bodyMedium: TextStyle(
        fontSize: 12.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        height: 1.2,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 11.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        height: 1.2,
        color: Color(0x42000000),
      ),
      // Popup button text.
      labelSmall: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.1,
        color: Colors.black,
      ),
      // Popup title.
      labelMedium: TextStyle(
        fontSize: 16.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.black,
      ),
      labelLarge: TextStyle(
        fontSize: 20.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.black,
      ),
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    // primaryColorDark: Colors.white,
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.white38,
    ),
    primaryColorLight: Color(0xFFF0E6E9),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Color(0xFF212121),
      onPrimary: Colors.white,
      secondary: Color(0xFF4E4E4E),
      onSecondary: Colors.white,
      tertiary: Colors.white,
      onTertiary: Colors.white38,
      background: Color(0xFF212121),
      primaryContainer: Colors.black,
      onPrimaryContainer: Colors.black26,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.amber.withOpacity(0.5),
      selectionHandleColor: Colors.amber,
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: 12.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 11.0,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 13.0,
        fontFamily: 'Roboto',
        color: Colors.white,
        height: 1.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 12.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        height: 1.2,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 11.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        height: 1.2,
        color: Colors.white,
      ),
      // Popup button text.
      labelSmall: TextStyle(
        fontSize: 14.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.1,
        color: Colors.white,
      ),
      // Popup title.
      labelMedium: TextStyle(
        fontSize: 16.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 20.0,
        fontFamily: 'Roboto',
        letterSpacing: 0.25,
        color: Colors.white,
      ),
    ),
  );

  ThemeData? _themeData;

  ThemeData? getTheme() => _themeData;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('Current theme mode: $value');
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        _homepageBg = _homepageBgColors;
        _detailLibraryPageBg = _playlistDetailPageBgColors;
        _playerPageBackground = _playerPageBackgroundColors;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        _homepageBg = _darkHomepageBgColors;
        _detailLibraryPageBg = _darkPlaylistDetailPageBgColors;
        _playerPageBackground = _darkSongPlayerPageBgColors;
      }
      notifyListeners();
    });
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _homepageBg = _homepageBgColors;
    _detailLibraryPageBg = _playlistDetailPageBgColors;
    _playerPageBackground = _playerPageBackgroundColors;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _homepageBg = _darkHomepageBgColors;
    _detailLibraryPageBg = _darkPlaylistDetailPageBgColors;
    _playerPageBackground = _darkSongPlayerPageBgColors;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }
}
