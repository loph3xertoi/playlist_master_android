import 'package:flutter/material.dart';
import 'package:playlistmaster/pages/my_homepage.dart';
import 'package:playlistmaster/pages/playlist_detail.dart';
import 'package:playlistmaster/pages/search_page.dart';
import 'package:playlistmaster/pages/song_player.dart';
import 'package:playlistmaster/pages/splash_screen.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/states/my_navigation_button_state.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyNavigationButtonState>(
          create: (_) => MyNavigationButtonState(),
        ),
        ChangeNotifierProvider<MySearchState>(
          create: (_) => MySearchState(),
        ),
        ChangeNotifierProvider<MyAppState>(
          create: (_) => MyAppState(),
        ),
      ],
      child: MaterialApp(
        title: 'Playlist Master',
        theme: ThemeData(
          useMaterial3: true,
          // colorScheme: Colors.white,
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        initialRoute: '/splashscreen',
        routes: {
          '/splashscreen': (context) => SplashScreen(),
          '/': (context) => MyHomePage(),
          '/search': (context) => SearchPage(),
          '/playlist_detail': (context) => PlaylistDetailPage(),
          '/song_player': (context) => SongPlayerPage(),
        },
        // home: SplashScreen(),
      ),
    );
  }
}
