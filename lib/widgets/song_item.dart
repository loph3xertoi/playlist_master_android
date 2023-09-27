import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../entities/basic/basic_song.dart';
import '../entities/dto/result.dart';
import '../entities/netease_cloud_music/ncm_song.dart';
import '../entities/pms/pms_song.dart';
import '../entities/qq_music/qqmusic_song.dart';
import '../http/api.dart';
import '../states/app_state.dart';
import '../third_lib_change/like_button/like_button.dart';
import '../utils/my_logger.dart';
import '../utils/my_toast.dart';
import 'select_library_popup.dart';
import 'song_item_menu_popup.dart';

class SongItem extends StatefulWidget {
  final int index;
  final BasicSong song;

  const SongItem({
    super.key,
    required this.index,
    required this.song,
  });

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  void _addSongToLibrary(BuildContext context, MyAppState appState,
      [bool addToPMS = false]) async {
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
          return SelectLibraryPopup(
            scrollController: scrollController,
            songs: [widget.song],
            action: 'add',
            addToPMS: addToPMS,
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
      if (list != null) {
        List<Result?> results = await Future.wait<Result?>(list);
        for (Result? result in results) {
          if (result != null && result.success) {
            if (!addToPMS) {
              appState.refreshLibraries!(appState, true);
              appState.refreshDetailLibraryPage!(appState);
            }
            MyToast.showToast('Add songs successfully');
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
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    bool isTakenDown = widget.song.isTakenDown;
    int payPlayType = widget.song.payPlay;
    return SizedBox(
      height: 50.0,
      child: Row(
        children: [
          if (currentPlatform == 0)
            Container(
              width: 3.0,
              height: 50.0,
              color: _getColorForPMSSong(widget.song),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SizedBox(
              width: 30.0,
              height: 50.0,
              child: Center(
                child: Text(
                  (widget.index + 1).toString(),
                  style: textTheme.labelSmall,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.name,
                  style: textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    payPlayType == 1 &&
                            ((currentPlatform == 0 &&
                                    (widget.song as PMSSong).type == 1) ||
                                currentPlatform == 1)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: Image.asset(
                              'assets/images/vip_item_qqmusic.png',
                              width: 20.0,
                            ),
                          )
                        : (payPlayType == 1 &&
                                ((currentPlatform == 0 &&
                                        (widget.song as PMSSong).type == 2) ||
                                    currentPlatform == 2))
                            ? Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                child: Image.asset(
                                  'assets/images/vip_item_ncm.png',
                                  width: 20.0,
                                ),
                              )
                            : Container(),
                    isTakenDown &&
                            (currentPlatform == 2 ||
                                currentPlatform == 0 ||
                                (currentPlatform == 1 && payPlayType == 0))
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 3.0, right: 3.0),
                            child: Image.asset(
                              'assets/images/no_song.png',
                              width: 30.0,
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: Text(
                        widget.song.singers.map((e) => e.name).join(', '),
                        style: textTheme.labelSmall!.copyWith(
                          fontSize: 10.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40.0,
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: LikeButton(
                  iconColor: colorScheme.tertiary,
                  size: 24.0,
                  isLiked: false,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    if ((currentPlatform == 1 || currentPlatform == 0) &&
                        payPlayType == 1) {
                      MyToast.showToast('This song need vip to play');
                      MyLogger.logger.e('This song need vip to play');
                      return;
                    }

                    if (isTakenDown) {
                      MyToast.showToast('This song is taken down');
                      MyLogger.logger.e('This song is taken down');
                      return;
                    }

                    if (appState.songsPlayer == null) {
                      appState.songsQueue = [widget.song];
                      appState.currentPlayingSongInQueue = 0;
                      try {
                        await appState.initSongsPlayer();
                      } catch (e) {
                        MyToast.showToast('Exception: $e');
                        MyLogger.logger.e('Exception: $e');
                        appState.disposeSongsPlayer();
                        return;
                      }

                      appState.currentSong = widget.song;

                      appState.prevSong = appState.currentSong;

                      appState.currentDetailSong = null;

                      appState.songsPlayer!.play();

                      MyToast.showToast('Added to queue');
                    } else {
                      appState.songsQueue!.insert(
                          appState.currentPlayingSongInQueue! + 1, widget.song);
                      AudioSource newAudioSource;
                      if (appState.isUsingMockData) {
                        newAudioSource = AudioSource.asset(
                          widget.song.songLink!,
                          tag: MediaItem(
                            // Specify a unique ID for each media item:
                            id: Uuid().v1(),
                            // Metadata to display in the notification:
                            album: 'Album name',
                            artist: widget.song.singers
                                .map((e) => e.name)
                                .join(', '),
                            title: widget.song.name,
                            artUri: kIsWeb
                                ? Uri.parse(MyAppState.defaultCoverImage)
                                : await appState.getImageFileFromAssets(
                                    widget.song.cover,
                                    appState.songsQueue!.indexOf(widget.song)),
                          ),
                        );
                      } else {
                        if (kIsWeb) {
                          newAudioSource = AudioSource.uri(
                            Uri.parse(widget.song.songLink!),
                            tag: MediaItem(
                              // Specify a unique ID for each media item:
                              id: Uuid().v1(),
                              // Metadata to display in the notification:
                              album: 'Album name',
                              artist: widget.song.singers
                                  .map((e) => e.name)
                                  .join(', '),
                              title: widget.song.name,
                              artUri: Uri.parse(
                                  API.convertImageUrl(widget.song.cover)),
                            ),
                          );
                        } else {
                          PMSSong initialSong = widget.song as PMSSong;
                          var songLink = await appState
                              .fetchSongsLink([initialSong.id.toString()], 0);
                          newAudioSource = LockCachingAudioSource(
                            Uri.parse(songLink!),
                            tag: MediaItem(
                              // Specify a unique ID for each media item:
                              id: Uuid().v1(),
                              // Metadata to display in the notification:
                              album: 'Album name',
                              artist: initialSong.singers
                                  .map((e) => e.name)
                                  .join(', '),
                              title: initialSong.name,
                              artUri: Uri.parse(initialSong.cover),
                            ),
                          );
                        }
                      }
                      appState.songsAudioSource!.insert(
                          appState.currentPlayingSongInQueue! + 1,
                          newAudioSource);
                      MyToast.showToast('Added to queue');
                    }
                  },
                  color: colorScheme.tertiary,
                  tooltip: 'Add to queue',
                  icon: Icon(
                    Icons.queue_play_next_rounded,
                  )),
              IconButton(
                  onPressed: () async {
                    var data = await showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) =>
                          CreateSongItemMenuDialog(song: widget.song),
                    );
                    if (data == 'Add to library' && mounted) {
                      _addSongToLibrary(context, appState);
                    }
                    if (data == 'Add to pms' && mounted) {
                      _addSongToLibrary(context, appState, true);
                    }
                  },
                  color: colorScheme.tertiary,
                  tooltip: 'Edit song',
                  icon: Icon(
                    Icons.more_vert_rounded,
                  )),
            ]),
          ),
          // if (currentPlatform == 0)
          //   Container(
          //     width: 3.0,
          //     height: 50.0,
          //     color: _getColorForPMSSong(widget.song),
          //   ),
        ],
      ),
    );
  }

  Color _getColorForPMSSong(BasicSong song) {
    int songType;
    if (song is PMSSong) {
      songType = song.type;
    } else if (song is QQMusicSong) {
      songType = 1;
    } else if (song is NCMSong) {
      songType = 2;
    } else {
      throw 'Invalid song type';
    }
    Color songColor;
    if (songType == 0) {
      songColor = Colors.transparent;
    } else if (songType == 1) {
      songColor = Color(0xFF13BE72);
    } else if (songType == 2) {
      songColor = Color(0xFFDF0000);
    } else if (songType == 3) {
      songColor = Color(0xFFFF558A);
    } else {
      throw 'Invalid song type';
    }
    return songColor;
  }
}
