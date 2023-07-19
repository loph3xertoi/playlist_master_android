import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../entities/basic/basic_library.dart';
import '../entities/basic/basic_song.dart';
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
  @override
  void initState() {
    super.initState();
  }

  void _addSongToLibrary(BuildContext context, MyAppState appState) async {
    if (mounted) {
      showFlexibleBottomSheet(
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
            song: widget.song,
          );
        },
        anchors: [0, 0.45, 0.9],
        isSafeArea: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 50.0,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SizedBox(
              width: 40.0,
              height: 50.0,
              child: Center(
                child: Text(
                  (widget.index + 1).toString(),
                  style: widget.song.payPlay == 1
                      ? textTheme.labelSmall!.copyWith(
                          color: colorScheme.onTertiary,
                        )
                      : widget.song.isTakenDown
                          ? textTheme.labelSmall!.copyWith(
                              color: colorScheme.onTertiary,
                              fontStyle: FontStyle.italic,
                            )
                          : textTheme.labelSmall,
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
                  style: widget.song.payPlay == 1
                      ? textTheme.labelMedium!.copyWith(
                          color: colorScheme.onTertiary,
                        )
                      : widget.song.isTakenDown
                          ? textTheme.labelMedium!.copyWith(
                              color: colorScheme.onTertiary,
                              fontStyle: FontStyle.italic,
                            )
                          : textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.song.singers.map((e) => e.name).join(', '),
                  style: widget.song.payPlay == 1
                      ? textTheme.labelSmall!.copyWith(
                          color: colorScheme.onTertiary,
                          fontSize: 10.0,
                        )
                      : widget.song.isTakenDown
                          ? textTheme.labelSmall!.copyWith(
                              fontSize: 10.0,
                              color: colorScheme.onTertiary,
                              fontStyle: FontStyle.italic,
                            )
                          : textTheme.labelSmall!.copyWith(
                              fontSize: 10.0,
                            ),
                  overflow: TextOverflow.ellipsis,
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
                  iconColor: widget.song.isTakenDown || widget.song.payPlay == 1
                      ? colorScheme.onTertiary
                      : colorScheme.tertiary,
                  size: 24.0,
                  isLiked: false,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    if (!widget.song.isTakenDown &&
                        (widget.song.payPlay == 0)) {
                      if (appState.player == null) {
                        appState.queue = [widget.song];
                        try {
                          await appState.initAudioPlayer();
                        } catch (e) {
                          MyToast.showToast('Exception: $e');
                          MyLogger.logger.e('Exception: $e');
                          appState.queue = [];
                          appState.currentDetailSong = null;
                          appState.currentPlayingSongInQueue = 0;
                          appState.currentSong = null;
                          appState.prevSong = null;
                          appState.isPlaying = false;
                          appState.player!.stop();
                          appState.player!.dispose();
                          appState.player = null;
                          appState.initQueue!.clear();
                          appState.isPlayerPageOpened = false;
                          appState.canSongPlayerPagePop = false;
                          return;
                        }
                        appState.currentPlayingSongInQueue = 0;

                        appState.currentSong = widget.song;

                        appState.prevSong = appState.currentSong;

                        appState.currentDetailSong = null;

                        appState.player!.play();

                        MyToast.showToast('Added to queue');
                      } else {
                        appState.queue!.insert(
                            appState.currentPlayingSongInQueue! + 1,
                            widget.song);
                        AudioSource newAudioSource;
                        if (appState.isUsingMockData) {
                          newAudioSource = AudioSource.asset(
                            widget.song.songLink,
                            tag: MediaItem(
                              // Specify a unique ID for each media item:
                              id: Uuid().v1(),
                              // Metadata to display in the notification:
                              album: 'Album name',
                              artist: widget.song.singers
                                  .map((e) => e.name)
                                  .join(', '),
                              title: widget.song.name,
                              artUri: await appState.getImageFileFromAssets(
                                  widget.song.cover,
                                  appState.queue!.indexOf(widget.song)),
                            ),
                          );
                        } else {
                          newAudioSource = LockCachingAudioSource(
                            Uri.parse(widget.song.songLink),
                            tag: MediaItem(
                              // Specify a unique ID for each media item:
                              id: Uuid().v1(),
                              // Metadata to display in the notification:
                              album: 'Album name',
                              artist: widget.song.singers
                                  .map((e) => e.name)
                                  .join(', '),
                              title: widget.song.name,
                              artUri: Uri.parse(widget.song.cover),
                            ),
                          );
                        }
                        appState.initQueue!.insert(
                            appState.currentPlayingSongInQueue! + 1,
                            newAudioSource);
                        MyToast.showToast('Added to queue');
                      }
                    } else {
                      if (widget.song.payPlay == 1) {
                        MyToast.showToast('This song need vip to play');
                        MyLogger.logger.e('This song need vip to play');
                      } else if (widget.song.isTakenDown) {
                        MyToast.showToast('This song is taken down');
                        MyLogger.logger.e('This song is taken down');
                      }
                    }
                  },
                  color: widget.song.isTakenDown || widget.song.payPlay == 1
                      ? colorScheme.onTertiary
                      : colorScheme.tertiary,
                  icon: Icon(
                    Icons.queue_play_next_rounded,
                  )),
              IconButton(
                  onPressed: () async {
                    var data = await showDialog(
                      context: context,
                      builder: (context) =>
                          CreateSongItemMenuDialog(song: widget.song),
                    );
                    if (data == 'Add to library' && mounted) {
                      _addSongToLibrary(context, appState);
                    }
                  },
                  color: widget.song.isTakenDown || widget.song.payPlay == 1
                      ? colorScheme.onTertiary
                      : colorScheme.tertiary,
                  icon: Icon(
                    Icons.more_vert_rounded,
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}
