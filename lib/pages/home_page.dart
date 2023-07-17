import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fplayer/fplayer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import '../utils/theme_manager.dart';
import '../widgets/bottom_player.dart';
import '../widgets/floating_button/quick_action.dart';
import '../widgets/floating_button/quick_action_menu.dart';
import '../widgets/my_content_area.dart';
import '../widgets/my_footer.dart';
import '../widgets/my_searchbar.dart';
import '../widgets/night_background.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  /// Current selected music app,
  /// 0 represents local music app, 1 represents QQ music,
  /// 2 represents netease music, 3 represents bilibili.
  var currentMusicApp = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    resetRotation();
  }

  void resetRotation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    await FPlugin.setOrientationPortrait();
    // MyToast.showToast('Reset rotation');
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
              // appState.currentPlatform = 0;
              print(appState);
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
                                await SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.immersiveSticky,
                                    overlays: []);
                                await FPlugin.setOrientationPortrait();
                                MyToast.showToast('Reset rotation');
                              },
                              child: Text(
                                'Reset rotation',
                                style: textTheme.labelMedium,
                              ),
                            ),
                          ),
                        ),
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
                                var res = await appState.fetchSearchedSongs(
                                    '洛天依', appState.firstPageNo, appState.pageSize, appState.currentPlatform);
                                print(res);
                                MyToast.showToast('Search songs');
                              },
                              child: Text(
                                'Search songs',
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
                    inDetailLibraryPage: false,
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
                        appState.currentSong == null
                            ? Container()
                            : BottomPlayer(),
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
