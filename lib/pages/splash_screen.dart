import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../utils/storage_manager.dart';
import '../widgets/my_selectable_text.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<dynamic> currentPlatformFuture;
  late Future<String> splashImageFuture;
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    currentPlatformFuture = StorageManager.readData('currentPlatform');
    splashImageFuture = state.getBiliSplashScreenImage();
    Timer(Duration(seconds: 3), () {
      // if (hasActiveWork()) {
      //   final scheduler = SchedulerBinding.instance;
      //   scheduler.addPostFrameCallback((_) {
      //     Navigator.pushReplacementNamed(context, '/home_page');
      //   });
      // } else {
      Navigator.pushReplacementNamed(context, '/home_page');
      // }
    });
  }

  // bool hasActiveWork() {
  //   final scheduler = SchedulerBinding.instance;
  //   return scheduler.hasScheduledFrame;
  // }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MySelectableText(
                    snapshot.hasError ? '${snapshot.error}' : appState.errorMsg,
                    style: textTheme.labelMedium!.copyWith(
                      color: colorScheme.onPrimary,
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
                        currentPlatformFuture =
                            StorageManager.readData('currentPlatform')
                                as Future<int>;
                        splashImageFuture = appState.getBiliSplashScreenImage();
                      });
                    },
                  ),
                ],
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
                  child: CachedNetworkImage(
                    imageUrl: splashImage,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(MdiIcons.debian),
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
