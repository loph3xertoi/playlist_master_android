import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../entities/basic/basic_song.dart';
import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../third_lib_change/like_button/like_button.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'select_library_popup.dart';
import 'song_item_menu_popup.dart';

class BiliResourceItem extends StatefulWidget {
  final int index;
  final BiliResource resource;

  const BiliResourceItem({
    super.key,
    required this.index,
    required this.resource,
  });

  @override
  State<BiliResourceItem> createState() => _BiliResourceItemState();
}

class _BiliResourceItemState extends State<BiliResourceItem> {
  @override
  void initState() {
    super.initState();
  }

  // void _addResourceToLibrary(BuildContext context, MyAppState appState) async {
  //   if (mounted) {
  //     List<Future<Result?>>? list =
  //         await showFlexibleBottomSheet<List<Future<Result?>>>(
  //       minHeight: 0,
  //       initHeight: 0.45,
  //       maxHeight: 0.9,
  //       context: context,
  //       bottomSheetColor: Colors.transparent,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(30.0),
  //           topRight: Radius.circular(30.0),
  //         ),
  //       ),
  //       builder: (
  //         BuildContext context,
  //         ScrollController scrollController,
  //         double bottomSheetOffset,
  //       ) {
  //         return SelectLibraryPopup(
  //           scrollController: scrollController,
  //           songs: [widget.resource],
  //           action: 'add',
  //         );
  //       },
  //       anchors: [0, 0.45, 0.9],
  //       isSafeArea: true,
  //     );
  //     if (list != null) {
  //       List<Result?> results = await Future.wait<Result?>(list);
  //       for (Result? result in results) {
  //         if (result != null && result.success) {
  //           appState.refreshLibraries!(appState, true);
  //           appState.refreshDetailLibraryPage!(appState);
  //           MyToast.showToast('Add songs successfully');
  //           break;
  //         }
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    var isUsingMockData = appState.isUsingMockData;
    var resource = widget.resource;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 80.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 5.0),
          //   child: SizedBox(
          //     width: 40.0,
          //     height: 50.0,
          //     child: Center(
          //       child: Text(
          //         (widget.index + 1).toString(),
          //         style: textTheme.labelSmall,
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            width: 128.0,
            height: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                4.0,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                print(appState);
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: isUsingMockData
                    ? Image.asset(
                        resource.cover,
                        fit: BoxFit.cover,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: resource.cover.isNotEmpty
                                ? resource.cover
                                : MyAppState.defaultCoverImage,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(MdiIcons.debian),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                              right: 5.0,
                              bottom: 5.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(formatDuration(resource.duration),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              )),
                        ],
                      ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        resource.title,
                        maxLines: 2,
                        style: textTheme.labelSmall!.copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 1.0, right: 5.0),
                              child: Image.asset(
                                'assets/images/up.png',
                                height: 12.0,
                              ),
                            ),
                            Text(
                              resource.upperName,
                              style: textTheme.labelSmall!.copyWith(
                                fontSize: 12.0,
                                color: colorScheme.onPrimary.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Image.asset(
                                          'assets/images/bili_play_count.png',
                                          height: 16.0,
                                        ),
                                      ),
                                      Text(
                                        humanizeInt(resource.playCount),
                                        style: textTheme.labelSmall!.copyWith(
                                          fontSize: 11.0,
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.5),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 1.0),
                                        child: Image.asset(
                                          'assets/images/bili_danmaku.png',
                                          height: 16.0,
                                        ),
                                      ),
                                      Text(
                                        humanizeInt(resource.danmakuCount),
                                        style: textTheme.labelSmall!.copyWith(
                                          fontSize: 11.0,
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.5),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 1.0),
                                        child: Image.asset(
                                          'assets/images/bili_page.png',
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.5),
                                          height: 16.0,
                                        ),
                                      ),
                                      Text(
                                        humanizeInt(resource.page),
                                        style: textTheme.labelSmall!.copyWith(
                                          fontSize: 11.0,
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.5),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          // var data = await showDialog(
                                          //   context: context,
                                          //   builder: (context) =>
                                          //       CreateSongItemMenuDialog(song: widget.song),
                                          // );
                                          // if (data == 'Add to library' && mounted) {
                                          //   _addResourceToLibrary(context, appState);
                                          // }
                                        },
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.5),
                                        tooltip: 'Edit resource',
                                        icon: Icon(
                                          Icons.more_vert_rounded,
                                          size: 16.0,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int remainedSeconds = seconds % 60;
    String formattedSeconds =
        remainedSeconds < 10 ? '0$remainedSeconds' : '$remainedSeconds';
    int remainedMinutes = duration.inMinutes % 60;
    String formattedMinutes =
        remainedMinutes < 10 ? '0$remainedMinutes' : '$remainedMinutes';
    int remainedHours = duration.inHours;
    String formattedHours =
        remainedHours < 10 ? '0$remainedHours' : '$remainedHours';
    return formattedHours == '00'
        ? '$formattedMinutes:$formattedSeconds'
        : '$formattedHours:$formattedMinutes:$formattedSeconds';
  }
}
