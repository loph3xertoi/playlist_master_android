import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_video.dart';
import '../entities/netease_cloud_music/ncm_video.dart';
import '../entities/pms/pms_song.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../states/app_state.dart';
import '../utils/my_logger.dart';
import '../widgets/my_selectable_text.dart';
import '../widgets/video_item.dart';

class RelatedVideosPage extends StatefulWidget {
  const RelatedVideosPage({super.key, required this.song});

  final BasicSong song;

  @override
  State<RelatedVideosPage> createState() => _RelatedVideosPageState();
}

class _RelatedVideosPageState extends State<RelatedVideosPage> {
  late Future<List<BasicVideo>?> _relatedVideos;

  late int _currentPlatform;

  late bool _isUsingMockData;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    _isUsingMockData = state.isUsingMockData;
    _currentPlatform = state.currentPlatform;
    if (_isUsingMockData) {
      throw UnimplementedError('No mock data for video');
    } else {
      _relatedVideos = state.fetchRelatedMVs(widget.song, _currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    _currentPlatform = appState.currentPlatform;
    _isUsingMockData = appState.isUsingMockData;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _relatedVideos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              MyLogger.logger.e(
                  snapshot.hasError ? '${snapshot.error}' : appState.errorMsg);
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
                              _relatedVideos = appState.fetchRelatedMVs(
                                  widget.song, _currentPlatform);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              dynamic relatedVideos;
              if (_isUsingMockData) {
                relatedVideos = snapshot.data!.cast<QQMusicVideo>().toList();
              } else {
                if (_currentPlatform == 0) {
                  var songType = (widget.song as PMSSong).type;
                  if (songType == 1) {
                    relatedVideos =
                        snapshot.data!.cast<QQMusicVideo>().toList();
                  } else if (songType == 2) {
                    relatedVideos = snapshot.data!.cast<NCMVideo>().toList();
                  } else {
                    throw 'Invalid song type';
                  }
                } else if (_currentPlatform == 1) {
                  relatedVideos = snapshot.data!.cast<QQMusicVideo>().toList();
                } else if (_currentPlatform == 2) {
                  relatedVideos = snapshot.data!.cast<NCMVideo>().toList();
                } else if (_currentPlatform == 3) {
                  throw UnimplementedError(
                      'Not yet implement bilibili platform');
                } else {
                  throw UnsupportedError('Invalid platform');
                }
              }
              return relatedVideos.length == 0
                  ? Center(
                      child: Text(
                        'This song has no videos.',
                        style: textTheme.labelLarge,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: RefreshIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2.0,
                          onRefresh: () async {
                            setState(() {
                              _relatedVideos = appState.fetchRelatedMVs(
                                  widget.song, _currentPlatform);
                            });
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // padding: EdgeInsets.all(10.0),
                            itemCount: relatedVideos.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/video_player_page',
                                            arguments: relatedVideos[index]);
                                      },
                                      child: VideoItem(
                                        video: relatedVideos[index],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
            }
          },
        ),
      ),
    );
  }
}
