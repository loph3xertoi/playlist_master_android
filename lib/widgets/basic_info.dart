import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_picker_china/city_picker_china.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ip_geolocation_io/ip_geolocation_io.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_user.dart';
import '../entities/netease_cloud_music/ncm_user.dart';
import '../entities/pms/pms_user.dart';
import '../entities/qq_music/qqmusic_user.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
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
      imageSize = MediaQuery.of(context).size.width - 24.0;
      bgTopOffset = -topMargin;
      userTopOffset = imageSize - topMargin - bottomMargin;
    });
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    var currentPlatform = appState.currentPlatform;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MySelectableText(
                            '${snapshot.error}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Roboto',
                              fontSize: 16.0,
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
                              color: colorScheme.onPrimary,
                            ),
                            label: Text(
                              'Retry',
                              style: textTheme.labelMedium!.copyWith(
                                color: colorScheme.onPrimary,
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
                    );
                  } else {
                    dynamic user;
                    if (isUsingMockData) {
                      user = snapshot.data as QQMusicUser;
                    } else {
                      if (currentPlatform == 0) {
                        user = snapshot.data as PMSUser;
                      } else if (currentPlatform == 1) {
                        user = snapshot.data as QQMusicUser;
                      } else if (currentPlatform == 2) {
                        user = snapshot.data as NCMUser;
                      } else if (currentPlatform == 3) {
                        throw UnimplementedError(
                            'Not yet implement bilibili platform');
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
                            bgTopOffset = -topMargin;
                            userTopOffset =
                                imageSize - topMargin - bottomMargin;
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
                                        imageUrl: user.bgPic.isEmpty
                                            ? MyAppState.defaultCoverImage
                                            : user.bgPic,
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
                                    ? BuildMockUser(
                                        user: user as QQMusicUser,
                                      )
                                    : currentPlatform == 1
                                        ? BuildQQMusicUser(
                                            user: user as QQMusicUser,
                                          )
                                        : currentPlatform == 2
                                            ? BuildNCMUser(
                                                user: user as NCMUser,
                                              )
                                            // :currentPlatform==3?BuildQQMusicUser( user: user, currentPlatform: currentPlatform, textTheme: textTheme)
                                            : const Placeholder(),
                              ),
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
          user.headPic.isEmpty ? MyAppState.defaultCoverImage : user.headPic,
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
                  : user.lvPic,
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
                  : user.listenPic,
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
    const apiKey = '7e6e5a2ec2404fc8b3e846d45c5abb76';
    final geolocation = IpGeoLocationIO(apiKey);
    geolocation.getUserLocation().then((value) => setState(() {
          area = '${value.city}, ${value.stateProv}, ${value.countryName}';
        }));
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 36.0,
          backgroundImage: CachedNetworkImageProvider(
            user.headPic.isEmpty ? MyAppState.defaultCoverImage : user.headPic,
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
                              : user.redVipLevelIcon,
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
                              : user.redPlusVipLevelIcon,
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
                              : user.musicPackageVipLevelIcon,
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
