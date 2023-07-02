import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:playlistmaster/pages/my_homepage.dart';
import 'package:playlistmaster/pages/playlist_detail.dart';
import 'package:playlistmaster/pages/search_page.dart';
import 'package:playlistmaster/pages/song_player.dart';
import 'package:playlistmaster/pages/splash_screen.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/states/my_navigation_button_state.dart';
import 'package:playlistmaster/states/my_search_state.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.daw.playlistmaster.channel',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
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
        // darkTheme: ThemeData.dark(),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        // theme: MyThemes.darkTheme,
        initialRoute: '/splashscreen',
        routes: {
          '/splashscreen': (context) => SplashScreen(),
          '/home': (context) => MyHomePage(),
          '/search': (context) => SearchPage(),
          '/playlist_detail': (context) => PlaylistDetailPage(),
          '/song_player': (context) => SongPlayerPage(),
          // '/song_player': (context) {
          //   final args = ModalRoute.of(context)!.settings.arguments
          //       as Map<String, dynamic>;
          //   return SongPlayerPage(
          //     // isPlaying: args['isPlaying'],
          //   );
          // },
        },
        // onGenerateRoute: (settings) {
        //   switch (settings.name) {
        //     case '/search':
        //       return PageTransition(
        //         child: SearchPage(),
        //         type: PageTransitionType.fade,
        //         settings: settings,
        //         reverseDuration: Duration(seconds: 1),
        //       );
        //     case '/playlist_detail':
        //       return PageTransition(
        //         child: PlaylistDetailPage(),
        //         type: PageTransitionType.topToBottomJoined,
        //         childCurrent: this,
        //         settings: settings,
        //         reverseDuration: Duration(seconds: 1),
        //       );
        //     case '/song_player':
        //       return PageTransition(
        //         child: SongPlayerPage(),
        //         type: PageTransitionType.topToBottomJoined,
        //         childCurrent: this,
        //         settings: settings,
        //         reverseDuration: Duration(seconds: 1),
        //       );
        //     default:
        //       return null;
        //   }
        // },
        // home: SplashScreen(),
      ),
    );
  }
}
