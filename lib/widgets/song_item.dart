import 'package:flutter/material.dart';
import 'package:playlistmaster/entities/song.dart';
import 'package:playlistmaster/third_lib_change/like_button/like_button.dart';
import 'package:playlistmaster/widgets/create_song_item_menu_popup%20copy.dart';

class SongItem extends StatefulWidget {
  final int index;
  final Song song;

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
  Widget build(BuildContext context) {
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
                  widget.song.singers[0].name,
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
                  onPressed: () {},
                  color: widget.song.isTakenDown || widget.song.payPlay == 1
                      ? colorScheme.onTertiary
                      : colorScheme.tertiary,
                  icon: Icon(
                    Icons.queue_play_next_rounded,
                  )),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreateSongItemMenuDialog(),
                    );
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
