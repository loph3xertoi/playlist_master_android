import 'package:flutter/material.dart';

import '../entities/bilibili/bili_resource.dart';

class SelectableResourceItem extends StatelessWidget {
  const SelectableResourceItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.resource,
  });

  final int index;
  final bool isSelected;
  final BiliResource resource;

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
                  resource.title,
                  style: textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  resource.upperName,
                  style: textTheme.labelSmall!.copyWith(fontSize: 10.0),
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
