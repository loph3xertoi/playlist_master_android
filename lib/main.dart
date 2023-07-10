import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/entities/video.dart';
import 'package:playlistmaster/pages/my_homepage.dart';
import 'package:playlistmaster/pages/playlist_detail.dart';
import 'package:playlistmaster/pages/search_page.dart';
import 'package:playlistmaster/pages/similar_songs.dart';
import 'package:playlistmaster/pages/song_detail.dart';
import 'package:playlistmaster/pages/song_player.dart';
import 'package:playlistmaster/pages/splash_screen.dart';
import 'package:playlistmaster/pages/video_player.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/states/my_navigation_button_state.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
import 'package:provider/provider.dart';

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
            '/home': (context) => MyHomePage(),
            '/search': (context) => SearchPage(),
            '/playlist_detail': (context) => PlaylistDetailPage(),
            '/song_player': (context) => SongPlayerPage(),
            // '/song_detail': (context) => SongDetailPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/song_detail') {
              final args = settings.arguments as Song;
              return MaterialPageRoute(
                builder: (context) => SongDetailPage(song: args),
              );
            }else if(settings.name == '/video_player'){
              final args = settings.arguments as Song;
              return MaterialPageRoute(
                builder: (context) => VideoPlayerPage(song: args),
              );
            }else if(settings.name == '/similar_songs'){
              final args = settings.arguments as Song;
              return MaterialPageRoute(
                builder: (context) => SimilarSongsPage(song: args),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
