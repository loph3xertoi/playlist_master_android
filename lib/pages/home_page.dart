import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fplayer/fplayer.dart';
import 'package:provider/provider.dart';

import '../config/user_info.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/basic_pms_user_info_dto.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/pms/pms_user.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/storage_manager.dart';
import '../utils/theme_manager.dart';
import '../widgets/add_third_app_cookie_form.dart';
import '../widgets/bottom_player.dart';
import '../widgets/confirm_popup.dart';
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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? _currentPlatform;

  // If the exit confirm dialog is shown, this will be true.
  bool _showExitDialog = false;

  BuildContext? exitDialogContext;

  @override
  void initState() {
    super.initState();
    // TODO: Check for updates.
    // AppUpdater.checkForUpdate();
    final state = Provider.of<MyAppState>(context, listen: false);
    _initUserInfo(state);
    if (!kIsWeb) {
      _resetRotation();
    }
  }

  // Initialize user info, email and phone.
  void _initUserInfo(MyAppState appState) async {
    BasicPMSUserInfoDTO? basicUser = await appState.getBasicInfoOfLoginUser();
    var user = await appState.fetchUser(0);
    if (user != null) {
      PMSUser pmsUser = user as PMSUser;
      setState(() {
        UserInfo.basicUser = basicUser;
        UserInfo.pmsUser = pmsUser;
      });
    } else {
      appState.logout();
      if (mounted) {
        return Navigator.of(context)
            .pushReplacementNamed('/login_page')
            .then((_) => false);
      }
      MyToast.showToast('Fail to get basic user info');
    }
  }

  void _resetRotation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    await FPlugin.setOrientationPortrait();
    // MyToast.showToast('Reset rotation');
  }

  @override
  Widget build(BuildContext context) {
    print('build homepage');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _currentPlatform = appState.currentPlatform;
    var screenSize = MediaQuery.of(context).size;
    const appcastURL = API.demoAppcastXml;
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          width: screenSize.width *
              (!kIsWeb && (Platform.isAndroid || Platform.isIOS) ? 0.75 : 0.5),
          child: NightBackground(),
        ),
        body: WillPopScope(
          onWillPop: () async {
            if (!_showExitDialog) {
              _showExitDialog = true;
              var exit = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    exitDialogContext = context;
                    return ShowConfirmDialog(
                      title: 'Do you want to exit?',
                      onConfirm: () =>
                          Navigator.of(exitDialogContext!).pop(true),
                    );
                  });
              if (exit != null) {
                return true;
              } else {
                _showExitDialog = false;
                return false;
              }
            } else {
              _showExitDialog = false;
              Navigator.of(exitDialogContext!).pop();
              return false;
            }
          },
          child: SafeArea(
            child: QuickActionMenu(
              backgroundColor: Colors.transparent,
              imageUri: 'assets/images/home_button.png',
              onTap: () async {
                print('homepage button $appState');
                MyToast.showToast('Switched to pms.');
                MyLogger.logger.i('Switched to pms.');
                if (_currentPlatform != 0) {
                  if (appState.songsPlayer != null) {
                    appState.disposeSongsPlayer();
                  }
                }
                appState.currentPlatform = 0;
                StorageManager.saveData(
                    'currentPlatform', appState.currentPlatform.toString());
                appState.refreshLibraries!(appState, false);
                if (appState.isUsingMockData) {
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
                            TextButton(
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
                                // await AudioPlayer.clearAssetCache();
                                MyToast.showToast('Clear local cache');
                              },
                              child: Text(
                                'Clear local cache',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () => throw Exception(),
                              child: Text(
                                'Throw Test Exception',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () async {
                                bool isWeb = kIsWeb;
                                if (!isWeb) {
                                  String platform = Platform.operatingSystem;
                                  print('Current platform is $platform');
                                  await SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.immersiveSticky,
                                      overlays: []);
                                  await FPlugin.setOrientationPortrait();
                                } else {
                                  print('Current platform is web');
                                }
                                MyToast.showToast('Reset rotation');
                              },
                              child: Text(
                                'Reset rotation',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () async {
                                String platformName;
                                dynamic searchMethod;
                                if (_currentPlatform == 0) {
                                  platformName = 'PMS';
                                } else if (_currentPlatform == 1) {
                                  platformName = 'QQ Music';
                                  searchMethod =
                                      appState.fetchSearchedSongs<QQMusicSong>(
                                          '洛天依', 1, 10, _currentPlatform!);
                                } else if (_currentPlatform == 2) {
                                  platformName = 'Netease Music';
                                  searchMethod =
                                      appState.fetchSearchedSongs<NCMSong>(
                                          '洛天依', 1, 10, _currentPlatform!);
                                } else if (_currentPlatform == 3) {
                                  platformName = 'BiliBili';
                                  searchMethod =
                                      appState.fetchSearchedSongs<BiliResource>(
                                          '洛天依', 1, 10, _currentPlatform!);
                                } else {
                                  throw Exception('Invalid platform');
                                }
                                MyToast.showToast('Searching in $platformName');
                                var res = await searchMethod;
                                print(res);
                              },
                              child: Text(
                                'Test searching',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () {
                                appState.refreshLibraries!(appState, false);
                                MyToast.showToast('Refresh libraries');
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Refresh libraries',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () async {
                                dynamic cookies = await appState.getCookies();
                                MyLogger.logger.i(cookies);
                              },
                              child: Text(
                                'Get cookies',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () async {},
                              child: Text(
                                'Other',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () {
                                // appState.refreshLibraries!(appState, false);
                                showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                          child: AddThirdAppCookieForm(
                                            thirdAppType: 1,
                                          ),
                                        ));
                                MyToast.showToast(
                                    'Test add third credential form');
                                // Navigator.pop(context);
                              },
                              child: Text(
                                'Test add third credential form',
                                style: textTheme.labelMedium,
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                shadowColor: MaterialStateProperty.all(
                                  colorScheme.primary,
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.grey,
                                ),
                              ),
                              onPressed: () {
                                appState.isUsingMockData =
                                    !appState.isUsingMockData;
                                MyToast.showToast(
                                    'Use Mock Data: ${appState.isUsingMockData}');
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Use Mock Data: ${appState.isUsingMockData}',
                                style: textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    context: context,
                  );
                }
              },
              actions: [
                QuickAction(
                  imageUri: 'assets/images/bilibili.png',
                  onTap: () {
                    if (appState.isUsingMockData ||
                        UserInfo.pmsUser!.subUsers.containsKey('bilibili')) {
                      MyToast.showToast('Switched to bilibili.');
                      MyLogger.logger.i('Switched to bilibili.');
                      if (_currentPlatform != 3) {
                        if (appState.songsPlayer != null) {
                          appState.disposeSongsPlayer();
                        }
                      }
                      appState.currentPlatform = 3;
                      StorageManager.saveData('currentPlatform',
                          appState.currentPlatform.toString());
                      appState.refreshLibraries!(appState, false);
                    } else {
                      MyToast.showToast(
                          'Please add valid credential for BiliBili.');
                      MyLogger.logger
                          .w('Please add valid credential for BiliBili.');
                    }
                  },
                ),
                QuickAction(
                  imageUri: 'assets/images/netease.png',
                  onTap: () {
                    if (appState.isUsingMockData ||
                        UserInfo.pmsUser!.subUsers.containsKey('ncm')) {
                      MyToast.showToast('Switched to netease music.');
                      MyLogger.logger.i('Switched to netease music.');
                      if (_currentPlatform != 2) {
                        if (appState.songsPlayer != null) {
                          appState.disposeSongsPlayer();
                        }
                      }
                      appState.currentPlatform = 2;
                      StorageManager.saveData('currentPlatform',
                          appState.currentPlatform.toString());
                      appState.refreshLibraries!(appState, false);
                    } else {
                      MyToast.showToast(
                          'Please add valid credential for Netease Cloud Music.');
                      MyLogger.logger.w(
                          'Please add valid credential for Netease Cloud Music.');
                    }
                  },
                ),
                QuickAction(
                  imageUri: 'assets/images/qqmusic.png',
                  onTap: () {
                    if (appState.isUsingMockData ||
                        UserInfo.pmsUser!.subUsers.containsKey('qqmusic')) {
                      MyToast.showToast('Switched to qq music.');
                      MyLogger.logger.i('Switched to qq music.');
                      if (_currentPlatform != 1) {
                        if (appState.songsPlayer != null) {
                          appState.disposeSongsPlayer();
                        }
                      }
                      appState.currentPlatform = 1;
                      StorageManager.saveData('currentPlatform',
                          appState.currentPlatform.toString());
                      appState.refreshLibraries!(appState, false);
                    } else {
                      MyToast.showToast(
                          'Please add valid credential for QQ Music.');
                      MyLogger.logger
                          .w('Please add valid credential for QQ Music.');
                    }
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
                              margin:
                                  EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
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
      ),
    );
  }
}
