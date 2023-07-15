import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'entities/basic/basic_song.dart';
import 'entities/basic/basic_video.dart';
import 'pages/detail_library_page.dart';
import 'pages/detail_song_page.dart';
import 'pages/home_page.dart';
import 'pages/related_videos_page.dart';
import 'pages/search_page.dart';
import 'pages/similar_songs_page.dart';
import 'pages/song_player_page.dart';
import 'pages/splash_screen.dart';
import 'pages/video_player_page.dart';
import 'states/app_state.dart';
import 'states/my_navigation_button_state.dart';
import 'states/my_search_state.dart';
import 'utils/theme_manager.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.daw.playlistmaster.channel',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: MyApp(),
  ));
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
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
          // themeMode: ThemeMode.system,
          theme: theme.getTheme(),
          title: 'Playlist Master',
          // theme: ThemeData(
          //   useMaterial3: true,
          //   colorSchemeSeed: Colors.green,
          // ),
          initialRoute: '/splashscreen',
          routes: {
            '/splashscreen': (context) => SplashScreen(),
            '/home_page': (context) => HomePage(),
            '/search_page': (context) => SearchPage(),
            '/detail_library_page': (context) => DetailLibraryPage(),
            '/song_player_page': (context) => SongPlayerPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail_song_page') {
              final args = settings.arguments as BasicSong;
              return MaterialPageRoute(
                builder: (context) => DetailSongPage(song: args),
              );
            } else if (settings.name == '/video_player_page') {
              final args = settings.arguments as BasicVideo;
              return MaterialPageRoute(
                builder: (context) => VideoPlayerPage(video: args),
              );
            } else if (settings.name == '/similar_songs_page') {
              final args = settings.arguments as BasicSong;
              return MaterialPageRoute(
                builder: (context) => SimilarSongsPage(song: args),
              );
            } else if (settings.name == '/related_videos_page') {
              final args = settings.arguments as BasicSong;
              return MaterialPageRoute(
                builder: (context) => RelatedVideosPage(song: args),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
