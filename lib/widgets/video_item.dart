import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_video.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../states/app_state.dart';

class VideoItem extends StatefulWidget {
  const VideoItem({super.key, required this.video});
  final BasicVideo video;
  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late dynamic _video;
  @override
  void initState() {
    super.initState();
    final state = Provider.of<MyAppState>(context, listen: false);
    var currentPlatform = state.currentPlatform;
    if (currentPlatform == 0) {
      throw UnimplementedError('Not yet implement pms platform');
    } else if (currentPlatform == 1) {
      _video = widget.video as QQMusicVideo;
    } else if (currentPlatform == 2) {
      throw UnimplementedError('Not yet implement ncm platform');
    } else if (currentPlatform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 100.0,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Ink.image(
                  image: CachedNetworkImageProvider(
                    _video.cover,
                  ),
                  height: 100.0,
                  width: 160.0,
                  fit: BoxFit.cover,
                  // child: CachedNetworkImage(
                  //   imageUrl: _video.cover,
                  //   progressIndicatorBuilder:
                  //       (context, url, downloadProgress) =>
                  //           CircularProgressIndicator(
                  //               value: downloadProgress.progress),
                  //   errorWidget: (context, url, error) => Icon(MdiIcons.debian),
                  // ),
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white70,
                  size: 80.0,
                ),
                Positioned(
                  left: 8.0,
                  bottom: 2.0,
                  child: Text(
                    '${NumberFormat('#,###').format(_video.playCnt)} viewed',
                    style: textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.video.name,
                    style: textTheme.labelLarge!.copyWith(
                      fontSize: 16.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    widget.video.singers.map((e) => e.name).join(', '),
                    style: textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
