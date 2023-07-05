import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:playlistmaster/mock_data.dart';
import 'package:playlistmaster/states/app_state.dart';
import 'package:provider/provider.dart';

class SongDetailPage extends StatefulWidget {
  const SongDetailPage({super.key});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    var songName = appState.currentDetailSong!.name;
    var singers = appState.currentDetailSong!.singers;
    var title = appState.currentDetailSong!.title;
    var albumName = appState.currentDetailSong!.albumName;
    var description = appState.currentDetailSong!.description;
    var pubTime = appState.currentDetailSong!.pubTime;
    var lyrics = appState.currentDetailSong!.lyrics;
    var size128 = appState.currentDetailSong!.size128;
    var size320 = appState.currentDetailSong!.size320;
    var sizeApe = appState.currentDetailSong!.sizeApe;
    var sizeFlac = appState.currentDetailSong!.sizeFlac;
    var isUsingMockData = appState.isUsingMockData;
    var currentDetailSong = appState.currentDetailSong;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return WillPopScope(
      onWillPop: () async {
        appState.isPlayerPageOpened = true;
        return true; // Allow the navigation to proceed
      },
      child: Center(
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
                                  ? Image.asset(MockData.detailSong.coverUri)
                                  : CachedNetworkImage(
                                      imageUrl:
                                          currentDetailSong!.coverUri.isNotEmpty
                                              ? currentDetailSong.coverUri
                                              : MyAppState.defaultCoverImage,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
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
      ),
    );
  }
}
