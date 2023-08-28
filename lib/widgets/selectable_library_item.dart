import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../entities/basic/basic_library.dart';
import '../http/api.dart';
import '../http/my_http.dart';
import '../states/app_state.dart';

class SelectableLibraryItem extends StatelessWidget {
  const SelectableLibraryItem({
    super.key,
    required this.library,
    required this.isCreateLibraryItem,
    required this.inMultiSelectMode,
    required this.selected,
  });

  final BasicLibrary? library;
  final bool isCreateLibraryItem;
  final bool inMultiSelectMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    var isUsingMockData = appState.isUsingMockData;
    return Ink(
      height: 60.0,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13.0, 7.0, 0.0, 7.0),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                width: 46.0,
                height: 46.0,
                color: colorScheme.secondary,
                child: isCreateLibraryItem
                    ? Icon(Icons.add_rounded)
                    : isUsingMockData
                        ? Image.asset(library!.cover)
                        : CachedNetworkImage(
                            imageUrl: library!.cover.isNotEmpty
                                ? kIsWeb
                                    ? API.convertImageUrl(library!.cover)
                                    : library!.cover
                                : MyAppState.defaultLibraryCover,
                            cacheManager: MyHttp.myImageCacheManager,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(MdiIcons.debian),
                          ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 7.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        isCreateLibraryItem
                            ? 'Create new library'
                            : library!.name,
                        style: textTheme.labelSmall!.copyWith(fontSize: 13.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    isCreateLibraryItem
                        ? Container()
                        : Text(
                            '${library!.itemCount} songs',
                            style:
                                textTheme.labelSmall!.copyWith(fontSize: 11.0),
                          ),
                  ],
                ),
              ),
            ),
            inMultiSelectMode
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Icon(
                      selected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: colorScheme.tertiary.withOpacity(0.8),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
