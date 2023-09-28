import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_picker_china/city_picker_china.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ip_geolocation_io/ip_geolocation_io.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../config/secrets.dart';
import '../config/user_info.dart';
import '../entities/basic/basic_user.dart';
import '../entities/bilibili/bili_user.dart';
import '../entities/netease_cloud_music/ncm_user.dart';
import '../entities/pms/pms_user.dart';
import '../entities/qq_music/qqmusic_user.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'add_third_app_cookie_form.dart';
import 'bilibili_level_bar.dart';
import 'my_selectable_text.dart';

class BasicInfo extends StatefulWidget {
  @override
  State<BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  late Future<BasicUser?> _basicUser;

  double topMargin = 40.0;
  double bottomMargin = 200.0;
  late double bgTopOffset;
  late double userTopOffset;
  double scale = 1.0;
  late double imageSize;

  void _changeBasicUser(Future<BasicUser?> basicUser) {
    setState(() {
      _basicUser = basicUser;
    });
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    bool isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _basicUser = Future.value(MockData.pmsUser.subUsers['qqmusic']);
    } else {
      _basicUser = state.fetchUser(state.currentPlatform);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var screenSize = MediaQuery.of(context).size;
      imageSize = screenSize.width - 24.0;
      bgTopOffset = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          ? -topMargin
          : -screenSize.width * 0.4;
      userTopOffset = (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          ? imageSize - topMargin - bottomMargin
          : screenSize.height * 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    var currentPlatform = appState.currentPlatform;
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(12.0, 76.0, 12.0, 70.0),
      child: ClipRect(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: FutureBuilder(
                future: _basicUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    MyLogger.logger.e(snapshot.hasError
                        ? '${snapshot.error}'
                        : appState.errorMsg);
                    return Material(
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(
                            'Got some error',
                            style: textTheme.labelLarge,
                          ),
                          backgroundColor: colorScheme.primary,
                          iconTheme:
                              IconThemeData(color: colorScheme.onSecondary),
                        ),
                        body: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MySelectableText(
                                snapshot.hasError
                                    ? '${snapshot.error}'
                                    : appState.errorMsg,
                                style: textTheme.labelMedium!.copyWith(
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                              TextButton.icon(
                                style: ButtonStyle(
                                  shadowColor: MaterialStateProperty.all(
                                    colorScheme.primary,
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.grey,
                                  ),
                                ),
                                icon: Icon(
                                  MdiIcons.webRefresh,
                                  color: colorScheme.onSecondary,
                                ),
                                label: Text(
                                  'Retry',
                                  style: textTheme.labelMedium!.copyWith(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _basicUser = appState
                                        .fetchUser(appState.currentPlatform);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    dynamic user;
                    if (isUsingMockData) {
                      user = snapshot.data as QQMusicUser;
                    } else {
                      if (currentPlatform == 0) {
                        user = snapshot.data as PMSUser;
                        // Update pms user info after changing third app's credential.
                        UserInfo.pmsUser = user;
                      } else if (currentPlatform == 1) {
                        user = snapshot.data as QQMusicUser;
                      } else if (currentPlatform == 2) {
                        user = snapshot.data as NCMUser;
                      } else if (currentPlatform == 3) {
                        user = snapshot.data as BiliUser;
                      } else {
                        throw UnsupportedError('Invalid platform');
                      }
                    }
                    return Scaffold(
                      body: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            if (details.delta.dy > 0) {
                              if (bgTopOffset < 0) {
                                bgTopOffset += details.delta.dy / 4.0;
                                userTopOffset += details.delta.dy;
                              } else {
                                bgTopOffset = 0.0;
                                scale = 1.0 + details.delta.dy / 10.0;
                              }
                            } else {
                              if (scale > 1.0) {
                                scale = 1.0 + details.delta.dy / 10.0;
                              } else {
                                scale = 1.0;
                                bgTopOffset += details.delta.dy / 4.0;
                                userTopOffset += details.delta.dy;
                              }
                            }
                          });
                        },
                        onVerticalDragEnd: (details) {
                          setState(() {
                            bgTopOffset = (!kIsWeb && Platform.isAndroid ||
                                    Platform.isIOS)
                                ? -topMargin
                                : -screenSize.width * 0.4;
                            userTopOffset = (!kIsWeb &&
                                    (Platform.isAndroid || Platform.isIOS))
                                ? imageSize - topMargin - bottomMargin
                                : screenSize.height * 0.1;
                            scale = 1.0;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              top: bgTopOffset,
                              child: AnimatedContainer(
                                transformAlignment: Alignment.topCenter,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                width: imageSize,
                                height: imageSize,
                                transform: Matrix4.identity()..scale(scale),
                                child: isUsingMockData
                                    ? Image.asset(
                                        user.bgPic,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        fit: BoxFit.contain,
                                        imageUrl: user.bgPic.isEmpty
                                            ? MyAppState.defaultCoverImage
                                            : kIsWeb
                                                ? API
                                                    .convertImageUrl(user.bgPic)
                                                : user.bgPic,
                                        cacheManager:
                                            MyHttp.myImageCacheManager,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(MdiIcons.debian),
                                      ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              top: userTopOffset,
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.0, 0.05, 1.0],
                                    colors: [
                                      Colors.transparent,
                                      colorScheme.primary,
                                      colorScheme.primary,
                                    ],
                                  ).createShader(Rect.fromLTRB(
                                      0, 0, rect.width, rect.height));
                                },
                                blendMode: BlendMode.dstIn,
                                child: AnimatedContainer(
                                  width: imageSize,
                                  height: imageSize * 3.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  // transform: Matrix4.identity()..,
                                  // color: colorScheme.primary,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              top: userTopOffset,
                              child: AnimatedContainer(
                                  width: imageSize,
                                  height: imageSize * 3.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  // color: colorScheme.primary,
                                  child: isUsingMockData
                                      ? BuildMockUser(user: user as QQMusicUser)
                                      : currentPlatform == 0
                                          ? BuildPMSUser(
                                              user: user as PMSUser,
                                              changeBasicUser: _changeBasicUser,
                                            )
                                          : currentPlatform == 1
                                              ? BuildQQMusicUser(
                                                  user: user as QQMusicUser)
                                              : currentPlatform == 2
                                                  ? BuildNCMUser(
                                                      user: user as NCMUser)
                                                  : currentPlatform == 3
                                                      ? BuildBilibiliUser(
                                                          user:
                                                              user as BiliUser)
                                                      : ErrorWidget(
                                                          UnsupportedError(
                                                              'Invalid platform'))),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}

class BuildMockUser extends StatelessWidget {
  const BuildMockUser({
    super.key,
    required this.user,
  });

  final QQMusicUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(children: [
      CircleAvatar(
        radius: 36.0,
        backgroundImage: Image.asset('assets/images/qqmusic.png').image,
      ),
      Text(
        '${user.name}(${user.qqNumber})',
        style: textTheme.labelMedium,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 34.0,
            height: 23.0,
            child: Image.asset(user.lvPic),
          ),
          SizedBox(
            width: 10.0,
          ),
          SizedBox(
            width: 18.0,
            height: 14.0,
            child: Image.asset(user.listenPic),
          ),
        ],
      ),
      Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Followers: ${user.fansNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Following: ${user.followNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'friends: ${user.friendsNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Visitors: ${user.visitorNum}',
              style: textTheme.labelSmall,
            ),
          ]),
    ]);
  }
}

class BuildPMSUser extends StatefulWidget {
  const BuildPMSUser({
    super.key,
    required this.user,
    required this.changeBasicUser,
  });

  final PMSUser user;
  final Function changeBasicUser;

  @override
  State<BuildPMSUser> createState() => _BuildPMSUserState();
}

class _BuildPMSUserState extends State<BuildPMSUser>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // _tabController.addListener(() {
    //   if (_tabController.index == 0 &&
    //       !_currentDetailResource.isSeasonResource &&
    //       _currentDetailResource.page > 1) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (_collapseSubpagesScrollController.hasClients) {
    //         _collapseSubpagesScrollController.animateTo(
    //           (_subPageNo - 1) * 128.0,
    //           curve: Curves.easeInOut,
    //           duration: Duration(milliseconds: 300),
    //         );
    //       }
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    return Column(children: [
      CircleAvatar(
        radius: 36.0,
        backgroundImage: CachedNetworkImageProvider(
          widget.user.headPic.isEmpty
              ? MyAppState.defaultCoverImage
              : kIsWeb
                  ? API.convertImageUrl(widget.user.headPic)
                  : widget.user.headPic,
          cacheManager: MyHttp.myImageCacheManager,
        ),
      ),
      SizedBox(height: 10.0),
      MySelectableText(
        '${widget.user.name}(${widget.user.id})',
        style: textTheme.labelLarge,
      ),
      if (widget.user.intro.isNotEmpty)
        MySelectableText(
          widget.user.intro,
          style: textTheme.labelSmall,
        ),
      SizedBox(height: 10.0),
      Container(
        height: 380.0,
        // width: 300.0,
        color: colorScheme.primary,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicatorColor: Color(0xFFFB6A9D),
                  dividerColor: colorScheme.onPrimary.withOpacity(0.3),
                  labelColor: Color(0xFFFB6A9D),
                  labelStyle: textTheme.labelSmall,
                  overlayColor: MaterialStateProperty.all(Colors.grey),
                  unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.3),
                  unselectedLabelStyle: textTheme.labelSmall,
                  tabs: [
                    Tab(
                        child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: GestureDetector(
                              onLongPress: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 20.0),
                                              Text(
                                                'Add credential for QQ Music',
                                                style: textTheme.labelMedium,
                                              ),
                                              AddThirdAppCookieForm(
                                                thirdAppType: 1,
                                              ),
                                            ],
                                          ),
                                        ));
                                if (result != null) {
                                  if (result) {
                                    bool isUsingMockData =
                                        appState.isUsingMockData;
                                    Future<BasicUser?> basicUser;
                                    if (isUsingMockData) {
                                      basicUser = Future.value(
                                          MockData.pmsUser.subUsers['qqmusic']);
                                    } else {
                                      basicUser = appState
                                          .fetchUser(appState.currentPlatform);
                                    }
                                    widget.changeBasicUser(basicUser);
                                    setState(() {});
                                  } else {
                                    MyToast.showToast(appState.errorMsg);
                                  }
                                }
                              },
                              child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/qqmusic.png')),
                            ))),
                    Tab(
                        child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: GestureDetector(
                              onLongPress: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 20.0),
                                              Text(
                                                'Add credential for Netease Cloud Music',
                                                style: textTheme.labelMedium,
                                              ),
                                              AddThirdAppCookieForm(
                                                thirdAppType: 2,
                                              ),
                                            ],
                                          ),
                                        ));
                                if (result != null) {
                                  if (result) {
                                    bool isUsingMockData =
                                        appState.isUsingMockData;
                                    Future<BasicUser?> basicUser;
                                    if (isUsingMockData) {
                                      basicUser = Future.value(
                                          MockData.pmsUser.subUsers['qqmusic']);
                                    } else {
                                      basicUser = appState
                                          .fetchUser(appState.currentPlatform);
                                    }
                                    widget.changeBasicUser(basicUser);
                                    setState(() {});
                                  } else {
                                    MyToast.showToast(appState.errorMsg);
                                  }
                                }
                              },
                              child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/netease.png')),
                            ))),
                    Tab(
                        child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: GestureDetector(
                              onLongPress: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: 20.0),
                                              Text(
                                                'Add credential for BiliBili',
                                                style: textTheme.labelMedium,
                                              ),
                                              AddThirdAppCookieForm(
                                                thirdAppType: 3,
                                              ),
                                            ],
                                          ),
                                        ));
                                if (result != null) {
                                  if (result) {
                                    bool isUsingMockData =
                                        appState.isUsingMockData;
                                    Future<BasicUser?> basicUser;
                                    if (isUsingMockData) {
                                      basicUser = Future.value(
                                          MockData.pmsUser.subUsers['qqmusic']);
                                    } else {
                                      basicUser = appState
                                          .fetchUser(appState.currentPlatform);
                                    }
                                    widget.changeBasicUser(basicUser);
                                    setState(() {});
                                  } else {
                                    MyToast.showToast(appState.errorMsg);
                                  }
                                }
                              },
                              child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/bilibili.png')),
                            ))),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Center(
                        child: widget.user.subUsers.containsKey('qqmusic')
                            ? ListView(
                                children: [
                                  BuildQQMusicUser(
                                      user: widget.user.subUsers['qqmusic']
                                          as QQMusicUser),
                                ],
                              )
                            : Text(
                                'Please login to QQ Music',
                                style: textTheme.labelMedium,
                              ),
                      ),
                      Center(
                        child: widget.user.subUsers.containsKey('ncm')
                            ? ListView(
                                children: [
                                  SizedBox(height: 35.0),
                                  BuildNCMUser(
                                      user: widget.user.subUsers['ncm']
                                          as NCMUser),
                                ],
                              )
                            : Text(
                                'Please login to Netease Cloud Music',
                                style: textTheme.labelMedium,
                              ),
                      ),
                      Center(
                        child: widget.user.subUsers.containsKey('bilibili')
                            ? ListView(
                                children: [
                                  BuildBilibiliUser(
                                      user: widget.user.subUsers['bilibili']
                                          as BiliUser),
                                ],
                              )
                            : Text(
                                'Please login to BiliBili',
                                style: textTheme.labelMedium,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class BuildQQMusicUser extends StatelessWidget {
  const BuildQQMusicUser({
    super.key,
    required this.user,
  });

  final QQMusicUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(children: [
      CircleAvatar(
        radius: 36.0,
        backgroundImage: CachedNetworkImageProvider(
          user.headPic.isEmpty
              ? MyAppState.defaultCoverImage
              : kIsWeb
                  ? API.convertImageUrl(user.headPic)
                  : user.headPic,
          cacheManager: MyHttp.myImageCacheManager,
        ),
      ),
      MySelectableText(
        '${user.name}(${user.qqNumber})',
        style: textTheme.labelMedium,
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 34.0,
            height: 23.0,
            child: CachedNetworkImage(
              imageUrl: user.lvPic.isEmpty
                  ? MyAppState.defaultCoverImage
                  : kIsWeb
                      ? API.convertImageUrl(user.lvPic)
                      : user.lvPic,
              cacheManager: MyHttp.myImageCacheManager,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(MdiIcons.debian),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          SizedBox(
            width: 18.0,
            height: 14.0,
            child: CachedNetworkImage(
              imageUrl: user.listenPic.isEmpty
                  ? MyAppState.defaultCoverImage
                  : kIsWeb
                      ? API.convertImageUrl(user.listenPic)
                      : user.listenPic,
              cacheManager: MyHttp.myImageCacheManager,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(MdiIcons.debian),
            ),
          ),
        ],
      ),
      Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Followers: ${user.fansNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Following: ${user.followNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Friends: ${user.friendsNum}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Visitors: ${user.visitorNum}',
              style: textTheme.labelSmall,
            ),
          ]),
    ]);
  }
}

class BuildNCMUser extends StatefulWidget {
  const BuildNCMUser({
    super.key,
    required this.user,
  });

  final NCMUser user;

  @override
  State<BuildNCMUser> createState() => _BuildNCMUserState();
}

class _BuildNCMUserState extends State<BuildNCMUser> {
  Future<CityResult?> resolvePostCode(String code) async {
    return CityPicker.searchWithCode(code);
  }

  String province = '';
  String city = '';
  String area = '';

  @override
  void initState() {
    super.initState();
    final geolocation = IpGeoLocationIO(ipGeoLocationApiKey);
    geolocation.getUserLocation().then((value) {
      if (mounted) {
        setState(() {
          area = '${value.city}, ${value.stateProv}, ${value.countryName}';
        });
      }
    }, onError: (error) {
      MyLogger.logger.e('$error: \n${error.stackTrace}');
    });
    resolvePostCode(widget.user.province.toString())
        .then((value) => setState(() {
              province = value!.province;
            }));
    resolvePostCode(widget.user.city.toString()).then((value) => setState(() {
          city = value!.city!;
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NCMUser user = widget.user;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 36.0,
          backgroundImage: CachedNetworkImageProvider(
            user.headPic.isEmpty
                ? MyAppState.defaultCoverImage
                : kIsWeb
                    ? API.convertImageUrl(user.headPic)
                    : user.headPic,
            cacheManager: MyHttp.myImageCacheManager,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MySelectableText(
            '${user.name}(${user.id})',
            style: textTheme.labelMedium,
          ),
        ),
        MySelectableText(
          user.signature,
          style: textTheme.labelSmall,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                user.gender == 0
                    ? 'assets/images/gender_secret.png'
                    : user.gender == 1
                        ? 'assets/images/male.png'
                        : 'assets/images/female.png',
                height: 12.0,
                width: 12.0,
              ),
            ),
            Text(
              'Birthday: ${DateFormat('yyyy-MM-dd').format(
                DateTime.fromMillisecondsSinceEpoch(user.birthday),
              )}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Following: ${user.follows}',
              style: textTheme.labelSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '|',
                style: textTheme.labelLarge!.copyWith(
                  color: textTheme.labelLarge!.color!.withOpacity(0.1),
                ),
              ),
            ),
            Text(
              'Fans: ${user.fans}',
              style: textTheme.labelSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '|',
                style: textTheme.labelLarge!.copyWith(
                  color: textTheme.labelLarge!.color!.withOpacity(0.1),
                ),
              ),
            ),
            Text(
              'Level: ${user.level}',
              style: textTheme.labelSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '|',
                style: textTheme.labelLarge!.copyWith(
                  color: textTheme.labelLarge!.color!.withOpacity(0.1),
                ),
              ),
            ),
            Text(
              'VIP: ${user.vipType == 0 ? 'no' : 'yes'}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () {},
                child: Tooltip(
                  message:
                      'Expired at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(user.redVipExpireTime),
                  )}',
                  triggerMode: TooltipTriggerMode.tap,
                  textStyle: textTheme.labelSmall,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 16.0,
                        child: CachedNetworkImage(
                          imageUrl: user.redVipLevelIcon.isEmpty
                              ? MyAppState.defaultCoverImage
                              : kIsWeb
                                  ? API.convertImageUrl(user.redVipLevelIcon)
                                  : user.redVipLevelIcon,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Lv${user.redVipLevel}',
                          style: textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () {},
                child: Tooltip(
                  message:
                      'Expired at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        user.redPlusVipExpireTime),
                  )}',
                  triggerMode: TooltipTriggerMode.tap,
                  textStyle: textTheme.labelSmall,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 16.0,
                        child: CachedNetworkImage(
                          imageUrl: user.redPlusVipLevelIcon.isEmpty
                              ? MyAppState.defaultCoverImage
                              : kIsWeb
                                  ? API
                                      .convertImageUrl(user.redPlusVipLevelIcon)
                                  : user.redPlusVipLevelIcon,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Lv${user.redPlusVipLevel}',
                          style: textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () {},
                child: Tooltip(
                  message:
                      'Expired at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        user.musicPackageVipExpireTime),
                  )}',
                  triggerMode: TooltipTriggerMode.tap,
                  textStyle: textTheme.labelSmall,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 16.0,
                        child: CachedNetworkImage(
                          imageUrl: user.musicPackageVipLevelIcon.isEmpty
                              ? MyAppState.defaultCoverImage
                              : kIsWeb
                                  ? API.convertImageUrl(
                                      user.musicPackageVipLevelIcon)
                                  : user.musicPackageVipLevelIcon,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Lv${user.musicPackageVipLevel}',
                          style: textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Listened songs:',
                      textAlign: TextAlign.end,
                      style: textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ' ${user.listenSongs}',
                      textAlign: TextAlign.start,
                      style: textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Playlists:',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ' ${user.playlistCount}',
                    textAlign: TextAlign.start,
                    style: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Province:',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ' $province',
                    textAlign: TextAlign.start,
                    style: textTheme.labelSmall!.copyWith(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'City:',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ' $city',
                    textAlign: TextAlign.start,
                    style: textTheme.labelSmall!.copyWith(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Registration time:',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(user.createTime),
                    )}',
                    textAlign: TextAlign.start,
                    style: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Last login:',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    ' ${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(user.lastLoginTime),
                    )}',
                    textAlign: TextAlign.start,
                    style: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Tooltip(
                message: user.lastLoginIP,
                triggerMode: TooltipTriggerMode.tap,
                textStyle: textTheme.labelSmall,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Area:',
                        textAlign: TextAlign.end,
                        style: textTheme.labelSmall,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          area,
                          textAlign: TextAlign.start,
                          style: textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BuildBilibiliUser extends StatelessWidget {
  const BuildBilibiliUser({
    super.key,
    required this.user,
  });

  final BiliUser user;

  int rgbIntToARGBInt(int rgbInt) {
    String hexString = 'FF${rgbInt.toRadixString(16).toUpperCase()}';
    return int.parse(hexString, radix: 16);
  }

  Map<String, Object> getIconAndColorByLevel(int level) {
    Map<String, Object> map = HashMap();
    String levelIcon;
    Color levelColor;
    switch (level) {
      case 0:
        levelIcon = 'assets/images/bili_lv0.png';
        levelColor = Color(0xFFBFBFBF);
        break;
      case 1:
        levelIcon = 'assets/images/bili_lv1.png';
        levelColor = Color(0xFFBFBFBF);
        break;
      case 2:
        levelIcon = 'assets/images/bili_lv2.png';
        levelColor = Color(0xFF95DDB2);
        break;
      case 3:
        levelIcon = 'assets/images/bili_lv3.png';
        levelColor = Color(0xFF92D1E5);
        break;
      case 4:
        levelIcon = 'assets/images/bili_lv4.png';
        levelColor = Color(0xFFFFB37C);
        break;
      case 5:
        levelIcon = 'assets/images/bili_lv5.png';
        levelColor = Color(0xFFFF6C00);
        break;
      case 6:
        levelIcon = 'assets/images/bili_lv6.png';
        levelColor = Color(0xFFFF0000);
        break;
      default:
        throw Exception('Invalid level');
    }
    map.putIfAbsent('levelIcon', () => levelIcon);
    map.putIfAbsent('levelColor', () => levelColor);
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    double proportion;
    int currentLevelExp = user.currentLevelExp;
    dynamic nextLevelExp;
    if (user.level == 6) {
      nextLevelExp = '--';
      proportion = 1;
    } else {
      nextLevelExp = user.nextLevelExp;
      proportion = user.currentLevelExp / user.nextLevelExp;
    }
    Map<String, Object> map = getIconAndColorByLevel(user.level);
    Color levelColor = map['levelColor'] as Color;
    String levelIcon = map['levelIcon'] as String;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 36.0,
                backgroundImage: CachedNetworkImageProvider(
                  user.headPic.isEmpty
                      ? MyAppState.defaultCoverImage
                      : kIsWeb
                          ? API.convertImageUrl(user.headPic)
                          : user.headPic,
                  cacheManager: MyHttp.myImageCacheManager,
                ),
              ),
              Opacity(
                opacity: 1,
                child: user.pendantImage.isNotEmpty
                    ? GestureDetector(
                        onTap: () {},
                        child: Tooltip(
                          message: user.pendantName,
                          triggerMode: TooltipTriggerMode.tap,
                          textStyle: textTheme.labelSmall,
                          child: CachedNetworkImage(
                            imageUrl: kIsWeb
                                ? API.convertImageUrl(user.dynamicPendantImage)
                                : user.dynamicPendantImage,
                            cacheManager: MyHttp.myImageCacheManager,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(MdiIcons.debian),
                            width: 125.0,
                          ),
                        ),
                      )
                    : Container(),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(user.name,
                  style: textTheme.labelMedium!.copyWith(fontSize: 18.0)),
            ),
            GestureDetector(
              onTap: () {},
              child: Tooltip(
                message: 'Expired at ${DateFormat('yyyy-MM-dd').format(
                  DateTime.fromMillisecondsSinceEpoch(user.vipExpireTime),
                )}',
                triggerMode: TooltipTriggerMode.tap,
                textStyle: textTheme.labelSmall,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 4.0),
                  child: CachedNetworkImage(
                    imageUrl: user.vipIcon.isEmpty
                        ? MyAppState.defaultCoverImage
                        : kIsWeb
                            ? API.convertImageUrl(user.vipIcon)
                            : user.vipIcon,
                    cacheManager: MyHttp.myImageCacheManager,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(MdiIcons.debian),
                    width: 46.0,
                  ),
                ),
              ),
            ),
            user.wearingFansBadge
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0, right: 4.0),
                    child: Container(
                      height: 14.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(rgbIntToARGBInt(user
                              .fansBadgeBorderColor)), // Set border color here
                          width: 1, // Set border width here
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment
                                    .topLeft, // Define the gradient start point
                                end: Alignment
                                    .bottomRight, // Define the gradient end point
                                colors: [
                                  Color(rgbIntToARGBInt(
                                      user.fansBadgeStartColor)),
                                  Color(
                                      rgbIntToARGBInt(user.fansBadgeEndColor)),
                                ], // Define the gradient colors
                                stops: [0.0, 1.0], // Define the gradient stops
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 2.0, left: 2.0, right: 2.0),
                              child: Center(
                                child: Text(
                                  user.fansBadgeText,
                                  style: TextStyle(
                                    height: 0.8,
                                    fontSize: 8.0,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: 14.0,
                              height: 14.0,
                              child: Text(
                                '${user.fansBadgeLevel}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  height: 1.3,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(rgbIntToARGBInt(
                                      user.fansBadgeBorderColor)),
                                ),
                              ))
                        ],
                      ),
                    ),
                  )
                : Container(),
            user.nameplateImage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Tooltip(
                        message:
                            '${user.nameplateName}: ${user.nameplateCondition}',
                        triggerMode: TooltipTriggerMode.tap,
                        textStyle: textTheme.labelSmall,
                        child: CachedNetworkImage(
                          imageUrl: kIsWeb
                              ? API.convertImageUrl(user.nameplateImage)
                              : user.nameplateImage,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                          width: 12.0,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        MySelectableText(
          user.sign,
          style: textTheme.labelSmall!.copyWith(
              fontSize: 12.0, color: colorScheme.onPrimary.withOpacity(0.5)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                user.gender == 0
                    ? 'assets/images/gender_secret.png'
                    : user.gender == 1
                        ? 'assets/images/male.png'
                        : 'assets/images/female.png',
                height: 12.0,
                width: 12.0,
              ),
            ),
            Text(
              'uid: ',
              style: textTheme.labelSmall!.copyWith(
                  fontSize: 12.0,
                  color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            MySelectableText(
              '${user.mid}',
              style: textTheme.labelSmall!.copyWith(
                  fontSize: 12.0,
                  color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                onTap: () {},
                child: Tooltip(
                  message: user.ip,
                  triggerMode: TooltipTriggerMode.tap,
                  textStyle: textTheme.labelSmall,
                  child: Text(
                    'ip: ${user.countryCode == 86 ? user.province : user.country}',
                    style: textTheme.labelSmall!.copyWith(
                        fontSize: 12.0,
                        color: colorScheme.onPrimary.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
            user.isp == 0
                ? Image.asset('assets/images/china_mobile.png', width: 20.0)
                : user.isp == 1
                    ? Image.asset('assets/images/china_telecom.png',
                        width: 20.0)
                    : Container(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Image.asset(
                      levelIcon,
                      width: 26.0,
                    ),
                  ),
                  Text(
                    '$currentLevelExp/$nextLevelExp',
                    style: textTheme.labelSmall!.copyWith(
                        fontSize: 12.0,
                        color: colorScheme.onPrimary.withOpacity(0.5)),
                  )
                ],
              ),
              LevelBar(
                proportion: proportion,
                activeColor: levelColor,
                inactiveColor: Colors.grey,
                height: 2.0,
                width: 100.0,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Followers: ${user.follower}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Following: ${user.following}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Dynamics: ${user.dynamicCount}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Coins: ${user.coins}',
              style: textTheme.labelSmall,
            ),
            Text(
              'B coins: ${user.bcoin}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Moral: ${user.moral}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Bind email: ${user.bindEmail}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Birthday: ${user.birthday}',
              style: textTheme.labelSmall,
            ),
            Text(
              'Bind phone: ${user.bindPhone}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
