import 'dart:async';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/bilibili/bili_resource.dart';
import '../entities/dto/result.dart';
import '../states/app_state.dart';
import '../utils/my_toast.dart';
import 'resource_item_menu_popup.dart';
import 'select_favlist_popup.dart';

class BiliResourceItem extends StatefulWidget {
  final BiliResource resource;
  // Whether this episode is selected.
  final bool isSelected;
  // The source fav list id that the resource belongs to, 0 means in search mode.
  final int biliSourceFavListId;
  final Function onTap;

  const BiliResourceItem({
    super.key,
    required this.biliSourceFavListId,
    required this.resource,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<BiliResourceItem> createState() => _BiliResourceItemState();
}

class _BiliResourceItemState extends State<BiliResourceItem> {
  MyAppState? _appState;
  late int _currentPlatform;
  late bool _isUsingMockData;
  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _currentPlatform = state.currentPlatform;
    _isUsingMockData = state.isUsingMockData;
  }

  void _addResourceToFavlist(BuildContext context, MyAppState appState) async {
    if (mounted) {
      List<Future<Result?>>? list =
          await showFlexibleBottomSheet<List<Future<Result?>>>(
        minHeight: 0,
        initHeight: 0.45,
        maxHeight: 0.9,
        context: context,
        bottomSheetColor: Colors.transparent,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return SelectFavListPopup(
            scrollController: scrollController,
            biliSourceFavListId: widget.biliSourceFavListId,
            resources: [widget.resource],
            action: 'add',
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            Timer(Duration(milliseconds: 1500), () {
              // if (mounted) {
              if (appState.searchedCount == 0) {
                appState.refreshDetailFavListPage != null
                    ? appState.refreshDetailFavListPage!(appState)
                    : null;
              }
              appState.refreshLibraries != null
                  ? appState.refreshLibraries!(appState, true)
                  : null;
              // }
            });
            // Future.delayed(Duration(milliseconds: 1500), () {
            //   appState.refreshDetailFavListPage!(appState);
            //   appState.refreshLibraries!(appState, true);
            // });
            MyToast.showToast('Add resources successfully');
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var resource = widget.resource;
    MyAppState appState = context.watch<MyAppState>();
    _currentPlatform = appState.currentPlatform;
    _isUsingMockData = appState.isUsingMockData;
    return Material(
      child: InkWell(
        onTap: () {
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.only(
              left: 12.0, top: 12.0, right: 4.0, bottom: 12.0),
          child: SizedBox(
            height: 80.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Ink(
                  width: 128.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        4.0,
                      ),
                      border: widget.isSelected
                          ? Border.all(color: Color(0xFFFB6A9D))
                          : Border.all(width: 0.0)),
                  child: GestureDetector(
                    onTap: () {
                      print(appState);
                      setState(() {});
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: _isUsingMockData
                          ? Image.asset(
                              resource.cover,
                              fit: BoxFit.cover,
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: resource.cover.isNotEmpty
                                      ? resource.cover.substring(0, 4) == 'http'
                                          ? resource.cover
                                          : 'https:${resource.cover}'
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
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(
                                            formatDuration(resource.duration),
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
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: textTheme.labelSmall!.copyWith(
                                  color: widget.isSelected
                                      ? Color(0xFFFB6A9D)
                                      : colorScheme.onPrimary.withOpacity(0.9),
                                ),
                                children: [
                                  widget.isSelected
                                      ? WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0, right: 4.0),
                                            child: Lottie.asset(
                                              'assets/images/lottie_wave.json',
                                              height: 10.0,
                                              width: 10.0,
                                            ),
                                          ),
                                        )
                                      : TextSpan(),
                                  WidgetSpan(
                                    child: Html(
                                      data:
                                          '<header>${resource.title}</header>',
                                      style: {
                                        'em': Style(
                                          color: Color(0xFFFB6A9D),
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        'header': Style(
                                          fontStyle: FontStyle.normal,
                                          maxLines: 2,
                                          textOverflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.6),
                                        ),
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    resource.upperName.isNotEmpty
                                        ? Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1.0, right: 5.0),
                                                child: Image.asset(
                                                  'assets/images/up.png',
                                                  height: 12.0,
                                                ),
                                              ),
                                              Text(
                                                resource.upperName,
                                                style: textTheme.labelSmall!
                                                    .copyWith(
                                                  fontSize: 12.0,
                                                  color: colorScheme.onPrimary
                                                      .withOpacity(0.5),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Image.asset(
                                                'assets/images/bili_play_count.png',
                                                color: colorScheme.onPrimary
                                                    .withOpacity(0.5),
                                                height: 16.0,
                                              ),
                                            ),
                                            Text(
                                              humanizeInt(resource.playCount),
                                              style: textTheme.labelSmall!
                                                  .copyWith(
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
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Image.asset(
                                                'assets/images/bili_danmaku.png',
                                                color: colorScheme.onPrimary
                                                    .withOpacity(0.5),
                                                height: 16.0,
                                              ),
                                            ),
                                            Text(
                                              humanizeInt(
                                                  resource.danmakuCount),
                                              style: textTheme.labelSmall!
                                                  .copyWith(
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
                                              padding: const EdgeInsets.only(
                                                  right: 1.0),
                                              child: Image.asset(
                                                'assets/images/bili_page.png',
                                                color: colorScheme.onPrimary
                                                    .withOpacity(0.5),
                                                height: 16.0,
                                              ),
                                            ),
                                            Text(
                                              humanizeInt(resource.page),
                                              style: textTheme.labelSmall!
                                                  .copyWith(
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
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 30.0,
                                      width: 30.0,
                                      child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            var data = await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CreateResourceItemMenuDialog(
                                                      resource:
                                                          widget.resource),
                                            );
                                            if (data == 'Add to favlist' &&
                                                mounted) {
                                              _addResourceToFavlist(
                                                  context, appState);
                                            }
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
