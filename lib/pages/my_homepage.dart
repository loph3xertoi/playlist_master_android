import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playlistmaster/http/my_http.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:playlistmaster/utils/my_toast.dart';
import 'package:playlistmaster/utils/theme_manager.dart';
import 'package:playlistmaster/widgets/bottom_player.dart';
import 'package:playlistmaster/widgets/floating_button/quick_action.dart';
import 'package:playlistmaster/widgets/floating_button/quick_action_menu.dart';
import 'package:playlistmaster/widgets/my_content_area.dart';
import 'package:playlistmaster/widgets/my_footer.dart';
import 'package:playlistmaster/widgets/my_searchbar.dart';
import 'package:playlistmaster/widgets/night_background.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  /// Current selected music app,
  /// 0 represents local music app, 1 represents QQ music,
  /// 2 represents netease music, 3 represents bilibili.
  var currentMusicApp = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build homepage');
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          width: MediaQuery.of(context).size.width * 0.75,
          child: NightBackground(),
        ),
        body: SafeArea(
          child: QuickActionMenu(
            backgroundColor: Colors.transparent,
            imageUri: 'assets/images/home_button.png',
            onTap: () async {
              appState.currentPlatform = 0;
              showDialog(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Test network image',
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium,
                    ),
                    // content: Image.network(MyAppState.defaultCoverImage),
                    content: Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () async {
                                await MyHttp.clearCache();
                                await AudioPlayer.clearAssetCache();
                                MyToast.showToast('Clear cache');
                              },
                              child: Text(
                                'Clear cache',
                                style: textTheme.labelMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                context: context,
              );
              print('homepage button $appState');
            },
            actions: [
              QuickAction(
                imageUri: 'assets/images/bilibili.png',
                onTap: () {
                  print('bilibili');
                },
              ),
              QuickAction(
                imageUri: 'assets/images/netease.png',
                onTap: () {
                  print('netease');
                },
              ),
              QuickAction(
                imageUri: 'assets/images/qqmusic.png',
                onTap: () {
                  appState.currentPlatform = 1;
                  print('qqmusic');
                },
              ),
            ],
            child: Column(
              children: [
                Container(
                  color: colorScheme.primary,
                  child: MySearchBar(
                    myScaffoldKey: _scaffoldKey,
                    notInHomepage: false,
                    inPlaylistDetailPage: false,
                  ),
                ),
                // SizedBox.expand(),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.homepageBg!,
                        stops: [0.0, 0.38, 0.6, 0.81, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                            child: MyContentArea(),
                          ),
                        ),
                        appState.isQueueEmpty ? Container() : BottomPlayer(),
                      ],
                    ),
                  ),
                ),
                MyFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
