import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_song.dart';
import '../entities/basic/basic_video.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../states/app_state.dart';
import '../widgets/video_item.dart';

class RelatedVideosPage extends StatefulWidget {
  const RelatedVideosPage({super.key, required this.song});

  final BasicSong song;

  @override
  State<RelatedVideosPage> createState() => _RelatedVideosPageState();
}

class _RelatedVideosPageState extends State<RelatedVideosPage> {
  late Future<List<BasicVideo>?> _relatedVideos;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var isUsingMockData = state.isUsingMockData;
    var currentPlatform = state.currentPlatform;
    if (isUsingMockData) {
      throw UnimplementedError('No mock data for video');
    } else {
      _relatedVideos = state.fetchRelatedMVs(widget.song, currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
    var isUsingMockData = appState.isUsingMockData;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _relatedVideos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectableText(
                      '${snapshot.error}',
                      contextMenuBuilder: (context, editableTextState) {
                        final List<ContextMenuButtonItem> buttonItems =
                            editableTextState.contextMenuButtonItems;
                        return AdaptiveTextSelectionToolbar(
                          anchors: editableTextState.contextMenuAnchors,
                          children: [
                            ...buttonItems.map<Widget>((buttonItem) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: buttonItem.onPressed,
                                  child: Ink(
                                    padding: EdgeInsets.all(8.0),
                                    color: colorScheme.primary,
                                    child: Text(
                                      CupertinoTextSelectionToolbarButton
                                          .getButtonLabel(context, buttonItem),
                                      style: textTheme.labelSmall!.copyWith(
                                        color: colorScheme.onSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                          ],
                        );
                      },
                      textAlign: TextAlign.center,
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
                          _relatedVideos = appState.fetchRelatedMVs(
                              widget.song, currentPlatform);
                        });
                      },
                    ),
                  ],
                ),
              );
            } else {
              dynamic relatedVideos;
              if (isUsingMockData) {
                relatedVideos = snapshot.data as List<QQMusicVideo>;
              } else {
                if (currentPlatform == 0) {
                  throw UnimplementedError('Not yet implement pms platform');
                } else if (currentPlatform == 1) {
                  relatedVideos = snapshot.data as List<QQMusicVideo>;
                } else if (currentPlatform == 2) {
                  throw UnimplementedError('Not yet implement ncm platform');
                } else if (currentPlatform == 3) {
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
                        child: ListView.builder(
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
                    );
            }
          },
        ),
      ),
    );
  }
}
