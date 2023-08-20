import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';

class ShowVideoPlayerSidebar extends StatelessWidget {
  const ShowVideoPlayerSidebar(
      {required this.videoLink, required this.updateResolutionList});

  final String videoLink;
  final Function updateResolutionList;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(0.0),
      alignment: Alignment.centerRight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: SizedBox(
        height: double.infinity,
        width: size.width / 10,
        child: Material(
          color: Colors.black54,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  onTap: () {
                    MyLogger.logger.d('Caching video...');
                    if (videoLink.substring(0, 4) == 'http') {
                      () async {
                        await appState.cacheVideo(videoLink);
                        updateResolutionList();
                      }();
                    } else {
                      MyToast.showToast('Already cached');
                      MyLogger.logger.wtf('Already cached');
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: Icon(Icons.download_rounded),
                          color: Colors.white70,
                          onPressed: () {
                            MyLogger.logger.d('Caching video...');
                            if (videoLink.substring(0, 4) == 'http') {
                              () async {
                                await appState.cacheVideo(videoLink);
                                updateResolutionList();
                              }();
                            } else {
                              MyToast.showToast('Already cached');
                              MyLogger.logger.wtf('Already cached');
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Cache this video',
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  onTap: () {
                    MyLogger.logger.d('Other settings');
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: Icon(Icons.description_rounded),
                          color: Colors.white70,
                          onPressed: () {
                            MyLogger.logger.d('Other settings');
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Other settings',
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
