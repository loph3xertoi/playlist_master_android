import 'dart:ui';

import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:log_export/log_export.dart';
import 'package:provider/provider.dart';

import 'entities/basic/basic_song.dart';
import 'entities/basic/basic_video.dart';
import 'firebase_options.dart';
import 'pages/detail_favlist_page.dart';
import 'pages/detail_library_page.dart';
import 'pages/detail_resource_page.dart';
import 'pages/detail_song_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page_new.dart';
import 'pages/related_videos_page.dart';
import 'pages/search_page.dart';
import 'pages/similar_songs_page.dart';
import 'pages/songs_player_page.dart';
import 'pages/splash_screen.dart';
import 'pages/video_player_page.dart';
import 'states/app_state.dart';
import 'states/my_navigation_button_state.dart';
import 'states/my_search_state.dart';
import 'utils/theme_manager.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  LogExport.init();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.daw.playlistmaster.channel',
    // androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
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
        builder: (context, theme, _) => BetterFeedback(
          // theme: FeedbackThemeData(
          //     feedbackSheetColor:
          //         theme.getTheme()?.colorScheme.primary ?? Colors.amber,
          //     bottomSheetDescriptionStyle:
          //         theme.getTheme()?.textTheme.labelMedium! ?? TextStyle()),
          child: MaterialApp(
            // themeMode: ThemeMode.system,
            builder: FToastBuilder(),
            navigatorKey: navigatorKey,
            theme: theme.getTheme(),
            title: 'Playlist Master',
            initialRoute: '/splashscreen',
            routes: {
              '/splashscreen': (context) => SplashScreen(),
              '/login_page': (context) => LoginScreen(),
              // '/login_page': (context) => LoginPage(),
              '/home_page': (context) => HomePage(),
              '/search_page': (context) => SearchPage(),
              '/detail_library_page': (context) => DetailLibraryPage(),
              '/detail_favlist_page': (context) => DetailFavListPage(),
              '/songs_player_page': (context) => SongsPlayerPage(),
              '/detail_resource_page': (context) => DetailResourcePage(),
              // '/resources_player_page': (context) => ResourcesPlayerPage(),
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
      ),
    );
  }
}
