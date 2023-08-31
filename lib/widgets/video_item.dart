import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_video.dart';
import '../entities/netease_cloud_music/ncm_video.dart';
import '../entities/qq_music/qqmusic_video.dart';
import '../http/api.dart';
import '../http/my_http.dart';
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
    dynamic video = widget.video;
    final state = Provider.of<MyAppState>(context, listen: false);
    var currentPlatform = state.currentPlatform;
    if (currentPlatform == 0) {
      if (video is QQMusicVideo || video is NCMVideo) {
        _video = video;
      } else {
        throw 'Invalid video type';
      }
    } else if (currentPlatform == 1) {
      _video = widget.video as QQMusicVideo;
    } else if (currentPlatform == 2) {
      _video = widget.video as NCMVideo;
    } else if (currentPlatform == 3) {
      throw UnimplementedError('Not yet implement bilibili platform');
    } else {
      throw UnsupportedError('Invalid platform');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (_video is QQMusicVideo) {
      return QQMusicVideoItem(video: _video, textTheme: textTheme);
    } else if (_video is NCMVideo) {
      return NCMVideoItem(
          video: _video, textTheme: textTheme, colorScheme: colorScheme);
    } else {
      throw 'Invalid video type';
    }
  }
}

class QQMusicVideoItem extends StatelessWidget {
  const QQMusicVideoItem({
    super.key,
    required video,
    required this.textTheme,
  }) : _video = video;

  final QQMusicVideo _video;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
                    kIsWeb ? API.convertImageUrl(_video.cover) : _video.cover,
                    cacheManager: MyHttp.myImageCacheManager,
                  ),
                  height: 100.0,
                  width: 160.0,
                  fit: BoxFit.cover,
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
                    '${humanizeInt(_video.playCount)} views',
                    style: textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                    _video.name,
                    style: textTheme.labelLarge!.copyWith(
                      fontSize: 16.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _video.singers.map((e) => e.name).join(', '),
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

class NCMVideoItem extends StatelessWidget {
  const NCMVideoItem({
    super.key,
    required video,
    required this.textTheme,
    required this.colorScheme,
  }) : _video = video;

  final NCMVideo _video;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  String formatDuration(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    int remainedSeconds = duration.inSeconds % 60;
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

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'[a-zA-Z]');
    bool isMV = !regex.hasMatch(_video.id);
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
                    kIsWeb ? API.convertImageUrl(_video.cover) : _video.cover,
                    cacheManager: MyHttp.myImageCacheManager,
                  ),
                  height: 100.0,
                  width: 160.0,
                  fit: BoxFit.cover,
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white70,
                  size: 80.0,
                ),
                Positioned(
                  right: 8.0,
                  bottom: 2.0,
                  child: Text(
                    formatDuration(_video.duration),
                    style: textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              isMV
                                  ? WidgetSpan(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 4.0, bottom: 3.0),
                                        child: Image.asset(
                                          'assets/images/ncm_mv.png',
                                          width: 20.0,
                                        ),
                                      ),
                                    )
                                  : TextSpan(),
                              TextSpan(
                                text: _video.name,
                                style: textTheme.labelLarge!.copyWith(
                                  fontSize: 16.0,
                                  overflow: TextOverflow.ellipsis,
                                  color: colorScheme.onPrimary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _video.singers.map((e) => e.name).join(', '),
                          style: textTheme.labelSmall!.copyWith(
                            fontSize: 12.0,
                            color: colorScheme.onPrimary.withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${humanizeInt(_video.playCount)} views',
                              style: textTheme.labelSmall!.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                '·',
                                style: textTheme.labelSmall!.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(_video.publishTime))),
                              style: textTheme.labelSmall!.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
