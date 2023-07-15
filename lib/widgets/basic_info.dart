import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_user.dart';
import '../entities/pms/pms_user.dart';
import '../entities/qq_music/qqmusic_user.dart';
import '../http/api.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';

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

  Future<BasicUser?> fetchUser(int platform) async {
    Uri url = Uri.http(API.host, '${API.user}/${API.uid}', {
      'platform': platform.toString(),
    });
    MyLogger.logger.d('Loading user information from network...');
    final client = RetryClient(http.Client());
    try {
      var response = await client.get(url);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        Map<String, dynamic> user = decodedResponse['data'];
        // result = user.map((e) => BasicUser.fromJson(e)).toList();
        if (platform == 0) {
          return PMSUser.fromJson(user);
        } else if (platform == 1) {
          return QQMusicUser.fromJson(user);
        } else if (platform == 2) {
          throw Exception('Not implement netease music platform');
        } else if (platform == 3) {
          throw Exception('Not implement bilibili platform');
        } else {
          throw Exception('Invalid platform');
        }
      } else {
        MyToast.showToast('Response error with code: ${response.statusCode}');
        MyLogger.logger.e('Response error with code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      MyToast.showToast('Exception thrown: $e');
      MyLogger.logger.e('Network error with exception: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    bool isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _basicUser = Future.value(MockData.pmsUser.subUsers['qqmusic']);
    } else {
      _basicUser = fetchUser(state.currentPlatform);
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
                        children: [
                          SelectableText(
                            'Exception: ${snapshot.error}',
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
                            icon: Icon(MdiIcons.webRefresh),
                            label: Text(
                              'Retry',
                              style: textTheme.labelMedium,
                            ),
                            onPressed: () {
                              setState(() {
                                _basicUser =
                                    fetchUser(appState.currentPlatform);
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
                      if (appState.currentPlatform == 0) {
                        user = snapshot.data as PMSUser;
                      } else if (appState.currentPlatform == 1) {
                        user = snapshot.data as QQMusicUser;
                      } else if (appState.currentPlatform == 2) {
                        throw Exception('Not implement netease music platform');
                      } else if (appState.currentPlatform == 3) {
                        throw Exception('Not implement bilibili platform');
                      } else {
                        throw Exception('Invalid platform');
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
                                child: Column(children: [
                                  CircleAvatar(
                                    radius: 36.0,
                                    backgroundImage: isUsingMockData
                                        ? Image.asset(
                                                'assets/images/qqmusic.png')
                                            .image
                                        : CachedNetworkImageProvider(
                                            user.headPic.isEmpty
                                                ? MyAppState.defaultCoverImage
                                                : user.headPic,
                                          ),
                                    // NetworkImage(user.headPic),
                                  ),
                                  Text(
                                    user.name,
                                    style: textTheme.labelMedium,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 34.0,
                                        height: 23.0,
                                        child: isUsingMockData
                                            ? Image.asset(user.lvPic)
                                            : CachedNetworkImage(
                                                imageUrl: user.lvPic.isEmpty
                                                    ? MyAppState
                                                        .defaultCoverImage
                                                    : user.lvPic,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(MdiIcons.debian),
                                              ),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      SizedBox(
                                        width: 18.0,
                                        height: 14.0,
                                        child: isUsingMockData
                                            ? Image.asset(user.listenPic)
                                            : CachedNetworkImage(
                                                imageUrl: user.listenPic.isEmpty
                                                    ? MyAppState
                                                        .defaultCoverImage
                                                    : user.listenPic,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(MdiIcons.debian),
                                              ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
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
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    // return Stack(
                    //   alignment: Alignment.topCenter,
                    //   children: [
                    //     AnimatedContainer(

                    //     )
                    //   ],
                    // );

                    // return CustomScrollView(
                    //   slivers: [
                    //     SliverAppBar(
                    //       backgroundColor: Colors.transparent,
                    //       expandedHeight: MediaQuery.of(context).size.width,
                    //       flexibleSpace: FlexibleSpaceBar(
                    //         background: Stack(
                    //           fit: StackFit.expand,
                    //           children: [
                    //             Image.network(
                    //               user.bgPic,
                    //               fit: BoxFit.cover,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       stretch: true,
                    //       pinned: true,
                    //     ),
                    //     SliverList(
                    //       delegate: SliverChildListDelegate(
                    //         [
                    //           Container(
                    //             color: Colors.white,
                    //             height: 600,
                    //             child: Column(
                    //               children: [
                    //                 // Place your user information widgets here.
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
