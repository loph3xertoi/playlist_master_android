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

  final List<Color> _songPlayerPageBgColors = [
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
  List<Color>? _songPlayerPageBg;

  List<Color>? get homepageBg => _homepageBg;

  List<Color>? get detailLibraryPageBg => _detailLibraryPageBg;

  List<Color>? get songPlayerPageBg => _songPlayerPageBg;

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
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Color(0xFF212121),
      selectionColor: Colors.black26,
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
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.amber,
      selectionColor: Colors.amber.withOpacity(0.5),
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
        _songPlayerPageBg = _songPlayerPageBgColors;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        _homepageBg = _darkHomepageBgColors;
        _detailLibraryPageBg = _darkPlaylistDetailPageBgColors;
        _songPlayerPageBg = _darkSongPlayerPageBgColors;
      }
      notifyListeners();
    });
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _homepageBg = _homepageBgColors;
    _detailLibraryPageBg = _playlistDetailPageBgColors;
    _songPlayerPageBg = _songPlayerPageBgColors;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _homepageBg = _darkHomepageBgColors;
    _detailLibraryPageBg = _darkPlaylistDetailPageBgColors;
    _songPlayerPageBg = _darkSongPlayerPageBgColors;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6E5E00),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFEE264),
  onPrimaryContainer: Color(0xFF211B00),
  secondary: Color(0xFF665E40),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFEEE2BC),
  onSecondaryContainer: Color(0xFF211B04),
  tertiary: Color(0xFF43664F),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC5ECCE),
  onTertiaryContainer: Color(0xFF002110),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF1D1B16),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1D1B16),
  surfaceVariant: Color(0xFFE9E2D0),
  onSurfaceVariant: Color(0xFF4B4739),
  outline: Color(0xFF7C7767),
  onInverseSurface: Color(0xFFF6F0E7),
  inverseSurface: Color(0xFF32302A),
  inversePrimary: Color(0xFFE0C64B),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF6E5E00),
  outlineVariant: Color(0xFFCDC6B4),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFE0C64B),
  onPrimary: Color(0xFF393000),
  primaryContainer: Color(0xFF534600),
  onPrimaryContainer: Color(0xFFFEE264),
  secondary: Color(0xFFD1C6A1),
  onSecondary: Color(0xFF363016),
  secondaryContainer: Color(0xFF4E472A),
  onSecondaryContainer: Color(0xFFEEE2BC),
  tertiary: Color(0xFFA9D0B3),
  onTertiary: Color(0xFF143723),
  tertiaryContainer: Color(0xFF2B4E38),
  onTertiaryContainer: Color(0xFFC5ECCE),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1D1B16),
  onBackground: Color(0xFFE7E2D9),
  surface: Color(0xFF1D1B16),
  onSurface: Color(0xFFE7E2D9),
  surfaceVariant: Color(0xFF4B4739),
  onSurfaceVariant: Color(0xFFCDC6B4),
  outline: Color(0xFF969080),
  onInverseSurface: Color(0xFF1D1B16),
  inverseSurface: Color(0xFFE7E2D9),
  inversePrimary: Color(0xFF6E5E00),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFE0C64B),
  outlineVariant: Color(0xFF4B4739),
  scrim: Color(0xFF000000),
);
