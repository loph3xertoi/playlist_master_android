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
      throw Exception('No mock data for video');
    } else {
      _relatedVideos = state.fetchRelatedMVs(widget.song, currentPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var currentPlatform = appState.currentPlatform;
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
                  children: [
                    SelectableText(
                      'Exception: ${snapshot.error}',
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
                      icon: Icon(MdiIcons.webRefresh),
                      label: Text(
                        'Retry',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.primary,
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
              if (currentPlatform == 1) {
                relatedVideos = snapshot.data as List<QQMusicVideo>;
              } else {
                throw Exception('Only implement for qq music platform');
              }
              return relatedVideos.length == 0
                  ? Center(
                      child: Text('This song has no videos.'),
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
