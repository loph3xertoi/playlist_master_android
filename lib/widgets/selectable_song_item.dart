import 'package:flutter/material.dart';

import '../entities/basic/basic_song.dart';

class SelectableSongItem extends StatelessWidget {
  const SelectableSongItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.song,
  });

  final int index;
  final bool isSelected;
  final BasicSong song;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 50.0,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              isSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: colorScheme.tertiary,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: song.payPlay == 1
                      ? textTheme.labelMedium!.copyWith(
                          color: colorScheme.onTertiary,
                        )
                      : song.isTakenDown
                          ? textTheme.labelMedium!.copyWith(
                              color: colorScheme.onTertiary,
                              fontStyle: FontStyle.italic,
                            )
                          : textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.singers.map((e) => e.name).join(', '),
                  style: song.payPlay == 1
                      ? textTheme.labelSmall!.copyWith(
                          color: colorScheme.onTertiary,
                          fontSize: 10.0,
                        )
                      : song.isTakenDown
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
        ],
      ),
    );
  }
}
