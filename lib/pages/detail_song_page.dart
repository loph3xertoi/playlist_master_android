import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_singer.dart';
import '../entities/basic/basic_song.dart';
import '../entities/netease_cloud_music/ncm_detail_song.dart';
import '../entities/netease_cloud_music/ncm_lyrics.dart';
import '../entities/qq_music/qqmusic_detail_song.dart';
import '../entities/qq_music/qqmusic_lyrics.dart';
import '../mock_data.dart';
import '../states/app_state.dart';
import '../widgets/my_lyrics_displayer.dart';
import '../widgets/my_selectable_text.dart';

class DetailSongPage extends StatefulWidget {
  final BasicSong song;
  const DetailSongPage({super.key, required this.song});

  @override
  State<DetailSongPage> createState() => _DetailSongPageState();
}

class _DetailSongPageState extends State<DetailSongPage> {
  Future<BasicSong?>? _detailSong;
  LyricsReaderModel? _lyricModel;
  late MyLyricsDisplayer _lyricUI;
  int _position = 0;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textTheme = Theme.of(context).textTheme;
      _lyricUI = MyLyricsDisplayer(
        bias: 0.1,
        // defaultSize: 14.0,
        // defaultExtSize: 12.0,
        // otherMainSize: 16.0,
        inlineGap: 0.0,
        lineGap: 20.0,
        highlight: false,
        textTheme: textTheme,
      );
    });

    var isUsingMockData = state.isUsingMockData;
    if (isUsingMockData) {
      _detailSong = Future.value(MockData.detailSong);
    } else {
      _detailSong = state.fetchDetailSong(widget.song, state.currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    var currentPlatform = appState.currentPlatform;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: _detailSong,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
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
                      _detailSong = appState.fetchDetailSong(
                          widget.song, appState.currentPlatform);
                    });
                  },
                ),
              ],
            ),
          );
        } else {
          dynamic detailSong;
          String? name;
          List<BasicSinger> singers;
          String? title;
          String? albumName;
          String? description;
          dynamic pubTime;
          BasicSong currentDetailSong;
          if (isUsingMockData) {
            detailSong = snapshot.data as QQMusicDetailSong;
            name = detailSong.name;
            singers = detailSong.singers;
            title = detailSong.subTitle;
            albumName = detailSong.albumName;
            description = detailSong.songDesc ?? 'No description';
            pubTime = detailSong.pubTime;
            currentDetailSong = detailSong;
            QQMusicLyrics lyrics = detailSong.lyrics;
            _lyricModel ??= LyricsModelBuilder.create()
                .bindLyricToMain(lyrics.lyric)
                .bindLyricToExt(lyrics.trans)
                .getModel();
          } else {
            if (currentPlatform == 0) {
              throw UnimplementedError('Not yet implement pms platform');
            } else if (currentPlatform == 1) {
              detailSong = snapshot.data as QQMusicDetailSong;
              name = detailSong.name;
              singers = detailSong.singers;
              title = detailSong.subTitle;
              albumName = detailSong.albumName;
              description = detailSong.songDesc ?? 'No description';
              pubTime = detailSong.pubTime;
              currentDetailSong = detailSong;
              // var size128 = detailSong.size128;
              // var size320 = detailSong.size320;
              // var sizeApe = detailSong.sizeApe;
              // var sizeFlac = detailSong.sizeFlac;
              QQMusicLyrics lyrics = detailSong.lyrics;
              _lyricModel ??= LyricsModelBuilder.create()
                  .bindLyricToMain(lyrics.lyric)
                  .bindLyricToExt(lyrics.trans)
                  .getModel();
            } else if (currentPlatform == 2) {
              detailSong = snapshot.data as NCMDetailSong;
              name = detailSong.name;
              singers = detailSong.singers;
              albumName = detailSong.albumName;
              description = 'No description';
              pubTime = DateFormat('yyyy-MM-dd').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(detailSong.publishTime)));
              currentDetailSong = detailSong;
              NCMLyrics lyrics = detailSong.lyrics;
              //TODO: advanced lyrics.
              _lyricModel ??= LyricsModelBuilder.create()
                  .bindLyricToMain(lyrics.lyric)
                  .bindLyricToExt(lyrics.tLyric)
                  .getModel();
            } else if (currentPlatform == 3) {
              throw UnimplementedError('Not yet implement bilibili platform');
            } else {
              throw UnsupportedError('Invalid platform');
            }
          }

          return Center(
            child: Container(
              color: colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      IconButton(
                        color: colorScheme.tertiary,
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MySelectableText(
                              name ?? 'Unknown',
                              style: textTheme.labelLarge!.copyWith(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            MySelectableText(
                              singers.map((e) => e.name).join(', '),
                              style: textTheme.labelSmall!.copyWith(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 12.0,
                            ),
                            child: Container(
                              width: 100.0,
                              height: 100.0,
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
                                      ? Image.asset(MockData.detailSong.cover)
                                      : CachedNetworkImage(
                                          imageUrl: currentDetailSong
                                                  .cover.isNotEmpty
                                              ? currentDetailSong.cover
                                              : MyAppState.defaultCoverImage,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Icon(MdiIcons.debian),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 100.0,
                              child: Align(
                                alignment: Alignment.center,
                                child: MySelectableText(
                                  albumName ?? 'Unknown',
                                  style: textTheme.labelLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        // mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title != null
                              ? MySelectableText(
                                  'title: $title',
                                  style: textTheme.labelMedium,
                                )
                              : Container(),
                          MySelectableText(
                            'pubTime: $pubTime',
                            style: textTheme.labelMedium,
                          ),

                          // SelectableText(
                          //   'size128: $size128',
                          //   style: textTheme.labelMedium,
                          // ),
                          // SelectableText(
                          //   'size320: $size320',
                          //   style: textTheme.labelMedium,
                          // ),
                          // SelectableText(
                          //   'sizeApe: $sizeApe',
                          //   style: textTheme.labelMedium,
                          // ),
                          // SelectableText(
                          //   'sizeFlac: $sizeFlac',
                          //   style: textTheme.labelMedium,
                          // ),
                          Listener(
                            onPointerUp: (details) {
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: LyricsReader(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                position: _position,
                                model: _lyricModel,
                                lyricUi: _lyricUI,
                                playing: false,
                                size: Size(double.infinity, 400.0),
                                onTap: () {},
                                emptyBuilder: () => Center(
                                  child: MySelectableText(
                                    'No lyrics',
                                    style: textTheme.labelMedium,
                                  ),
                                ),
                                selectLineBuilder: (progress, _) {
                                  _position = progress;
                                  return Container();
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                height: 100.0,
                                width: double.infinity,
                                color: colorScheme.secondary.withOpacity(0.3),
                                child: MySelectableText(
                                  'description: $description',
                                  style: textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
