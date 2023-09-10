import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import '../utils/pm_login.dart';
import '../utils/storage_manager.dart';
import '../widgets/my_selectable_text.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<dynamic> currentPlatformFuture;

  late Future<String> splashImageFuture;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    currentPlatformFuture = StorageManager.readData('currentPlatform');
    splashImageFuture = state.getBiliSplashScreenImage();
    Timer(Duration(seconds: 3), () async {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var token = localStorage.getString('token');
      if (token != null && token.isNotEmpty) {
        bool? isExpired = await PMLogin.checkToken(token);
        if (isExpired != null && !isExpired) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home_page');
          }
        } else {
          // Expired.
          MyToast.showToast('Login expired, please login again.');
          MyLogger.logger.w('Login expired!');
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login_page');
          }
        }
      } else {
        // Haven't logged.
        MyLogger.logger.w('Please login first.');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login_page');
        }
      }
    });
  }

  // bool hasActiveWork() {
  //   final scheduler = SchedulerBinding.instance;
  //   return scheduler.hasScheduledFrame;
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: Future.wait([currentPlatformFuture, splashImageFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            MyLogger.logger
                .e(snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
            return Material(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Got some error',
                    style: textTheme.labelLarge,
                  ),
                  backgroundColor: colorScheme.primary,
                  iconTheme: IconThemeData(color: colorScheme.onSecondary),
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
                            currentPlatformFuture =
                                StorageManager.readData('currentPlatform')
                                    as Future<int>;
                            splashImageFuture =
                                appState.getBiliSplashScreenImage();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            List<dynamic> data = snapshot.data!;
            int currentPlatform;
            if (data[0] == null) {
              StorageManager.saveData(
                  'currentPlatform', appState.currentPlatform);
              currentPlatform = appState.currentPlatform;
            } else {
              currentPlatform = data[0] as int;
            }
            String splashImage = data[1] as String;
            print('Current platform: $currentPlatform');
            print('Current splash screen image: $splashImage');
            if (currentPlatform == 3) {
              return Scaffold(
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: kIsWeb
                      ? ImageNetwork(
                          image: API.convertImageUrl(splashImage),
                          height: screenSize.height,
                          width: screenSize.width,
                          curve: Curves.easeIn,
                          fullScreen: true,
                          fitAndroidIos: BoxFit.cover,
                          fitWeb: BoxFitWeb.cover,
                          onLoading: CircularProgressIndicator(),
                          onError: Icon(MdiIcons.debian),
                        )
                      : CachedNetworkImage(
                          imageUrl: splashImage,
                          cacheManager: MyHttp.myImageCacheManager,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(MdiIcons.debian),
                        ),
                ),
              );
            } else {
              return Scaffold(
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.asset(
                    'assets/images/welcome.png',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          }
        });
  }
}
