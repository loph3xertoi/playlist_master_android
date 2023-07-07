import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/entities/detail_song.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:provider/provider.dart';

class SongDetailPage extends StatefulWidget {
  final Song song;
  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  Future<DetailSong?>? _detailSong;

  @override
  void initState() {
    final state = Provider.of<MyAppState>(context, listen: false);
    super.initState();
    _detailSong = state.fetchDetailSong(widget.song);
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: _detailSong,
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
                    style: textTheme.labelMedium,
                  ),
                  onPressed: () {
                    setState(() {
                      _detailSong = appState.fetchDetailSong(widget.song);
                    });
                  },
                ),
              ],
            ),
          );
        } else {
          DetailSong detailSong = snapshot.data as DetailSong;
          var songName = detailSong.name;
          var singers = detailSong.singers;
          var title = detailSong.title;
          var albumName = detailSong.albumName;
          var description = detailSong.description;
          var pubTime = detailSong.pubTime;
          var size128 = detailSong.size128;
          var size320 = detailSong.size320;
          var sizeApe = detailSong.sizeApe;
          var sizeFlac = detailSong.sizeFlac;
          var isUsingMockData = appState.isUsingMockData;
          var currentDetailSong = detailSong;
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
                          appState.isPlayerPageOpened = true;
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                              songName,
                              style: textTheme.labelMedium!.copyWith(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SelectableText(
                              singers.map((e) => e.name).join(','),
                              style: textTheme.labelSmall!.copyWith(
                                fontSize: 12.0,
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
                                      ? Image.asset(
                                          MockData.detailSong.coverUri)
                                      : CachedNetworkImage(
                                          imageUrl: currentDetailSong!
                                                  .coverUri.isNotEmpty
                                              ? currentDetailSong.coverUri
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
                                child: SelectableText(
                                  title,
                                  style: textTheme.labelMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        SelectableText(
                          'albumName: $albumName',
                          style: textTheme.labelMedium,
                        ),
                        SelectableText(
                          'pubTime: $pubTime',
                          style: textTheme.labelMedium,
                        ),
                        SelectableText(
                          'size128: $size128',
                          style: textTheme.labelMedium,
                        ),
                        SelectableText(
                          'size320: $size320',
                          style: textTheme.labelMedium,
                        ),
                        SelectableText(
                          'sizeApe: $sizeApe',
                          style: textTheme.labelMedium,
                        ),
                        SelectableText(
                          'sizeFlac: $sizeFlac',
                          style: textTheme.labelMedium,
                        ),
                        SingleChildScrollView(
                          child: Container(
                            height: 400.0,
                            width: double.infinity,
                            color: colorScheme.secondary.withOpacity(0.3),
                            child: SelectableText(
                              'description: $description',
                              style: textTheme.labelMedium,
                            ),
                          ),
                        ),
                      ],
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
